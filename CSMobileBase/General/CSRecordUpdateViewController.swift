//
//  CSRecordUpdateViewController.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/19/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import MUPullToRefresh

public protocol CSRecordUpdateDelegate {
    func shouldRefreshRecord(_ record: CSRecord?) -> CSRecord?
    func shouldUpdateRecord(_ record: CSRecord?) -> Bool
    func updateRecord(_ record: CSRecord?)
}

open class CSRecordUpdateViewController: CSRecordViewController {
    
    open var delegate: CSRecordUpdateDelegate?
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem?

    open override func viewDidLoad() {
        super.viewDidLoad()
        updateNavigationItem()
        
        if let saveBarButtonItem = saveBarButtonItem {
            if self.navigationItem.rightBarButtonItems?.count ?? 0 > 0 {
                navigationItem.rightBarButtonItems?.append(saveBarButtonItem)
            } else {
                navigationItem.rightBarButtonItem = saveBarButtonItem
            }
        }
    }
    
    @IBAction open func onSaveTouched(_ sender: AnyObject) {
        view.endEditing(true)
        let record: CSRecord? = refreshAndUpdateFields()
        if (self.shouldCreateOrUpdateRecord(record) && delegate?.shouldUpdateRecord(record) ?? true ) {
            delegate?.updateRecord(record)
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView?.mu_addPullToRefresh { (scrollView: UIScrollView?) in
            self.loadPageLayout()
        }
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fieldLayout: CSFieldLayout = pageLayout!.fieldLayouts[indexPath.row]
        let cell: CSFieldCell = dequeueReusableFieldCell(fieldLayout, tableView: tableView, indexPath: indexPath)
        cell.isEditable = fieldLayout.isUpdateable
        cell.isRequired = fieldLayout.isRequired && fieldLayout.isUpdateable
        return cell
    }
    
    open func loadPageLayout() {
        if let record: CSRecord = record {
            CSPageLayoutStore.instance.readAndSyncDown(record.objectType, recordTypeId: record.recordTypeId) { (pageLayout: CSPageLayout?, isSynced: Bool) in
                if record == self.record {
                    self.pageLayout = pageLayout
                    self.updateNavigationItem()
                    self.tableView?.reloadData()
                    self.tableView?.backgroundView = pageLayout == nil ? self.emptyView : nil
                }
                self.tableView?.mu_endRefreshing()
            }
        }
    }
    
    open func refreshAndUpdateFields() -> CSRecord? {
        let refreshed: CSRecord? = delegate?.shouldRefreshRecord(self.record)
        if let fieldLayouts: [CSFieldLayout] = pageLayout?.fieldLayouts {
            for fieldLayout: CSFieldLayout in fieldLayouts {
                if fieldLayout.isUpdateable {
                    if fieldLayout.type == CSFieldType.String && fieldLayout.extraTypeInfo == CSExtraTypeInfo.PersonName {
                        let salutation: String? = record?.getString(CSPersonName.Name.salutation.platformSpecificRawValue)
                        refreshed?.setString(CSPersonName.Name.salutation.platformSpecificRawValue, value: salutation)
                        let firstName: String? = record?.getString(CSPersonName.Name.firstName.platformSpecificRawValue)
                        refreshed?.setString(CSPersonName.Name.firstName.platformSpecificRawValue, value: firstName)
                        let lastName: String? = record?.getString(CSPersonName.Name.lastName.platformSpecificRawValue)
                        refreshed?.setString(CSPersonName.Name.lastName.platformSpecificRawValue, value: lastName)
                    }
                    else if fieldLayout.type == CSFieldType.String && fieldLayout.extraTypeInfo == nil {
                        let string: String? = record?.getString(fieldLayout.name)
                        refreshed?.setString(fieldLayout.name, value: string)
                    }
                    else if fieldLayout.type == CSFieldType.Integer {
                        let integer: Int? = record?.getInteger(fieldLayout.name)
                        refreshed?.setInteger(fieldLayout.name, value: integer)
                    }
                    else if fieldLayout.type == CSFieldType.Double {
                        let double: Double? = record?.getDouble(fieldLayout.name)
                        refreshed?.setDouble(fieldLayout.name, value: double)
                    }
                    else if fieldLayout.type == CSFieldType.Percent {
                        let double: Double? = record?.getDouble(fieldLayout.name)
                        refreshed?.setDouble(fieldLayout.name, value: double)
                    }
                    else if fieldLayout.type == CSFieldType.Currency {
                        let double: Double? = record?.getDouble(fieldLayout.name)
                        refreshed?.setDouble(fieldLayout.name, value: double)
                    }
                    else if fieldLayout.type == CSFieldType.TextArea {
                        let string: String? = record?.getString(fieldLayout.name)
                        refreshed?.setString(fieldLayout.name, value: string)
                    }
                    else if fieldLayout.type == CSFieldType.PickList {
                        let string: String? = record?.getString(fieldLayout.name)
                        refreshed?.setString(fieldLayout.name, value: string)
                    }
                    else if fieldLayout.type == CSFieldType.Date {
                        let date: Date? = record?.getDate(fieldLayout.name)
                        refreshed?.setDate(fieldLayout.name, value: date)
                    }
                    else if fieldLayout.type == CSFieldType.DateTime {
                        let date: Date? = record?.getDateTime(fieldLayout.name)
                        refreshed?.setDateTime(fieldLayout.name, value: date)
                    }
                    else if fieldLayout.type == CSFieldType.Phone {
                        let string: String? = record?.getString(fieldLayout.name)
                        refreshed?.setString(fieldLayout.name, value: string)
                    }
                    else if fieldLayout.type == CSFieldType.Email {
                        let string: String? = record?.getString(fieldLayout.name)
                        refreshed?.setString(fieldLayout.name, value: string)
                    }
                    else if fieldLayout.type == CSFieldType.Address, let streetField: String = fieldLayout.streetField, let cityField: String = fieldLayout.cityField, let stateCodeField: String = fieldLayout.stateCodeField, let postalCodeField: String = fieldLayout.postalCodeField, let countryCodeField: String = fieldLayout.countryCodeField {
                        let address: CSAddress? = record?.getAddress(fieldLayout.name)
                        refreshed?.setAddress(fieldLayout.name, value: address, streetField: streetField, cityField: cityField, stateCodeField: stateCodeField, postalCodeField: postalCodeField, countryCodeField: countryCodeField)
                    }
                    else if fieldLayout.type == CSFieldType.Location {
                        let location: CSGeolocation? = record?.getGeolocation(fieldLayout.name)
                        refreshed?.setGeolocation(fieldLayout.name, value: location)
                    }
                    else if fieldLayout.type == CSFieldType.Reference, let relationshipName: String = fieldLayout.relationshipName {
                        let reference: CSRecord? = record?.getReference(relationshipName)
                        refreshed?.setReference(fieldLayout.name, value: reference, relationshipName: relationshipName)
                    }
                }
            }
        }
        return refreshed
    }
}
