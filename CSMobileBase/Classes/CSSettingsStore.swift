//
//  CSSettingsStore.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 10/01/19.
//



import Foundation
import SmartStore
import SwiftyJSON

public let CSSettingsChangedNotification = "CSSettingsChangedNotification"

open class CSSettingsStore {
    
    open static let instance: CSSettingsStore = CSSettingsStore()
    
    fileprivate let endpoint: String = Bundle.main.object(forInfoDictionaryKey: "SFDCEndpoint") as! String
    fileprivate let soupName: String = "Settings"
    
    lazy var notificationCenter: NotificationCenter = NotificationCenter.default
    lazy var dateFormatter: DateFormatter = DateFormatter()
    
    fileprivate var smartStore: SFSmartStore {
        let store: SFSmartStore = SFSmartStore.sharedStore(withName: kDefaultSmartStoreName) as! SFSmartStore
        SFSyncState.setupSyncsSoupIfNeeded(store)
        if store.soupExists(soupName) == false {
            do {
                //-----Fixed by Mayank-----//
                var indexes = [[String:AnyObject]]()
                indexes = [
                    ["path" : CSSettings.Attribute.id.rawValue as AnyObject, "type" : kSoupIndexTypeString as AnyObject]
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
    
    open func read<S: CSSettings>() -> S {
        do {
            let querySpec: SFQuerySpec = SFQuerySpec.newAllQuerySpec(soupName, withOrderPath: nil, with: SFSoupQuerySortOrder.descending, withPageSize: 1)
            let entry: AnyObject? = try smartStore.query(with: querySpec, pageIndex: 0).first as AnyObject
            return S.fromStoreEntry(entry)
        } catch let error as NSError {
            SFLogger.log(SFLogLevel.error, msg: error.localizedDescription)
        }
        return S(json: JSON.null)
    }
    
    open func syncDownSettings<S: CSSettings>(_ onCompletion: ((S, Bool) -> Void)?) {
        let path: String = "/\(SFRestAPI.sharedInstance().apiVersion)/settings"
        let target: ApexSyncDownTarget = ApexSyncDownTarget.newSyncTarget(path, queryParams: [:])
        target.endpoint = endpoint
        
        let options: SFSyncOptions = SFSyncOptions.newSyncOptions(forSyncDown: SFSyncStateMergeMode.overwrite)
        syncManager.syncDown(with: target, options: options, soupName: soupName) { (syncState: SFSyncState!) in
            if syncState.isDone() || syncState.hasFailed() {
                DispatchQueue.main.async {
                    if syncState.hasFailed() {
                        SFLogger.log(SFLogLevel.error, msg: "syncDown Settings failed")
                    }
                    let settings: S = self.read()
                    self.notificationCenter.post(name: Notification.Name(rawValue: CSSettingsChangedNotification), object: settings)
                    print(settings)
                    onCompletion?(settings, syncState.hasFailed() == false)
                }
            }
        }
    }
    
}
