//
//  CSRecordListViewController.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/14/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import MUPullToRefresh

open class CSRecordListViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating {
    
    fileprivate let notificationCenter: NotificationCenter = NotificationCenter.default
    fileprivate let settingsDidChange: Selector = #selector(CSRecordListViewController.settingsDidChange(_:))
    
    open lazy var activityIndicatorView: UIActivityIndicatorView = self.initActivityIndicatorView()
    internal lazy var emptyView: UILabel = self.initEmptyView()
    open lazy var searchController: UISearchController = self.initSearchController()
    internal lazy var settings: CSSettings = CSSettingsStore.instance.read()
    
    open var objectType: String?
    open var pageLayout: CSPageLayout?
    open var records: [CSRecord] = []
    open var theme: CSTheme?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        notificationCenter.removeObserver(self, name: NSNotification.Name(rawValue: CSSettingsChangedNotification), object: nil)
        notificationCenter.addObserver(self, selector: settingsDidChange, name: NSNotification.Name(rawValue: CSSettingsChangedNotification), object: nil)
        let bundle: Bundle = Bundle(for: CSRecordListViewController.self)
        tableView.register(UINib(nibName: "CSRecordCell", bundle: bundle), forCellReuseIdentifier: "CSRecordCell")
        tableView.backgroundView = UIView()
        if tableView.tableFooterView == nil {
            tableView.tableFooterView = UIView()
        }
        if let objectType: String = objectType {
            navigationItem.title = settings.object(objectType)?.labelPlural?.localizedUppercase
        }
        if let theme: CSTheme = theme {
            applyTheme(theme)
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if records.count == 0 {
            activityIndicatorView.startAnimating()
            refresh()
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.mu_addPullToRefresh { (scrollView: UIScrollView?) in
            self.refresh()
        }
        tableView.mu_addInfiniteScrolling { (scrollView: UIScrollView?) in
            self.loadMore()
        }
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    open override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 101
    }
    
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let record: CSRecord = records[indexPath.row]
        let cell: CSRecordCell = tableView.dequeueReusableCell(withIdentifier: "CSRecordCell", for: indexPath) as! CSRecordCell
        if let pageLayout: CSPageLayout = pageLayout {
            cell.addLabelsForPageLayout(pageLayout: pageLayout, settings: settings, record: record)
        }
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let theme: CSTheme = theme, let cell: CSRecordCell = cell as? CSRecordCell {
            cell.applyTheme(theme: theme)
        }
    }
    
    open func didPresentSearchController(_ searchController: UISearchController) {
        refresh()
    }
    
    open func didDismissSearchController(_ searchController: UISearchController) {
        tableView.tableHeaderView = nil
        refresh()
    }
    
    open func updateSearchResults(for searchController: UISearchController) {
        refresh()
    }
    
    open func presentSearchController() {
        searchController.searchBar.becomeFirstResponder()
        searchController.isActive = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    open func loadPageLayout() {
        if let objectType: String = objectType {
            CSPageLayoutStore.instance.readAndSyncDown(objectType, recordTypeId: nil) { (pageLayout: CSPageLayout?, isSynced: Bool) in
                self.pageLayout = pageLayout
                self.tableView.reloadData()
                self.tableView.backgroundView = self.records.count == 0 ? self.emptyView : nil
                self.tableView.mu_endRefreshing()
                self.activityIndicatorView.stopAnimating()
            }
        }
        else {
            tableView.reloadData()
            tableView.backgroundView = records.count == 0 ? emptyView : nil
            tableView.mu_endRefreshing()
            activityIndicatorView.stopAnimating()
        }
    }
    
    open func refresh() {
        let text: String = searchController.searchBar.text ?? ""
        if searchController.isActive {
            searchRecords(text) { (records: [CSRecord], isSynced: Bool) in
                if self.searchController.isActive && self.searchController.searchBar.text == text {
                    self.records = records
                    self.loadPageLayout()
                }
            }
        }
        else {
            fetchRecords() { (records: [CSRecord], isSynced: Bool) in
                if self.searchController.isActive == false {
                    self.records = records
                    self.loadPageLayout()
                }
            }
        }
    }
    
    open func loadMore() {
        let text: String = searchController.searchBar.text ?? ""
        let values: [CSRecord] = records
        if searchController.isActive {
            searchRecords(text, offset: values.count) { (records: [CSRecord], isSynced: Bool) in
                if self.searchController.isActive && self.searchController.searchBar.text == text {
                    self.records = values + records
                    self.tableView.reloadData()
                    self.tableView.mu_endLoading()
                }
            }
        }
        else {
            fetchRecords(offset: values.count) { (records: [CSRecord], isSynced: Bool) in
                if self.searchController.isActive == false {
                    self.records = values + records
                    self.tableView.reloadData()
                    self.tableView.mu_endLoading()
                }
            }
        }
    }

    open func fetchRecords(offset: Int = 0, onCompletion: @escaping ([CSRecord], Bool) -> Void) {
        if let objectType: String = objectType {
            let recordStore: CSRecordStore = CSStoreManager.instance.retrieveStore(objectType)
            recordStore.readAndSyncDown(offset: offset) { (records: [CSRecord], isSynced: Bool) in
                onCompletion(records, isSynced)
            }
        }
    }
    
    open func searchRecords(_ text: String, offset: Int = 0, onCompletion: @escaping ([CSRecord], Bool) -> Void) {
        if let objectType: String = objectType {
            let recordStore: CSRecordStore = CSStoreManager.instance.retrieveStore(objectType)
            recordStore.searchAndSyncDown(text, offset: offset) { (records: [CSRecord], isSynced: Bool) in
                onCompletion(records, isSynced)
            }
        }
    }
    
    open func settingsDidChange(_ notification: Notification) {
        if let settings: CSSettings = notification.object as? CSSettings {
            self.settings = settings
            if let objectType: String = objectType, let object: CSObject = settings.object(objectType) {
                navigationItem.title = object.labelPlural?.localizedUppercase
            }
        }
    }
    
    open func applyTheme(_ theme: CSTheme) {
        self.theme = theme
        view.backgroundColor = theme.backgroundColor
        emptyView.font = theme.headingFont
        emptyView.textColor = theme.textColor
        emptyView.backgroundColor = theme.backgroundColor
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.separatorColor
        tableView.reloadData()
    }
    
    fileprivate func initEmptyView() -> UILabel {
        let label: UILabel = UILabel()
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        label.text = "No Results"
        return label
    }
    
    fileprivate func initActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.center = view.center
        return activityIndicatorView
    }
    
    fileprivate func initSearchController() -> UISearchController {
        let searchController: UISearchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        return searchController
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
}
