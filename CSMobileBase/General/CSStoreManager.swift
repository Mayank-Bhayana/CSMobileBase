//
//  CCSStoreManager.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 6/28/18.
//  Copyright © 2018 Textron Inc.. All rights reserved.
//

import Foundation
import SmartStore
import ReachabilitySwift

open class CSStoreManager: NSObject {
    
    public static let instance: CSStoreManager = CSStoreManager()
    
    fileprivate let notificationCenter: NotificationCenter = NotificationCenter.default
    fileprivate let settingsDidChange: Selector = #selector(CSStoreManager.settingsDidChange(_:))
    
    let reachability = Reachability()!
    
    fileprivate var stores: [String : CSRecordStore] = [:]
    
    public var storeList: [String] {
        return stores.map { $0.key }
    }
    
    open var endpoint: String = "/services/apexrest/"
    
    fileprivate override init() {
        super.init()
        SalesforceSDKManager.setInstanceClass(SalesforceSDKManagerWithSmartStore.self)
        
        notificationCenter.addObserver(self, selector: settingsDidChange, name: NSNotification.Name(rawValue: CSSettingsChangedNotification), object: nil)
        
        reachability.whenReachable = { reachability in
            SFLogger.log(SFLogLevel.debug, msg: "Connection Status Changed")
            CSStoreManager.instance.syncUp()
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    open func registerStore(_ recordStore: CSRecordStore) {
        stores[recordStore.objectType] = recordStore
    }
    
    open func retrieveStore(_ objectType: String) -> CSRecordStore {
        if let recordStore: CSRecordStore = stores[objectType] {
            return recordStore
        }
        return CSRecordStore(objectType: objectType)
    }
    
    open func syncUp(onCompletion completion: ((Bool) -> Void)? = nil) {
        let values = self.stores.values
        let stores = Array(values)
        var syncUpSuccess = true
        
        if stores.count > 0 {
            func getStoreAndCallSyncUp(index:Int, syncCompletion: @escaping ((Void) -> Void)) -> Void {
                print("doing fetch for store index \(index)")
                let store = stores[index] as CSRecordStore
                store.syncUp { (success) in
                    print("fetch completed, calling next")
                    syncUpSuccess = syncUpSuccess && success
                    if index + 1 <= stores.count - 1 {
                        getStoreAndCallSyncUp(index: index + 1, syncCompletion: syncCompletion)
                    } else {
                        syncCompletion()
                    }
                }
            }
            
            getStoreAndCallSyncUp(index: 0) {
                if let c = completion {
                    print("fetching completed, success: \(syncUpSuccess)")
                    c(syncUpSuccess)
                }
            }
        }
    }
    
    internal func settingsDidChange(_ notification: Notification) {
        if let settings: CSSettings = notification.object as? CSSettings {
            for objectType: String in settings.objectTypes {
                retrieveStore(objectType).indexStore()
            }
        }
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
}
