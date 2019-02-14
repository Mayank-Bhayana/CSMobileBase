//
//  CSStoreFactory.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 10/01/19.
//


import Foundation

open class CSStoreFactory: NSObject {
    
    open static let instance: CSStoreFactory = CSStoreFactory()
    
    fileprivate let settingsDidChange: Selector = #selector(CSStoreFactory.settingsDidChange(_:))
    
    fileprivate var stores: [String : CSRecordStore]
    
    fileprivate override init() {
        self.stores = [:]
    }
    
    open func retrieveStore(_ objectType: String) -> CSRecordStore {
        if let recordStore: CSRecordStore = stores[objectType] {
            return recordStore
        }
        return CSRecordStore(objectType: objectType)
    }
    
    open func registerStore(_ recordStore: CSRecordStore) {
        stores[recordStore.objectType] = recordStore
    }
    
    open func syncUp() {
        for recordStore: CSRecordStore in stores.values {
            recordStore.syncUp(onCompletion: nil)
        }
    }
    
    func settingsDidChange(_ notification: Notification) {
        if let settings: CSSettings = notification.object as? CSSettings {
            for objectType: String in settings.objectTypes {
                retrieveStore(objectType).indexStore()
            }
        }
    }
    
}

