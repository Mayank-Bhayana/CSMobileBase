//
//  CSRecordViewController.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/19/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import UIKit

open class CSRecordViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    fileprivate let notificationCenter: NotificationCenter = NotificationCenter.default
    fileprivate let settingsDidChange: Selector = #selector(CSRecordViewController.settingsDidChange(_:))
    fileprivate let keyboardDidChangeFrame: Selector = #selector(CSRecordViewController.keyboardDidChangeFrame(_:))
    fileprivate let keyboardWillHide: Selector = #selector(CSRecordViewController.keyboardWillHide(_:))
    
    internal lazy var settings: CSSettings = CSSettingsStore.instance.read()
    
    @IBOutlet open weak var tableView: UITableView?
    
    open weak var activeCell: CSFieldCell?
    
    open lazy var activityIndicatorView: UIActivityIndicatorView = self.initActivityIndicatorView()
    internal lazy var emptyView: UILabel = self.initEmptyView()
    
    open var pageLayout: CSPageLayout?
    open var record: CSRecord?
    open var theme: CSTheme?
    
    fileprivate var edgeInsets: UIEdgeInsets?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        notificationCenter.removeObserver(self, name: NSNotification.Name(rawValue: CSSettingsChangedNotification), object: nil)
        notificationCenter.addObserver(self, selector: settingsDidChange, name: NSNotification.Name(rawValue: CSSettingsChangedNotification), object: nil)
        
        self.tableView?.estimatedRowHeight = 85.0
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.separatorStyle = .none
        
        let bundle: Bundle = Bundle(for: CSRecordViewController.self)
        tableView?.register(UINib(nibName: "CSFieldCell", bundle: bundle), forCellReuseIdentifier: "CSFieldCell")
        tableView?.register(UINib(nibName: "CSStringCell", bundle: bundle), forCellReuseIdentifier: "CSStringCell")
        tableView?.register(UINib(nibName: "CSBooleanCell", bundle: bundle), forCellReuseIdentifier: "CSBooleanCell")
        tableView?.register(UINib(nibName: "CSIntegerCell", bundle: bundle), forCellReuseIdentifier: "CSIntegerCell")
        tableView?.register(UINib(nibName: "CSDoubleCell", bundle: bundle), forCellReuseIdentifier: "CSDoubleCell")
        tableView?.register(UINib(nibName: "CSPercentCell", bundle: bundle), forCellReuseIdentifier: "CSPercentCell")
        tableView?.register(UINib(nibName: "CSCurrencyCell", bundle: bundle), forCellReuseIdentifier: "CSCurrencyCell")
        tableView?.register(UINib(nibName: "CSTextAreaCell", bundle: bundle), forCellReuseIdentifier: "CSTextAreaCell")
        tableView?.register(UINib(nibName: "CSPickListCell", bundle: bundle), forCellReuseIdentifier: "CSPickListCell")
        tableView?.register(UINib(nibName: "CSDateCell", bundle: bundle), forCellReuseIdentifier: "CSDateCell")
        tableView?.register(UINib(nibName: "CSDateTimeCell", bundle: bundle), forCellReuseIdentifier: "CSDateTimeCell")
        tableView?.register(UINib(nibName: "CSPhoneCell", bundle: bundle), forCellReuseIdentifier: "CSPhoneCell")
        tableView?.register(UINib(nibName: "CSEmailCell", bundle: bundle), forCellReuseIdentifier: "CSEmailCell")
        tableView?.register(UINib(nibName: "CSUrlCell", bundle: bundle), forCellReuseIdentifier: "CSUrlCell")
        tableView?.register(UINib(nibName: "CSAddressCell", bundle: bundle), forCellReuseIdentifier: "CSAddressCell")
        tableView?.register(UINib(nibName: "CSGeoLocationCell", bundle: bundle), forCellReuseIdentifier: "CSGeoLocationCell")
        tableView?.register(UINib(nibName: "CSReferenceCell", bundle: bundle), forCellReuseIdentifier: "CSReferenceCell")
        tableView?.register(UINib(nibName: "CSPersonNameCell", bundle: bundle), forCellReuseIdentifier: "CSPersonNameCell")
        if let theme: CSTheme = theme {
            applyTheme(theme)
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notificationCenter.addObserver(self, selector: keyboardDidChangeFrame, name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
        notificationCenter.addObserver(self, selector: keyboardWillHide, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pageLayout?.fieldLayouts.count ?? 0
    }
    
//    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if let fieldLayout: CSFieldLayout = pageLayout?.fieldLayouts[indexPath.row] {
//            if fieldLayout.type == CSFieldType.TextArea {
//                return 150
//            }
//            if fieldLayout.type == CSFieldType.Address {
//                return 200
//            }
//        }
//        return 80
//    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fieldLayout: CSFieldLayout = pageLayout!.fieldLayouts[indexPath.row]
        return dequeueReusableFieldCell(fieldLayout, tableView: tableView, indexPath: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let theme: CSTheme = theme, let cell: CSFieldCell = cell as? CSFieldCell {
            cell.applyTheme(theme: theme)
        }
    }
    
    open func dequeueReusableFieldCell(_ fieldLayout: CSFieldLayout, tableView: UITableView, indexPath: IndexPath) -> CSFieldCell {
        if fieldLayout.type == CSFieldType.String && fieldLayout.extraTypeInfo == CSExtraTypeInfo.PersonName {
            let cell: CSPersonNameCell = tableView.dequeueReusableCell(withIdentifier: "CSPersonNameCell", for: indexPath) as! CSPersonNameCell
            cell.label.text = fieldLayout.label?.localizedUppercase
            cell.value = CSPersonName(record: record)
            cell.length = fieldLayout.length ?? 255
            cell.pickListValues = salutationPickListValues(fieldLayout.name)
            cell.delegate = self
            return cell
        }
        else if fieldLayout.type == CSFieldType.String && fieldLayout.extraTypeInfo == nil {
            let cell: CSStringCell = tableView.dequeueReusableCell(withIdentifier: "CSStringCell", for: indexPath) as! CSStringCell
            cell.label.text = fieldLayout.label?.localizedUppercase
            cell.value = record?.getString(fieldLayout.name.platformCaseStringValue)
            cell.length = fieldLayout.length ?? 255
            cell.delegate = self
            return cell
        }
        else if fieldLayout.type == CSFieldType.Integer {
            let cell: CSIntegerCell = tableView.dequeueReusableCell(withIdentifier: "CSIntegerCell", for: indexPath) as! CSIntegerCell
            cell.label.text = fieldLayout.label?.localizedUppercase
            cell.value = record?.getInteger(fieldLayout.name.platformCaseStringValue)
            cell.length = fieldLayout.length ?? 10
            cell.delegate = self
            return cell
        }
        else if fieldLayout.type == CSFieldType.Double {
            let cell: CSDoubleCell = tableView.dequeueReusableCell(withIdentifier: "CSDoubleCell", for: indexPath) as! CSDoubleCell
            cell.label.text = fieldLayout.label?.localizedUppercase
            cell.value = record?.getDouble(fieldLayout.name.platformCaseStringValue)
            cell.length = fieldLayout.length ?? 10
            cell.scale = fieldLayout.scale ?? 0
            cell.delegate = self
            return cell
        }
        else if fieldLayout.type == CSFieldType.Percent {
            let cell: CSPercentCell = tableView.dequeueReusableCell(withIdentifier: "CSPercentCell", for: indexPath) as! CSPercentCell
            cell.label.text = fieldLayout.label?.localizedUppercase
            cell.value = record?.getDouble(fieldLayout.name.platformCaseStringValue)
            cell.length = fieldLayout.length ?? 10
            cell.scale = fieldLayout.scale ?? 0
            cell.delegate = self
            return cell
        }
        else if fieldLayout.type == CSFieldType.Currency {
            let cell: CSCurrencyCell = tableView.dequeueReusableCell(withIdentifier: "CSCurrencyCell", for: indexPath) as! CSCurrencyCell
            cell.label.text = fieldLayout.label?.localizedUppercase
            cell.value = record?.getDouble(fieldLayout.name.platformCaseStringValue)
            cell.isoCode = record?.getString(CSRecord.Field.currencyIsoCode.platformSpecificRawValue)
            cell.length = fieldLayout.length ?? 10
            cell.scale = fieldLayout.scale ?? 0
            cell.delegate = self
            return cell
        }
        else if fieldLayout.type == CSFieldType.Boolean {
            let cell: CSBooleanCell = tableView.dequeueReusableCell(withIdentifier: "CSBooleanCell", for: indexPath) as! CSBooleanCell
            cell.label.text = fieldLayout.label?.localizedUppercase
            cell.value = record?.getBoolean(fieldLayout.name.platformCaseStringValue) ?? false
            cell.delegate = self
            return cell
        }
        else if fieldLayout.type == CSFieldType.TextArea {
            let cell: CSTextAreaCell = tableView.dequeueReusableCell(withIdentifier: "CSTextAreaCell", for: indexPath) as! CSTextAreaCell
            cell.label.text = fieldLayout.label?.localizedUppercase
            cell.value = record?.getString(fieldLayout.name.platformCaseStringValue)
            cell.length = fieldLayout.length ?? 131072
            cell.delegate = self
            return cell
        }
        else if fieldLayout.type == CSFieldType.PickList {
            let cell: CSPickListCell = tableView.dequeueReusableCell(withIdentifier: "CSPickListCell", for: indexPath) as! CSPickListCell
            cell.label.text = fieldLayout.label?.localizedUppercase
            cell.value = record?.getString(fieldLayout.name.platformCaseStringValue) ?? fieldLayout.defaultValue
            cell.pickListValues = fieldLayout.options
            cell.delegate = self
            return cell
        }
        else if fieldLayout.type == CSFieldType.Date {
            let cell: CSDateCell = tableView.dequeueReusableCell(withIdentifier: "CSDateCell", for: indexPath) as! CSDateCell
            cell.label.text = fieldLayout.label?.localizedUppercase
            cell.value = record?.getDate(fieldLayout.name.platformCaseStringValue)
            cell.delegate = self
            return cell
        }
        else if fieldLayout.type == CSFieldType.DateTime {
            let cell: CSDateTimeCell = tableView.dequeueReusableCell(withIdentifier: "CSDateTimeCell", for: indexPath) as! CSDateTimeCell
            cell.label.text = fieldLayout.label?.localizedUppercase
            cell.value = record?.getDateTime(fieldLayout.name.platformCaseStringValue)
            cell.delegate = self
            return cell
        }
        else if fieldLayout.type == CSFieldType.Phone {
            let cell: CSPhoneCell = tableView.dequeueReusableCell(withIdentifier: "CSPhoneCell", for: indexPath) as! CSPhoneCell
            cell.label.text = fieldLayout.label?.localizedUppercase
            cell.value = record?.getString(fieldLayout.name.platformCaseStringValue)
            cell.length = fieldLayout.length ?? 15
            cell.delegate = self
            return cell
        }
        else if fieldLayout.type == CSFieldType.Email {
            let cell: CSEmailCell = tableView.dequeueReusableCell(withIdentifier: "CSEmailCell", for: indexPath) as! CSEmailCell
            cell.label.text = fieldLayout.label?.localizedUppercase
            cell.value = record?.getString(fieldLayout.name.platformCaseStringValue)
            cell.length = fieldLayout.length ?? 40
            cell.delegate = self
            return cell
        }
        else if fieldLayout.type == CSFieldType.Url {
            let cell: CSUrlCell = tableView.dequeueReusableCell(withIdentifier: "CSUrlCell", for: indexPath) as! CSUrlCell
            cell.label.text = fieldLayout.label?.localizedUppercase
            cell.value = record?.getString(fieldLayout.name.platformCaseStringValue)
            cell.delegate = self
            return cell
        }
        else if fieldLayout.type == CSFieldType.Address {
            let cell: CSAddressCell = tableView.dequeueReusableCell(withIdentifier: "CSAddressCell", for: indexPath) as! CSAddressCell
            cell.label?.text = fieldLayout.label?.localizedUppercase
            cell.value = record?.getAddress(fieldLayout.name.platformCaseStringValue)
            cell.countryPickListValues = fieldLayout.countryOptions
            cell.statePickListValues = fieldLayout.stateOptions
            cell.delegate = self
            return cell
        }
        else if fieldLayout.type == CSFieldType.Location {
            let cell: CSGeolocationCell = tableView.dequeueReusableCell(withIdentifier: "CSGeolocationCell", for: indexPath) as! CSGeolocationCell
            cell.label?.text = fieldLayout.label?.localizedUppercase
            cell.value = record?.getGeolocation(fieldLayout.name.platformCaseStringValue)
            cell.delegate = self
            return cell
        }
        if fieldLayout.type == CSFieldType.Reference && settings.object(fieldLayout.referenceTo ?? "") != nil {
            let cell: CSReferenceCell = tableView.dequeueReusableCell(withIdentifier: "CSReferenceCell", for: indexPath) as! CSReferenceCell
            cell.label.text = fieldLayout.label?.localizedUppercase
            if let relationshipName: String = fieldLayout.relationshipName {
                cell.value = record?.getReference(relationshipName.platformCaseStringValue)
            }
            cell.referenceTo = fieldLayout.referenceTo
            cell.relationshipName = fieldLayout.relationshipName?.platformCaseStringValue
            cell.relationshipField = fieldLayout.relationshipField?.platformCaseStringValue
            cell.delegate = self
            return cell
        }
        else {
            let cell: CSFieldCell = tableView.dequeueReusableCell(withIdentifier: "CSFieldCell", for: indexPath) as! CSFieldCell
            cell.label.text = fieldLayout.label?.localizedUppercase
            cell.delegate = self
            return cell
        }
    }
    
    open func applyTheme(_ theme: CSTheme) {
        self.theme = theme
        view.backgroundColor = theme.backgroundColor
        emptyView.font = theme.headingFont
        emptyView.textColor = theme.textColor
        emptyView.backgroundColor = theme.backgroundColor
        tableView?.backgroundColor = theme.backgroundColor
        tableView?.separatorColor = theme.separatorColor
        tableView?.reloadData()
    }
    
    open func settingsDidChange(_ notification: Notification) {
        if let settings: CSSettings = notification.object as? CSSettings {
            self.settings = settings
            updateNavigationItem()
        }
    }
    
    internal func updateNavigationItem() {
        if let record: CSRecord = record, let recordTypeName: String = pageLayout?.recordTypeName {
            if recordTypeName.uppercased() != "MASTER" {
                navigationItem.title = recordTypeName.localizedUppercase
            }
            else {
                navigationItem.title = settings.object(record.objectType)?.label?.localizedUppercase
            }
        }
    }
    
    internal func keyboardDidChangeFrame(_ notification: Notification) {
        if let tableView: UITableView = tableView, let activeCell: CSFieldCell = activeCell {
            if let size: CGSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size {
                if view.frame.size.height - size.height < activeCell.frame.origin.y + activeCell.frame.height - tableView.contentOffset.y  {
                    edgeInsets = tableView.contentInset
                    tableView.contentInset = UIEdgeInsetsMake(0, 0, size.height, 0)
                    tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, size.height, 0)
                    let point: CGPoint = CGPoint(x: 0, y: activeCell.frame.origin.y - size.height)
                    tableView.setContentOffset(point, animated: true)
                }
            }
        }
    }
    
    internal func keyboardWillHide(_ notification: Notification) {
        if let edgeInsets: UIEdgeInsets = edgeInsets {
            tableView?.contentInset = edgeInsets
            tableView?.scrollIndicatorInsets = edgeInsets
        }
        activeCell = nil
    }
    
    fileprivate func initEmptyView() -> UILabel {
        let label: UILabel = UILabel()
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        label.text = "Detail Unavailable"
        return label
    }
    
    fileprivate func initActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.center = view.center
        return activityIndicatorView
    }
    
    fileprivate func salutationPickListValues(_ field: String) -> [CSPickListValue]? {
        for layoutSection: CSLayoutSection in pageLayout?.editLayoutSections ?? [] {
            for layoutRow: CSLayoutRow in layoutSection.layoutRows {
                for layoutItem: CSLayoutItem in layoutRow.layoutItems {
                    for layoutComponent: CSLayoutComponent in layoutItem.layoutComponents {
                        if layoutComponent.value == field {
                            for layoutComponent: CSLayoutComponent in layoutComponent.layoutComponents {
                                return layoutComponent.detail?.pickListValues
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
    
    internal func shouldCreateOrUpdateRecord(_ record: CSRecord?) -> Bool {
        if let record = record, let response = pageLayout?.isValid(record: record) {
            if response.0 == false {
                if let alertController = response.1 {
                    navigationController?.present(alertController, animated: true, completion: nil)
                }
            } else {
                let response = isMissingRequiredFields(isCreate: true)
                if response.0 == true {
                    let alertController: UIAlertController = UIAlertController(title: SFLocalizedString("ERROR", ""), message: "\(SFLocalizedString("REQUIRED_FIELD_MISSING", "")) : \(response.1 ?? "")", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: SFLocalizedString("OK", ""), style: UIAlertActionStyle.cancel, handler: nil))
                    present(alertController, animated: true, completion: nil)
                } else { // Record is valid -> Save
                    return true
                }
            }
        }
        return false
    }
    
    open func isMissingRequiredFields(isCreate: Bool = false) -> (Bool, String?) {
        for fieldLayout: CSFieldLayout in pageLayout?.fieldLayouts ?? [] {
            if fieldLayout.isRequired && (isCreate || fieldLayout.isUpdateable) && (!isCreate || fieldLayout.isCreateable) {
                if fieldLayout.type == CSFieldType.String && fieldLayout.extraTypeInfo == CSExtraTypeInfo.PersonName {
                    if record?.getString(CSPersonName.Name.lastName.platformSpecificRawValue)?.isEmpty ?? true {
                        return (true, fieldLayout.label)
                    }
                }
                else if fieldLayout.type == CSFieldType.String && fieldLayout.extraTypeInfo == nil {
                    if record?.getString(fieldLayout.name.platformCaseStringValue)?.isEmpty ?? true {
                        return (true, fieldLayout.label)
                    }
                }
                else if fieldLayout.type == CSFieldType.Integer {
                    if record?.getInteger(fieldLayout.name.platformCaseStringValue) == nil {
                        return (true, fieldLayout.label)
                    }
                }
                else if fieldLayout.type == CSFieldType.Double {
                    if record?.getDouble(fieldLayout.name.platformCaseStringValue) == nil {
                        return (true, fieldLayout.label)
                    }
                }
                else if fieldLayout.type == CSFieldType.Percent {
                    if record?.getDouble(fieldLayout.name.platformCaseStringValue) == nil {
                        return (true, fieldLayout.label)
                    }
                }
                else if fieldLayout.type == CSFieldType.Currency {
                    if record?.getDouble(fieldLayout.name.platformCaseStringValue) == nil {
                        return (true, fieldLayout.label)
                    }
                }
                else if fieldLayout.type == CSFieldType.TextArea {
                    if record?.getString(fieldLayout.name.platformCaseStringValue)?.isEmpty ?? true {
                        return (true, fieldLayout.label)
                    }
                }
                else if fieldLayout.type == CSFieldType.PickList {
                    if record?.getString(fieldLayout.name.platformCaseStringValue)?.isEmpty ?? true {
                        return (true, fieldLayout.label)
                    }
                }
                else if fieldLayout.type == CSFieldType.Date {
                    if record?.getDate(fieldLayout.name.platformCaseStringValue) == nil {
                        return (true, fieldLayout.label)
                    }
                }
                else if fieldLayout.type == CSFieldType.DateTime {
                    if record?.getDateTime(fieldLayout.name.platformCaseStringValue) == nil {
                        return (true, fieldLayout.label)
                    }
                }
                else if fieldLayout.type == CSFieldType.Phone {
                    if record?.getString(fieldLayout.name.platformCaseStringValue)?.isEmpty ?? true {
                        return (true, fieldLayout.label)
                    }
                }
                else if fieldLayout.type == CSFieldType.Email {
                    if record?.getString(fieldLayout.name.platformCaseStringValue)?.isEmpty ?? true {
                        return (true, fieldLayout.label)
                    }
                }
                else if fieldLayout.type == CSFieldType.Address {
                    if record?.getAddress(fieldLayout.name.platformCaseStringValue) == nil {
                        return (true, fieldLayout.label)
                    }
                }
                else if fieldLayout.type == CSFieldType.Location {
                    if record?.getGeolocation(fieldLayout.name.platformCaseStringValue) == nil {
                        return (true, fieldLayout.label)
                    }
                }
                else if fieldLayout.type == CSFieldType.Reference {
                    if record?.getString(fieldLayout.name.platformCaseStringValue)?.isEmpty ?? true {
                        return (true, fieldLayout.label)
                    }
                }
            }
        }
        return (false, nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }
    
}

extension CSRecordViewController: CSFieldCellDelegate {
    public func valueDidChange(cell: CSFieldCell) {
        if let indexPath: IndexPath = tableView?.indexPath(for: cell) {
            if let fieldLayout: CSFieldLayout = pageLayout?.fieldLayouts[indexPath.row] {
                if let cell: CSStringCell = cell as? CSStringCell {
                    record?.setString(fieldLayout.name.platformCaseStringValue, value: cell.value)
                }
                else if let cell: CSIntegerCell = cell as? CSIntegerCell {
                    record?.setInteger(fieldLayout.name.platformCaseStringValue, value: cell.value)
                }
                else if let cell: CSDoubleCell = cell as? CSDoubleCell {
                    record?.setDouble(fieldLayout.name.platformCaseStringValue, value: cell.value)
                }
                else if let cell: CSCurrencyCell = cell as? CSCurrencyCell {
                    record?.setDouble(fieldLayout.name.platformCaseStringValue, value: cell.value)
                }
                else if let cell: CSPercentCell = cell as? CSPercentCell {
                    record?.setDouble(fieldLayout.name.platformCaseStringValue, value: cell.value)
                }
                else if let cell: CSBooleanCell = cell as? CSBooleanCell {
                    record?.setBoolean(fieldLayout.name.platformCaseStringValue, value: cell.value)
                }
                else if let cell: CSTextAreaCell = cell as? CSTextAreaCell {
                    record?.setString(fieldLayout.name.platformCaseStringValue, value: cell.value)
                }
                else if let cell: CSPickListCell = cell as? CSPickListCell {
                    record?.setString(fieldLayout.name.platformCaseStringValue, value: cell.value)
                }
                else if let cell: CSDateCell = cell as? CSDateCell {
                    record?.setDate(fieldLayout.name.platformCaseStringValue, value: cell.value as Date?)
                }
                else if let cell: CSDateTimeCell = cell as? CSDateTimeCell {
                    record?.setDateTime(fieldLayout.name.platformCaseStringValue, value: cell.value as Date?)
                }
                else if let cell: CSPhoneCell = cell as? CSPhoneCell {
                    record?.setString(fieldLayout.name.platformCaseStringValue, value: cell.value)
                }
                else if let cell: CSEmailCell = cell as? CSEmailCell {
                    record?.setString(fieldLayout.name.platformCaseStringValue, value: cell.value)
                }
                else if let cell: CSAddressCell = cell as? CSAddressCell,let streetField: String = fieldLayout.streetField, let cityField: String = fieldLayout.cityField, let stateCodeField: String = fieldLayout.stateCodeField, let postalCodeField: String = fieldLayout.postalCodeField, let countryCodeField: String = fieldLayout.countryCodeField {
                    record?.setAddress(fieldLayout.name.platformCaseStringValue, value: cell.value, streetField: streetField, cityField: cityField, stateCodeField: stateCodeField, postalCodeField: postalCodeField, countryCodeField: countryCodeField)
                }
                else if let cell: CSGeolocationCell = cell as? CSGeolocationCell {
                    record?.setGeolocation(fieldLayout.name.platformCaseStringValue, value: cell.value)
                }
                else if let cell: CSReferenceCell = cell as? CSReferenceCell, let relationshipName: String = cell.relationshipName  {
                    record?.setReference(fieldLayout.name.platformCaseStringValue, value: cell.value, relationshipName: relationshipName)
                }
                else if let cell: CSPersonNameCell = cell as? CSPersonNameCell {
                    record?.setString(CSPersonName.Name.salutation.platformSpecificRawValue, value: cell.value?.salutation)
                    record?.setString(CSPersonName.Name.firstName.platformSpecificRawValue, value: cell.value?.firstName)
                    record?.setString(CSPersonName.Name.lastName.platformSpecificRawValue, value: cell.value?.lastName)
                }
            }
        }
    }
}
