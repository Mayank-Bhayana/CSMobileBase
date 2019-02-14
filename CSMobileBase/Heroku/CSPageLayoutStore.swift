//
//  CSPageLayoutStore.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 6/28/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import SmartStore
import SmartSync

open class CSPageLayoutStore {
    
    open static let instance: CSPageLayoutStore = CSPageLayoutStore()
    
    fileprivate let soupName: String = "PageLayout"
    
    var endpoint: String = ""
    var host: String = "https://fieldvisit.herokuapp.com"
    
    fileprivate var smartStore: SFSmartStore {
        let store: SFSmartStore = SFSmartStore.sharedStore(withName: kDefaultSmartStoreName) as! SFSmartStore
        SFSyncState.setupSyncsSoupIfNeeded(store)
        if store.soupExists(soupName) == false {
            do {
                let indexes: [[String:String]] = [
                    ["path" : CSPageLayout.Name.id.platformSpecificRawValue, "type" : kSoupIndexTypeString],
                    ["path" : CSPageLayout.Name.objectType.platformSpecificRawValue, "type" : kSoupIndexTypeString],
                    ["path" : CSPageLayout.Name.recordTypeId.platformSpecificRawValue, "type" : kSoupIndexTypeString]
                ]
                let indexSpecs: [AnyObject] = SFSoupIndex.asArraySoupIndexes(indexes) as [AnyObject]
                try store.registerSoup(soupName, withIndexSpecs: indexSpecs, error: ())
            } catch let error as NSError {
                SFLogger.log(SFLogLevel.error, msg: "\(soupName) failed to register soup: \(error.localizedDescription)")
            }
        }
        return store
    }
    
    fileprivate var syncManager: SFSmartSyncSyncManager {
        let store: SFSmartStore = smartStore
        let manager: SFSmartSyncSyncManager = SFSmartSyncSyncManager.sharedInstance(for: store)!
        return manager
    }
    
    fileprivate var cache: [String : [String : CSPageLayout]] = [:]
    
    
    fileprivate init() {}
    
    open func prefetch(onCompletion: ((Bool) -> Void)?) {
//        let path: String = "/\(SFRestAPI.sharedInstance().apiVersion)/pageLayout"
//        let target: ApexSyncDownTarget = ApexSyncDownTarget.newSyncTarget(path, queryParams: [:])
//        target.endpoint = CSStoreManager.instance.endpoint
        
        let path = "/magic/apex/apex"
        let target:HerokuApexSyncDownTarget = HerokuApexSyncDownTarget.newSyncTarget(path: path, params: ["apexTarget":"pageLayout" as AnyObject])
        target.objectType = self.soupName.platformCaseStringValue
        target.endpoint = self.endpoint
        target.host = self.host
        
        let options: SFSyncOptions = SFSyncOptions.newSyncOptions(forSyncDown: SFSyncStateMergeMode.overwrite)
        syncManager.syncDown(with: target, options: options, soupName: soupName) { (syncState: SFSyncState?) in
            if let syncState = syncState {
                if syncState.isDone() || syncState.hasFailed() {
                    if syncState.hasFailed() {
                        SFLogger.log(SFLogLevel.error, msg: "syncDown PageLayout failed")
                    }
                    else {
                        SFLogger.log(SFLogLevel.debug, msg: "syncDown PageLayout returned \(syncState.totalSize)")
                    }
                    if let onCompletion: ((Bool) -> Void) = onCompletion {
                        DispatchQueue.main.async {
                            onCompletion(syncState.hasFailed() == false)
                        }
                    }
                }
            }
        }
    }
    
    open func readAndSyncDown(_ objectType: String, recordTypeId: String?, onCompletion: @escaping (CSPageLayout?, Bool) -> Void)  {
        let staleDate: Int64 = Int64(Date().timeIntervalSince1970 * 1000) - 60000
        if let pageLayout: CSPageLayout = readFromCache(objectType, recordTypeId: recordTypeId), pageLayout.soupLastModifiedDate > staleDate {
            onCompletion(pageLayout, true)
        }
        else {
            if let pageLayout: CSPageLayout = read(objectType, recordTypeId: recordTypeId) {
                writeToCache(objectType, pageLayout: pageLayout)
                onCompletion(pageLayout, true)
            }
            syncDown(objectType, recordTypeId: recordTypeId) { (pageLayout: CSPageLayout?, isSynced: Bool) in
                if let pageLayout: CSPageLayout = pageLayout {
                    self.writeToCache(objectType, pageLayout: pageLayout)
                }
                onCompletion(pageLayout, true)
            }
        }
    }
    
