//
//  CSRecordStore.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 6/28/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import SmartStore
import SmartSync
import RxSwift

open class CSRecordStore:CSRecordStoreBase {
    
    private let parentString = "parent"
    private lazy var settings: CSSettings = CSSettingsStore.instance.read()
    
    override open var readFields: CSFieldSet {
        return super.readFields
            .withField(CSRecord.Field.pgid.platformSpecificRawValue)
    }

    override open var indexes: [[String: String]] {
        return super.indexes + [
            ["path" : CSRecord.Field.pgid.platformSpecificRawValue, "type" : kSoupIndexTypeString]
        ]
    }

    internal func getReferencedObjects() -> [(String, String, String)] {
        let referencableObjects = CSStoreManager.instance.storeList + [parentString]

        let referenced: [(String, String, String)] = settings.object(objectType)
            .map { $0.fields }!
            .filter {$0.type == CSFieldType.Reference && referencableObjects.contains($0.referenceTo?.platformCaseStringValue ?? "") && $0.referenceTo?.platformCaseStringValue != objectType}
            .map { ($0.referenceTo!.platformCaseStringValue, $0.relationshipName!.platformCaseStringValue, $0.name.platformCaseStringValue) }
        return referenced
    }
    
    open func syncUp(_ target: SFSyncUpTarget? = nil, onCompletion completion: ((Bool) -> Void)? = nil) {
        
        let referenced = getReferencedObjects()
        
        if referenced.count == 0 {
            doSyncUp(target, onCompletion: completion)
        }
        
        for (index, (var parentName, var relationshipName, var fieldName)) in referenced.enumerated() {
            if parentName != self.objectType {
                
                if relationshipName == parentString { // NOTES AND ATTACHMENTS
                    fieldName = "parentId"
                    relationshipName = "parent__r"
                    parentName = "fv_visit__c" // HARD CODE FOR NOW - CAN ONLY BE ON VISITS
                }
                let parentRecordStore = CSStoreManager.instance.retrieveStore(parentName)
                
                parentRecordStore.syncUp(target) { syncUpsuccess in
                    if syncUpsuccess {
                        parentRecordStore.doSyncUp(target) { doSyncUpsuccess in
                            self.readLocallyCreated(parent: parentName, fieldName: fieldName).forEach { record in
                                let parentId = record.getString(fieldName)
                                if let newParent: CSRecord = parentRecordStore.read(forExternalId: parentId) {
                                    record.setReference(fieldName, value: newParent, relationshipName: relationshipName)
                                    _ = self.update(record)
                                }
                            }
                            if referenced.count - 1 == index {
                                self.doSyncUp(target, onCompletion: completion)
                            }
                        }
                    } else {
                        // parent sync up failed
                        if let c = completion {
                            c(false)
                        }
                    }
                }
            }
        }
    }
    
