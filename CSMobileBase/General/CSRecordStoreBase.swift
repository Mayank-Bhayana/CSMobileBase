//
//  CSRecordStoreBase.swift
//  CSMobileBase
//
//  Created by Nicholas McDonald on 4/25/17.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import Foundation
import SmartStore
import SmartSync
import RxSwift

open class CSRecordStoreBase {
    
    public typealias RecordCompletionBlock<R> = ([R], Bool) -> Void
    public typealias QueryBuilderBlock = ((CSQueryBuilder) -> (CSQueryBuilder))
    
    public let dateFormatter: DateFormatter = DateFormatter()
    open let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    public final var smartSync: SFSmartSyncSyncManager {
        let store: SFSmartStore = smartStore
        return SFSmartSyncSyncManager.sharedInstance(for: store)!
    }
    
    public final var smartStore: SFSmartStore {
        let store: SFSmartStore = SFSmartStore.sharedStore(withName: kDefaultSmartStoreName) as! SFSmartStore
        SFSyncState.setupSyncsSoupIfNeeded(store)
        if store.soupExists(objectType) == false {
            do {
                let soupSpec: SFSoupSpec = SFSoupSpec.newSoupSpec(objectType, withFeatures: soupFeatures)
                let indexSpecs: [AnyObject] = SFSoupIndex.asArraySoupIndexes(indexes) as [AnyObject]
                try store.registerSoup(with: soupSpec, withIndexSpecs: indexSpecs)
            } catch let error as NSError {
                SFLogger.log(SFLogLevel.error, msg: "\(objectType) failed to register soup: \(error.localizedDescription)")
            }
        }
        return store
    }
    
    public func showInspector(_ inViewController:UIViewController) {
        let inspector = SFSmartStoreInspectorViewController(store: self.smartStore)
        inViewController.present(inspector!, animated: false, completion: nil)
    }
    
    open var objectType: String
    open var soupFeatures: [Any]
    open var limit: UInt { return 350 }
    open var objectObservable: BehaviorSubject<[CSRecord?]> = BehaviorSubject(value: [])
    
    open var indexes: [[String:String]] {
        let object: CSObject? = CSSettingsStore.instance.read().object(objectType)
        let nameField: String = object?.nameField ?? CSRecord.Field.id.platformSpecificRawValue
        var indexes: [[String:String]] = [["path" : CSRecord.Field.id.platformSpecificRawValue, "type" : kSoupIndexTypeString]]
        indexes.append(["path" : CSRecord.Field.externalId.platformSpecificRawValue, "type" : kSoupIndexTypeString])
        indexes.append(["path" : nameField, "type" : kSoupIndexTypeString])
        indexes.append(["path" : "__local__", "type" : kSoupIndexTypeInteger])
        indexes.append(["path" : "__locally_deleted__", "type" : kSoupIndexTypeInteger])
        indexes.append(["path" : "__locally_created__", "type" : kSoupIndexTypeInteger])
        for searchField: String in object?.searchFields ?? [] {
            indexes.append(["path" : searchField, "type" : kSoupIndexTypeFullText])
        }
        return indexes
    }
    
    lazy var child: CSRecordStore? = CSStoreManager.instance.retrieveStore(self.objectType)
    
    open var masters: [CSRecordStore] { return [] }
    
    open var readFields: CSFieldSet {
        if let object: CSObject = CSSettingsStore.instance.read().object(objectType) {
            return CSFieldSet.forRead()
                .withObject(object)
                .withField(CSRecord.Field.id.platformSpecificRawValue)
                .withField(CSRecord.Field.externalId.platformSpecificRawValue)
                .withField(object.nameField ?? CSRecord.Field.id.platformSpecificRawValue)
        }
        return CSFieldSet.forRead().withField(CSRecord.Field.id.platformSpecificRawValue)
    }
    
    open var writeFields: CSFieldSet {
        if let object: CSObject = CSSettingsStore.instance.read().object(objectType) {
            return CSFieldSet.forWrite()
                .withObject(object)
        }
        return CSFieldSet.forWrite()
    }
    
    open var createFields: CSFieldSet {
        if let object: CSObject = CSSettingsStore.instance.read().object(objectType) {
            return CSFieldSet.forCreate()
                .withObject(object)
        }
        return CSFieldSet.forCreate()
    }
    
    open var updateFields: CSFieldSet {
        if let object: CSObject = CSSettingsStore.instance.read().object(objectType) {
            return CSFieldSet.forUpdate()
                .withObject(object)
        }
        return CSFieldSet.forUpdate()
    }