    fileprivate func read(_ objectType: String, recordTypeId: String?) -> CSPageLayout? {
        do {
            if let recordTypeId: String = recordTypeId {
                let query: String = "SELECT {\(soupName):_soup} FROM {\(soupName)} WHERE {\(soupName):\(CSPageLayout.Name.objectType.platformSpecificRawValue)} = '\(objectType)' AND {\(soupName):\(CSPageLayout.Name.recordTypeId.platformSpecificRawValue)} = '\(recordTypeId)'"
                let querySpec: SFQuerySpec = SFQuerySpec.newSmartQuerySpec(query, withPageSize: 1)
                let entries: [AnyObject] = try smartStore.query(with: querySpec, pageIndex: 0) as [AnyObject]
                let dictionaries: [NSDictionary] = entries.map { return ($0 as! [NSDictionary])[0] }
                if let dictionary: NSDictionary = dictionaries.first {
                    return CSPageLayout(dictionary: dictionary)
                }
            }
            else {
                let query: String = "SELECT {\(soupName):_soup} FROM {\(soupName)} WHERE {\(soupName):\(CSPageLayout.Name.objectType.platformSpecificRawValue)} = '\(objectType)' AND ({\(soupName):\(CSPageLayout.Name.recordTypeId.platformSpecificRawValue)} = '012000000000000AAA' OR {\(soupName):\(CSPageLayout.Name.recordTypeId.platformSpecificRawValue)} IS NULL)"
                let querySpec: SFQuerySpec = SFQuerySpec.newSmartQuerySpec(query, withPageSize: 1)
                let entries: [AnyObject] = try smartStore.query(with: querySpec, pageIndex: 0) as [AnyObject]
                let dictionaries: [NSDictionary] = entries.map { return ($0 as! [NSDictionary])[0] }
                if let dictionary: NSDictionary = dictionaries.first {
                    return CSPageLayout(dictionary: dictionary)
                }
            }
        } catch let error as NSError {
            SFLogger.log(SFLogLevel.error, msg: "\(objectType) failed to query store: \(error.localizedDescription)")
        }
        return nil
    }
    
    fileprivate func syncDown(_ objectType: String, recordTypeId: String?, onCompletion: @escaping (CSPageLayout?, Bool) -> Void) {
        var queryParams: [String : String] = ["objectType" : objectType]
        if let recordTypeId: String = recordTypeId {
            queryParams["recordTypeId"] = recordTypeId
        }
        let path: String = "/\(SFRestAPI.sharedInstance().apiVersion)/pageLayout"
        let target = HerokuApexSyncDownTarget.newSyncTarget(path: nil, params: ["apexTarget":"pageLayout" as AnyObject])
        
        // TODO FIX
//        let target: ApexSyncDownTarget = ApexSyncDownTarget.newSyncTarget(path, queryParams: queryParams)
//        target.endpoint = CSStoreManager.instance.endpoint
        let options: SFSyncOptions = SFSyncOptions.newSyncOptions(forSyncDown: SFSyncStateMergeMode.overwrite)
        syncManager.syncDown(with: target, options: options, soupName: soupName) { (syncState: SFSyncState?) in
            if let syncState = syncState {
                if syncState.isDone() || syncState.hasFailed() {
                    if syncState.hasFailed() {
                        SFLogger.log(SFLogLevel.error, msg: "syncDown PageLayout objectType-\(objectType) recordTypeId-\(recordTypeId ?? "nil") failed")
                    }
                    else {
                        SFLogger.log(SFLogLevel.debug, msg: "syncDown PageLayout objectType-\(objectType) recordTypeId-\(recordTypeId ?? "nil") returned \(syncState.totalSize)")
                    }
                    let pageLayout: CSPageLayout? = self.read(objectType, recordTypeId: recordTypeId)
                    DispatchQueue.main.async {
                        onCompletion(pageLayout, syncState.hasFailed() == false)
                        
                    }
                }
            }
        }
    }
    
    fileprivate func writeToCache(_ objectType: String, pageLayout: CSPageLayout) {
        if var map: [String : CSPageLayout] = cache[objectType] {
            map[pageLayout.recordTypeId ?? "012000000000000AAA"] = pageLayout
            cache[objectType] = map
        }
        else {
            cache[objectType] = [pageLayout.recordTypeId ?? "012000000000000AAA" : pageLayout]
        }
    }
    
    fileprivate func readFromCache(_ objectType: String, recordTypeId: String?) -> CSPageLayout? {
        if let pageLayout: CSPageLayout = cache[objectType]?[recordTypeId ?? "012000000000000AAA"] {
            return pageLayout
        }
        return nil
    }
    
}