    open func doSyncUp(_ target: SFSyncUpTarget? = nil, onCompletion: ((Bool) -> Void)?) {
        let timestamp = NSDate().timeIntervalSince1970 - 1
        
        let updateBlock: SFSyncSyncManagerUpdateBlock = { (syncState: SFSyncState?) in
            if let syncState = syncState {
                if syncState.isDone() || syncState.hasFailed() {
                    self.semaphore.signal()
                    self.syncDown(timestamp:Int(timestamp), onCompletion: { (isSynced, time) in
                        DispatchQueue.main.async {
                            if syncState.hasFailed() {
                                SFLogger.log(SFLogLevel.error, msg: "syncUp \(self.objectType) failed")
                            }
                            else {
                                self.expireStore()
                                SFLogger.log(SFLogLevel.debug, msg: "syncUp \(self.objectType) done")
                            }
                            CSStoreManager.instance.retrieveStore(self.objectType).objectObservable.onNext([])
                            onCompletion?(syncState.hasFailed() == false && isSynced)
                        }
                    })
                }
            }
        }
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            self.semaphore.wait(timeout: DispatchTime.distantFuture)
            let options: SFSyncOptions = SFSyncOptions.newSyncOptions(forSyncUp: self.readFields.array)
            if let t = target {
                self.smartSync.syncUp(with: t, options: options, soupName: self.objectType, update: updateBlock)
            }
            else {
                let type = NSString(format:"salesforce.%@", self.objectType.lowercased()) as String
                let queryParams:Dictionary<String, AnyObject> = ["recordType":type as AnyObject]
                
                let params:Dictionary<String, AnyObject> = [HerokuTargetConstants.kHerokuSyncTargetQueryParams: queryParams as AnyObject]
                let target = HerokuSFSyncUpTarget(dict:params)
                self.smartSync.syncUp(with: target, options: options, soupName: self.objectType, update: updateBlock)
            }
        }
    }
    
    private func readLocallyCreated<R: CSRecord>(parent: String, fieldName: String) -> [R] {
        let query = "SELECT {\(objectType.platformCaseStringValue):_soup} FROM {\(objectType.platformCaseStringValue)}, {\(parent.platformCaseStringValue)} WHERE {\(objectType.platformCaseStringValue):\(fieldName.platformCaseStringValue)} = {\(parent.platformCaseStringValue):mobileexternalid__c}"
        let records: [R] = self.queryStore(query, offset: 0)
        
        return records
    }
    
    public func read(forExternalId externalID: String?) -> CSRecord? {
        guard externalID != nil else { return nil }
        var query: CSQueryBuilder = CSQueryBuilder.forSoupName(objectType)
        query = query.whereEqual(CSRecord.Field.externalId.platformSpecificRawValue, value: externalID!)
        return read(query).first
    }
    
    public func refresh(record record: CSRecord?) -> CSRecord? {
        guard record != nil && record?.id != nil else { return nil }
        var query: CSQueryBuilder = CSQueryBuilder.forSoupName(objectType)
            .whereEqual(CSRecord.Field.id.platformSpecificRawValue, value: record!.id!)
        if let externalId = record?.externalId {
            query = query.or()
                .whereEqual(CSRecord.Field.externalId.platformSpecificRawValue, value: externalId)
        }
        return read(query).first
    }
    
    open func createAndSyncUp(_ record: CSRecord, onCompletion: ((Void) -> Void)?) -> CSRecord {
        let refreshed: CSRecord = create(record)
//        self.objectObservable.onNext([refreshed])
        onCompletion?()
        
        let type = NSString(format:"salesforce.%@", objectType.lowercased()) as String
        var params:Dictionary<String, AnyObject> = ["Id":record.id as AnyObject]
        let queryParams:Dictionary<String, AnyObject> = ["recordType":type as AnyObject]
        
        params[HerokuTargetConstants.kHerokuSyncTargetQueryParams] = queryParams as AnyObject
        
        let target = HerokuSFSyncUpTarget(dict: params)
        
        self.syncUp(target) { (isSynced:Bool) in
            self.objectObservable.onNext([refreshed])
        }
        return refreshed
    }
    
    open func updateAndSyncUp(_ record: CSRecord, onCompletion: ((Void) -> Void)?) -> CSRecord {
        let refreshed: CSRecord = update(record)
        onCompletion?()
        
        let type = NSString(format:"salesforce.%@", objectType.lowercased()) as! String
        var params:Dictionary<String, AnyObject> = ["Id":record.id as AnyObject]
        let queryParams:Dictionary<String, AnyObject> = ["recordType":type as AnyObject]
        params[HerokuTargetConstants.kHerokuSyncTargetQueryParams] = queryParams as! AnyObject
        
        let target = HerokuSFSyncUpTarget(dict: params)
        self.syncUp(target) { (isSynced: Bool) in
            self.objectObservable.onNext([record])
        }
        return refreshed
    }
    
    open func deleteAndSyncUp(_ record: CSRecord, onCompletion: ((Void) -> Void)? = nil) {
        self.delete(record)
        onCompletion?()
        
        let type = NSString(format:"salesforce.%@", objectType.lowercased()) as! String
        var params:Dictionary<String, AnyObject> = ["Id":record.id as AnyObject]
        let queryParams:Dictionary<String, AnyObject> = ["recordType":type as AnyObject]
        params[HerokuTargetConstants.kHerokuSyncTargetQueryParams] = queryParams as! AnyObject
        
        let target = HerokuSFSyncUpTarget(dict: params)
        self.syncUp(target) { (isSynced: Bool) in
            self.objectObservable.onNext([])
        }
    }
    
    open func prefetch(_ beginDate: Date?, endDate: Date?, onCompletion: ((Bool) -> Void)?) {
        
        var query: CSQueryBuilder = CSQueryBuilder.forSoupName(objectType)
        query = query.whereNotNull(CSRecord.Field.id.platformSpecificRawValue)
        
        let type = NSString(format:"salesforce.%@", objectType.lowercased()) as String
        let params:Dictionary<String, AnyObject> = ["recordType":type as AnyObject]
        let target = HerokuSFDBSyncDownTarget.newSyncTarget(path: nil, params: params)
        target.objectType = self.objectType
        let options: SFSyncOptions = SFSyncOptions.newSyncOptions(forSyncDown: SFSyncStateMergeMode.leaveIfChanged)
        smartSync.syncDown(with: target, options: options, soupName: objectType, update: { (syncState: SFSyncState?) in
            if let syncState = syncState {
                if syncState.isDone() || syncState.hasFailed() {
                    if syncState.hasFailed() {
                        SFLogger.log(SFLogLevel.error, msg: "prefetch \(self.objectType) failed")
                    }
                    else {
                        SFLogger.log(SFLogLevel.debug, msg: "prefetch \(self.objectType) returned \(syncState.totalSize)")
                    }
                    if let onCompletion: ((Bool) -> Void) = onCompletion {
                        DispatchQueue.main.async {
                            onCompletion(syncState.hasFailed() == false)
                        }
                    }
                }
            }
        })

    }
    
    open func readAndSyncDown<R: CSRecord>(_ record: R, offset: Int = 0, queryFilters: QueryBuilderBlock? = nil, onCompletion completion: @escaping RecordCompletionBlock<R>) {
        readAndSyncDown(record.id, offset: offset, queryFilters: queryFilters, onCompletion: completion)
    }
    
    open func readAndSyncDown<R: CSRecord>(_ recordId: String? = nil, offset: Int = 0, queryFilters: QueryBuilderBlock? = nil, onCompletion completion: @escaping RecordCompletionBlock<R>) {
        
        var whereClause: String? = nil
        var query: CSQueryBuilder = CSQueryBuilder.forSoupName(objectType)
        
        if let recordId = recordId {
            query = query.whereEqual(CSRecord.Field.id.platformSpecificRawValue, value: recordId)
            whereClause = "\(CSRecord.Field.id.platformSpecificRawValue) = '\(recordId)'"
        } else {
            query = query.whereNotNull(CSRecord.Field.id.platformSpecificRawValue)
        }
        if let queryFilters = queryFilters {
            query = queryFilters(query)
        }
        
        _ = read(query, onCompletion: completion)
        
//        let soql: String = SFRestAPI.soqlQuery(withFields: readFields.array, sObject: objectType, whereClause: nil, groupBy: nil, having: nil, orderBy: nil, limit: NSInteger(limit))! + " offset \(offset)"

        let type = NSString(format:"salesforce.%@", objectType.lowercased()) as String
        let params:Dictionary<String, AnyObject> = ["recordType":type as AnyObject]
        let target = HerokuSFDBSyncDownTarget.newSyncTarget(path: nil, params: params)
        target.objectType = self.objectType
        syncDown(target) { (isSynced: Bool, timestamp: String) in
            if isSynced {
                self.cleanStore(query.buildCleanupForDate(timestamp), offset: offset)
            }
            let records: [R] = self.queryStore(query.buildRead(), offset: offset)
            DispatchQueue.main.async {
                completion(records, isSynced)
                self.objectObservable.onNext(self.read(query, onCompletion: completion))
            }
        }
    }

    open func requestAndSyncDownFileContentsFor(record: CSRecord, onCompletion: @escaping (Bool, String) -> Void) {
        let dictionary = ["Id" : record.id]
        let target = HerokuRestSyncDownFileTarget.newSyncTarget(path: nil, params: dictionary as [String : AnyObject])
        
        syncDown(target) { (isSynced: Bool, timestamp: String) in
            self.objectObservable.onNext([record])
        }
    }
    
    open func searchAndSyncDown<R: CSRecord>(_ text: String, offset: Int = 0, onCompletion: @escaping ([R], Bool) -> Void) {
        print("error: not implemneted")
        let settings: CSSettings = CSSettingsStore.instance.read()
        if text.characters.count > 1, let object: CSObject = settings.object(objectType) {
            let nameField: String = object.nameField ?? CSRecord.Field.id.platformSpecificRawValue
            let query: CSQueryBuilder = CSQueryBuilder.forSoupName(objectType)
                .orderBy(nameField)
 
            let sosl: String = "FIND {\(text)*} IN ALL FIELDS RETURNING \(objectType)(\(readFields.description) LIMIT \(limit) OFFSET \(offset))"
            let target: SFSyncDownTarget = SFSoslSyncDownTarget.newSyncTarget(sosl)
            syncDown(target) { (isSynced: Bool, timestamp: String) in
                let records: [R] = self.queryStore(query.buildSearchForText(text), offset: offset)
                DispatchQueue.main.async {
                    self.objectObservable.onNext(records)
                    onCompletion(records, isSynced)
                }
            }
        }
        else {
            onCompletion([], false)
        }
    }
    
    private func syncDown(timestamp:Int, onCompletion: @escaping (Bool, String) -> Void) {
        let type = NSString(format:"salesforce.%@", objectType.lowercased()) as String
        let time = NSString(format:"%i", timestamp) as String
        let params:Dictionary<String, AnyObject> = ["recordType":type as AnyObject, "lastmodifieddate":time as AnyObject]
        let target = HerokuSFDBSyncDownTarget.newSyncTarget(path: nil, params: params)
        target.objectType = self.objectType
        self.syncDown(target, onCompletion: onCompletion)
    }
    
}
