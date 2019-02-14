//
//  CSRecordCreateViewController.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/22/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import UIKit

public protocol CSRecordCreateDelegate {
    func shouldCreateRecord(_ record: CSRecord?) -> Bool
    func createRecord(_ record: CSRecord?)
}

open class CSRecordCreateViewController: CSRecordViewController {
    
    open var delegate: CSRecordCreateDelegate?
    open var popoverBarButtonItem: UIBarButtonItem? = nil
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem?

    @IBAction open func onSaveTouched(_ sender: AnyObject) {
        view.endEditing(true)
        if (self.shouldCreateOrUpdateRecord(record) && delegate?.shouldCreateRecord(record) ?? true ) {
            delegate?.createRecord(record)
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        let recordTypes: [CSRecordType] = availableRecordTypes()
        if recordTypes.count > 1 {
            let alertController: UIAlertController = initAlertController(recordTypes)
            if let barButtonItem = popoverBarButtonItem {
                alertController.popoverPresentationController?.barButtonItem = barButtonItem
                present(alertController, animated: true, completion: nil)
            } else {
                alertController.popoverPresentationController?.sourceView = view
                alertController.popoverPresentationController?.sourceRect = view.frame
                present(alertController, animated: true, completion: nil)
            }
        }
        else {
            record?.recordTypeId = recordTypes.first?.id
            activityIndicatorView.startAnimating()
            loadPageLayout()
        }
        if let saveBarButtonItem = saveBarButtonItem {
            if self.navigationItem.rightBarButtonItems?.count ?? 0 > 0 {
                navigationItem.rightBarButtonItems?.append(saveBarButtonItem)
            } else {
                navigationItem.rightBarButtonItem = saveBarButtonItem
            }
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
        cell.isEditable = fieldLayout.isCreateable
        cell.isRequired = fieldLayout.isRequired && fieldLayout.isCreateable
        return cell
    }
    
    open func loadPageLayout() {
        if let record: CSRecord = record {
            CSPageLayoutStore.instance.readAndSyncDown(record.objectType, recordTypeId: record.recordTypeId) { (pageLayout: CSPageLayout?, isSynced: Bool) in
                self.pageLayout = pageLayout
                self.updateNavigationItem()
                self.applyDefaultValues()
                self.tableView?.reloadData()
                self.tableView?.backgroundView = pageLayout == nil ? self.emptyView : nil
                self.tableView?.mu_endRefreshing()
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    open func applyDefaultValues() {
        if let record: CSRecord = record, let fieldLayouts: [CSFieldLayout] =  pageLayout?.fieldLayouts {
            for fieldLayout: CSFieldLayout in fieldLayouts {
                if let defaultValue: String = fieldLayout.defaultValue  {
                    if fieldLayout.type == CSFieldType.PickList {
                        if record.getString(fieldLayout.name) == nil {
                            record.setString(fieldLayout.name, value: defaultValue)
                        }
                    }
                }
            }
            self.record = record
            self.tableView?.reloadData()
        }
    }
    
    fileprivate func initAlertController(_ recordTypes: [CSRecordType]) -> UIAlertController {
        let alertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        for recordType: CSRecordType in recordTypes {
            alertController.addAction(UIAlertAction(title: recordType.label, style: UIAlertActionStyle.default) { (alertAction: UIAlertAction) in
                self.record?.recordTypeId = recordType.id
                self.activityIndicatorView.startAnimating()
                self.loadPageLayout()
            })
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        return alertController
    }
    
    fileprivate func availableRecordTypes() -> [CSRecordType] {
        if let objectType: String = record?.objectType, let object: CSObject = settings.object(objectType) {
            return object.recordTypes.filter { $0.isAvailable }
        }
        return []
    }
    
}
