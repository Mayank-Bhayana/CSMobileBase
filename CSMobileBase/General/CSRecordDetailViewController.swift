//
//  CSRecordDetailViewController.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/8/18.
//  Copyright © 2018 Textron Inc.. All rights reserved.
//

import Foundation
import MUPullToRefresh

open class CSRecordDetailViewController: CSRecordViewController {
    
    
    @IBOutlet weak var editBarButtonItem: UIBarButtonItem?

    open override func viewDidLoad() {
        super.viewDidLoad()
        if let editBarButtonItem = editBarButtonItem {
            if self.navigationItem.rightBarButtonItems?.count ?? 0 > 0 {
                navigationItem.rightBarButtonItems?.append(editBarButtonItem)
            } else {
                navigationItem.rightBarButtonItem = editBarButtonItem
            }
        }
    }
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? CSRecordUpdateViewController {
            destinationViewController.record = record
            destinationViewController.pageLayout = pageLayout
            destinationViewController.theme = theme
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicatorView.startAnimating()
        refresh()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView?.mu_addPullToRefresh { (scrollView: UIScrollView?) in
            self.refresh()
        }
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
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    open func refresh() {
        if let record: CSRecord = record {
            fetchRecord(record) { (record: CSRecord?, isSynced: Bool) in
                if record == self.record {
                    self.record = record
                    self.loadPageLayout()
                }
            }
        }
    }
    
    open func fetchRecord(_ record: CSRecord, onCompletion: @escaping (CSRecord?, Bool) -> Void) {
        let recordStore: CSRecordStore = CSStoreManager.instance.retrieveStore(record.objectType)
        recordStore.readAndSyncDown(record) { (record: [CSRecord], isSynced: Bool) in
            onCompletion(record.first, isSynced)
        }
    }
    
}