    public func hasIndexSpecs(_ indexSpecs: [AnyObject]) -> Bool {
        if indexSpecs.count != smartStore.indices(forSoup: objectType).count {
            return false
        }
        var dictionary: [String : [String]] = [:]
        for index: AnyObject in smartStore.indices(forSoup: objectType) as [AnyObject] {
            if let soupIndex: SFSoupIndex = index as? SFSoupIndex {
                if dictionary[soupIndex.path] != nil {
                    dictionary[soupIndex.path]!.append(soupIndex.indexType)
                }
                else {
                    dictionary[soupIndex.path] = [soupIndex.indexType]
                }
            }
        }
        for index: AnyObject in indexSpecs {
            if let soupIndex: SFSoupIndex = index as? SFSoupIndex {
                if let indexTypes: [String] = dictionary[soupIndex.path] {
                    if indexTypes.contains(soupIndex.indexType) == false {
                        return false
                    }
                }
                else {
                    return false
                }
            }
        }
        return true
    }
    
    required public init(objectType: String) {
        self.objectType = objectType.platformCaseStringValue
        self.soupFeatures = []
    }
    
    open func indexStore() {
        if smartStore.soupExists(objectType) {
            let indexSpecs: [AnyObject] = SFSoupIndex.asArraySoupIndexes(indexes) as [AnyObject]
            if hasIndexSpecs(indexSpecs) == false {
                smartStore.alterSoup(objectType, withIndexSpecs: indexSpecs, reIndexData: true)
                SFLogger.log(SFLogLevel.debug, msg: "\(objectType) updating indices")
            }
        }
    }
    
    open func cleanStore(_ query: String, offset: Int = 0) {
        do {
            let querySpec: SFQuerySpec = SFQuerySpec.newSmartQuerySpec(query, withPageSize: limit)
            let pageIndex: UInt = UInt(ceil(Double(offset) / Double(limit)))
            let entries: [AnyObject] = try smartStore.query(with: querySpec, pageIndex: pageIndex) as [AnyObject]
            smartStore.removeEntries(entries, fromSoup: objectType)
        } catch let error as NSError {
            SFLogger.log(SFLogLevel.error, msg: "\(objectType) failed to clean store: \(error.localizedDescription)")
        }
    }
    
