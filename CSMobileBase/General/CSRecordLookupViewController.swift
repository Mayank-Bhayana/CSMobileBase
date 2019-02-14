//
//  CSRecordLookupViewController.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/20/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import UIKit

public protocol CSRecordLookupDelegate {
    func didSelectRecord(_ record: CSRecord)
}

open class CSRecordLookupViewController: CSRecordListViewController {
    
    open var delegate: CSRecordLookupDelegate?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        let bundle: Bundle = Bundle(for: CSRecordLookupViewController.self)
        tableView.register(UINib(nibName: "CSRecordLookupCell", bundle: bundle), forCellReuseIdentifier: "CSRecordLookupCell")
        if let objectType: String = objectType, settings.object(objectType)?.isSearchable == true {
            tableView.tableHeaderView = searchController.searchBar
        }
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let record: CSRecord = records[indexPath.row]
        let cell: CSRecordLookupCell = tableView.dequeueReusableCell(withIdentifier: "CSRecordLookupCell", for:indexPath) as! CSRecordLookupCell
        if let pageLayout: CSPageLayout = pageLayout {
            cell.addLabelsForPageLayout(pageLayout: pageLayout, settings: settings, record: record)
        }
        cell.delegate = self
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let theme: CSTheme = theme, let cell: CSRecordLookupCell = cell as? CSRecordLookupCell {
            cell.applyTheme(theme: theme)
        }
    }
    
    open override func didDismissSearchController(_ searchController: UISearchController) {
        refresh()
    }
    
    open override func settingsDidChange(_ notification: Notification) {
        super.settingsDidChange(notification)
        if let settings: CSSettings = notification.object as? CSSettings {
            self.settings = settings
            if let objectType: String = objectType, let object: CSObject = settings.object(objectType) {
                tableView.tableHeaderView = object.isSearchable ? searchController.searchBar : nil
            }
        }
    }
}

extension CSRecordLookupViewController: CSRecordLookupCellDelegate {
    public func onButtonTouched(cell: CSRecordLookupCell) {
        if let indexPath: IndexPath = tableView.indexPath(for: cell) {
            delegate?.didSelectRecord(records[indexPath.row])
        }
    }
}
