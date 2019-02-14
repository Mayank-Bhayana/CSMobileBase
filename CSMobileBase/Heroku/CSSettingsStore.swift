//
//  CSSettingsStore.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 6/28/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import SmartStore
import SmartSync
import SwiftyJSON
import RxSwift

public let CSSettingsChangedNotification = "CSSettingsChangedNotification"

public class CSSettingsStore:NSObject, CSSettingsStoreProtocol {
    fileprivate(set) open var settingsObservable: BehaviorSubject<CSSettings?> = BehaviorSubject(value: nil)

    fileprivate static let singleton: CSSettingsStore = CSSettingsStore()
    
    fileprivate override init() {}
    
    public static var instance:CSSettingsStoreProtocol {
        return CSSettingsStore.singleton
    }
    
    open let notificationCenter: NotificationCenter = NotificationCenter.default
    open let dateFormatter: DateFormatter = DateFormatter()
    open let soupName: String = "Settings".platformCaseStringValue
    
    open var smartStore: SFSmartStore {
        let store: SFSmartStore = SFSmartStore.sharedStore(withName: kDefaultSmartStoreName) as! SFSmartStore
        SFSyncState.setupSyncsSoupIfNeeded(store)
        if store.soupExists(soupName) == false {
            do {
                let indexes: [[String:String]] = [
                    ["path" : CSRecord.Field.id.platformSpecificRawValue, "type" : kSoupIndexTypeString]
                ]
                let indexSpecs: [AnyObject] = SFSoupIndex.asArraySoupIndexes(indexes) as [AnyObject]
                try store.registerSoup(soupName, withIndexSpecs: indexSpecs, error: ())
            } catch let error as NSError {
                SFLogger.log(SFLogLevel.error, msg: "\(soupName) failed to register soup: \(error.localizedDescription)")
            }
        }
        return store
    }
    
    open var syncManager: SFSmartSyncSyncManager {
        let store: SFSmartStore = smartStore
        let manager: SFSmartSyncSyncManager = SFSmartSyncSyncManager.sharedInstance(for: store)!
        return manager
    }
    
    open func read<S: CSSettings>() -> S {
        do {
            let querySpec: SFQuerySpec = SFQuerySpec.newAllQuerySpec(soupName, withOrderPath: nil, with: SFSoupQuerySortOrder.descending, withPageSize: 1)
            let entry: AnyObject? = try smartStore.query(with: querySpec, pageIndex: 0).first as AnyObject?
            return S.fromStoreEntry(entry)
        } catch let error as NSError {
            SFLogger.log(SFLogLevel.error, msg: error.localizedDescription)
        }
        return S(json: JSON.null)
    }
    
    open func syncDownSettings<S: CSSettings>(_ onCompletion: ((S, Bool) -> Void)?) {
        let target:HerokuApexSyncDownTarget = HerokuApexSyncDownTarget.newSyncTarget(path: nil, params: ["apexTarget":"settings" as AnyObject])
        target.objectType = self.soupName.platformCaseStringValue
        self.syncDownTarget(target, completion: onCompletion)
    }
    
    public func syncDownTarget<S: CSSettings>(_ target:SFSyncDownTarget, completion: ((S, Bool) -> Void)?) {
        let options: SFSyncOptions = SFSyncOptions.newSyncOptions(forSyncDown: SFSyncStateMergeMode.overwrite)
        syncManager.syncDown(with: target, options: options, soupName: soupName) { (syncState: SFSyncState?) in
            if let syncState = syncState {
                if syncState.isDone() || syncState.hasFailed() {
                    DispatchQueue.main.async {
                        if syncState.hasFailed() {
                            SFLogger.log(SFLogLevel.error, msg: "syncDown Settings failed")
                        }
                        let settings: S = self.read()
                        self.notificationCenter.post(name: Notification.Name(rawValue: CSSettingsChangedNotification), object: settings)
                        self.settingsObservable.onNext(settings)
                        completion?(settings, syncState.hasFailed() == false)
                    }
                }
            }
        }
    }
}