    open func expireStore() {
        do {
            let calendar: Calendar = Calendar.current
            let options: NSCalendar.Options = NSCalendar.Options(rawValue: 0)
            let date: Date = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: -14, to: Date(), options: options)!
            let timestamp: String = Int64(date.timeIntervalSince1970 * 1000).description
            let query: String = "SELECT {\(self.objectType):_soupEntryId} FROM {\(self.objectType)} WHERE {\(self.objectType):__local__} = 0 AND {\(self.objectType):_soupLastModifiedDate} < \(timestamp)"
            let querySpec: SFQuerySpec = SFQuerySpec.newSmartQuerySpec(query, withPageSize: 1000000)
            let entries: [AnyObject] = try smartStore.query(with: querySpec, pageIndex: 0) as [AnyObject]
            smartStore.removeEntries(entries, fromSoup: objectType)
        } catch let error as NSError {
            SFLogger.log(SFLogLevel.error, msg: "\(objectType) failed to expire store: \(error.localizedDescription)")
        }
    }
    
    open func queryStore<R: CSRecord>(_ query: String, offset: Int = 0) -> [R] {
        do {
            let querySpec: SFQuerySpec = SFQuerySpec.newSmartQuerySpec(query, withPageSize: limit)
            let pageIndex: UInt = UInt(ceil(Double(offset) / Double(limit)))
            let entries: [AnyObject] = try smartStore.query(with: querySpec, pageIndex: pageIndex) as [AnyObject]
            let dictionaries: [NSDictionary] = entries.map { return ($0 as! [NSDictionary])[0] }
            return dictionaries.map{ R(dictionary: $0) }
        } catch let error as NSError {
            SFLogger.log(SFLogLevel.error, msg: "\(objectType) failed to query store: \(error.localizedDescription)")
        }
        return []
    }
    
    open func queryStore(_ query: String) -> Int {
        do {
            let querySpec: SFQuerySpec = SFQuerySpec.newSmartQuerySpec(query, withPageSize: 1)
            let entries: [[Int]] = try smartStore.query(with: querySpec, pageIndex: 0) as! [[Int]]
            return entries.first?.first ?? 0
        } catch let error as NSError {
            SFLogger.log(SFLogLevel.error, msg: "\(objectType) failed to query store: \(error.localizedDescription)")
        }
        return 0
    }
    
    open func refresh<R: CSRecord>(_ record: R) -> R {
        let entry: [String : AnyObject] = record.toStoreEntry()
        if let soupEntryId: AnyObject = entry["_soupEntryId"] {
            let entries: [AnyObject] = smartStore.retrieveEntries([soupEntryId], fromSoup: objectType) as [AnyObject]
            if let dictionary: NSDictionary = entries.first as? NSDictionary {
                return R(dictionary: dictionary)
            }
        }
        return record
    }
    
    open func create<R: CSRecord>(_ record: R) -> R {
        record.setInteger("__local__", value: 1)
        record.setInteger("__locally_created__", value: 1)
        record.setInteger("__locally_updated__", value: 0)
        record.setInteger("__locally_deleted__", value: 0)
        let entries: [AnyObject] = smartStore.upsertEntries([record.toStoreEntry()], toSoup: objectType) as [AnyObject]
        if let dictionary: NSDictionary = entries.first as? NSDictionary {
            let record = R(dictionary: dictionary)
            child?.objectObservable.onNext([record])
            return record
        }
        child?.objectObservable.onNext([record])
        return record
    }
    
    open func update<R: CSRecord>(_ record: R) -> R {
        record.setInteger("__local__", value: 1)
//        record.setInteger("__locally_created__", value: 0)
        record.setInteger("__locally_updated__", value: 1)
        record.setInteger("__locally_deleted__", value: 0)
        let entries: [AnyObject] = smartStore.upsertEntries([record.toStoreEntry()], toSoup: objectType) as [AnyObject]
        if let dictionary: NSDictionary = entries.first as? NSDictionary {
            let record = R(dictionary: dictionary)
            child?.objectObservable.onNext([record])
            return record
        }
        return record
    }
    
    open func delete<R: CSRecord>(_ record: R) {
        record.setInteger("__local__", value: 1)
        record.setInteger("__locally_created__", value: 0)
        record.setInteger("__locally_updated__", value: 0)
        record.setInteger("__locally_deleted__", value: 1)
        smartStore.upsertEntries([record.toStoreEntry()], toSoup: objectType)
        child?.objectObservable.onNext([])
    }
    
    open func syncDown(_ target: SFSyncDownTarget, onCompletion: @escaping (Bool, String) -> Void) {
        let timestamp: String = Int64(Date().timeIntervalSince1970 * 1000).description
        let options: SFSyncOptions = SFSyncOptions.newSyncOptions(forSyncDown: SFSyncStateMergeMode.leaveIfChanged)
        smartSync.syncDown(with: target, options: options, soupName: objectType, update: { (syncState: SFSyncState?) in
            if let syncState = syncState {
                if syncState.isDone() || syncState.hasFailed() {
                    if syncState.hasFailed() {
                        SFLogger.log(SFLogLevel.error, msg: "syncDown \(self.objectType) failed")
                    }
                    else {
                        SFLogger.log(SFLogLevel.debug, msg: "syncDown \(self.objectType) returned \(syncState.totalSize)")
                    }
                    onCompletion(syncState.hasFailed() == false, timestamp)
                }
            }
        })
    }

    open func read<R: CSRecord>(_ queryFilters: @escaping (QueryBuilderBlock)) -> [R] {
        let records: [R] = read(queryFilters: queryFilters, offset: 0, onCompletion: nil)
        return records
    }
    
    open func read<R: CSRecord>(queryFilters: QueryBuilderBlock? = nil, offset: Int = 0, onCompletion completion: RecordCompletionBlock<R>? = nil) -> [R] {
        var query: CSQueryBuilder = CSQueryBuilder.forSoupName(objectType)
            //.whereNotNull(CSRecord.Field.id.platformSpecificRawValue)
        
        if let q = queryFilters {
            query = q(query)
        }
        return read(query, offset: offset, onCompletion: completion)
    }
    
    open func read<R: CSRecord>(_ query: CSQueryBuilder, offset: Int = 0, onCompletion completion: RecordCompletionBlock<R>? = nil) -> [R] {
        let records: [R] = self.queryStore(query.buildRead(), offset: offset)
        DispatchQueue.main.async {
            completion?(records, true)
        }
        return records
    }
    
    
}
