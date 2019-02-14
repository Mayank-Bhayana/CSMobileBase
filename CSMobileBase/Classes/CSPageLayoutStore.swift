//
//  CSPageLayoutStore.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 10/01/19.
//


import Foundation
import SmartStore
import SmartSync

open class CSPageLayoutStore {
    
    open static let instance: CSPageLayoutStore = CSPageLayoutStore()
    
    fileprivate let endpoint: String =  "/services/apexrest" //NSBundle.mainBundle().objectForInfoDictionaryKey("SFDCEndpoint") as! String
    fileprivate let soupName: String = "PageLayout"
    
    fileprivate var smartStore: SFSmartStore {
        let store: SFSmartStore = SFSmartStore.sharedStore(withName: kDefaultSmartStoreName) as! SFSmartStore
        SFSyncState.setupSyncsSoupIfNeeded(store)
        if store.soupExists(soupName) == false {
            do {
                //-----Fixed by Mayank-----//
                var indexes = [[String:AnyObject]]()
                indexes = [
                    ["path" : CSPageLayout.Attribute.id.rawValue as AnyObject, "type" : kSoupIndexTypeString as AnyObject],
                    ["path" : CSPageLayout.Attribute.objectType.rawValue as AnyObject, "type" : kSoupIndexTypeString as AnyObject],
                    ["path" : CSPageLayout.Attribute.recordTypeId.rawValue as AnyObject, "type" : kSoupIndexTypeString as AnyObject]
                ]
                let indexSpecs: [AnyObject] = SFSoupIndex.asArraySoupIndexes(indexes)! as [AnyObject]
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
    
    fileprivate init() {}
    
    open func prefetch(onCompletion: ((Bool) -> Void)?) {
        let path: String = "/\(SFRestAPI.sharedInstance().apiVersion)/pageLayout"
        let target: ApexSyncDownTarget = ApexSyncDownTarget.newSyncTarget(path, queryParams: [:])
        target.endpoint = endpoint
        
        let options: SFSyncOptions = SFSyncOptions.newSyncOptions(forSyncDown: SFSyncStateMergeMode.overwrite)
        syncManager.syncDown(with: target, options: options, soupName: soupName) { (syncState: SFSyncState!) in
            if syncState.isDone() || syncState.hasFailed() {
                DispatchQueue.main.async() {
                    if syncState.hasFailed() {
                        SFLogger.log(SFLogLevel.error, msg: "syncDown PageLayout failed")
                    }
                    else {
                        SFLogger.log(SFLogLevel.info, msg: "syncDown PageLayout returned \(syncState.totalSize)")
                    }
                    onCompletion?(syncState.hasFailed() == false)
                }
            }
        }
    }
    
    open func readAndSyncDown(_ objectType: String, recordTypeId: String?, onCompletion: @escaping (CSPageLayout?, Bool) -> Void) {
        onCompletion(read(objectType, recordTypeId: recordTypeId), true)
        
        var queryParams: [String : String] = ["objectType" : objectType]
        if let recordTypeId: String = recordTypeId {
            queryParams["recordTypeId"] = recordTypeId
        }
        
        let path: String = "/\(SFRestAPI.sharedInstance().apiVersion)/pageLayout"
        let target: ApexSyncDownTarget = ApexSyncDownTarget.newSyncTarget(path, queryParams: queryParams)
        target.endpoint = endpoint
        
        let options: SFSyncOptions = SFSyncOptions.newSyncOptions(forSyncDown: SFSyncStateMergeMode.overwrite)
        syncManager.syncDown(with: target, options: options, soupName: soupName) { (syncState: SFSyncState!) in
            if syncState.isDone() || syncState.hasFailed() {
                DispatchQueue.main.async() {
                    if syncState.hasFailed() {
                        SFLogger.log(SFLogLevel.error, msg: "syncDown PageLayout objectType-\(objectType) recordTypeId-\(recordTypeId ?? "nil") failed")
                    }
                    else {
                        SFLogger.log(SFLogLevel.info, msg: "syncDown PageLayout objectType-\(objectType) recordTypeId-\(recordTypeId ?? "nil") returned \(syncState.totalSize)")
                    }
                    onCompletion(self.read(objectType, recordTypeId: recordTypeId), true)
                }
            }
        }
    }
    
    fileprivate func read(_ objectType: String, recordTypeId: String?) -> CSPageLayout? {
        do {
            if let recordTypeId: String = recordTypeId {
                let query: String = "SELECT {\(soupName):_soup} FROM {\(soupName)} WHERE {\(soupName):\(CSPageLayout.Attribute.objectType.rawValue)} = '\(objectType)' AND {\(soupName):\(CSPageLayout.Attribute.recordTypeId.rawValue)} = '\(recordTypeId)'"
                let querySpec: SFQuerySpec = SFQuerySpec.newSmartQuerySpec(query, withPageSize: 1)
                let entries: [AnyObject] = try smartStore.query(with: querySpec, pageIndex: 0) as [AnyObject]
                let dictionaries: [NSDictionary] = entries.map { return ($0 as! [NSDictionary])[0] }
                return CSPageLayout.fromStoreEntry(dictionaries.first)
            }
            else {
                let query: String = "SELECT {\(soupName):_soup} FROM {\(soupName)} WHERE {\(soupName):\(CSPageLayout.Attribute.objectType.rawValue)} = '\(objectType)' AND ({\(soupName):\(CSPageLayout.Attribute.recordTypeId.rawValue)} = '012000000000000AAA' OR {\(soupName):\(CSPageLayout.Attribute.recordTypeId.rawValue)} IS NULL)"
                let querySpec: SFQuerySpec = SFQuerySpec.newSmartQuerySpec(query, withPageSize: 1)
                let entries: [AnyObject] = try smartStore.query(with: querySpec, pageIndex: 0) as [AnyObject]
                let dictionaries: [NSDictionary] = entries.map { return ($0 as! [NSDictionary])[0] }
                return CSPageLayout.fromStoreEntry(dictionaries.first)
            }
        } catch let error as NSError {
            SFLogger.log(SFLogLevel.error, msg: "\(objectType) failed to query store: \(error.localizedDescription)")
            return nil
        }
    }
    
}

