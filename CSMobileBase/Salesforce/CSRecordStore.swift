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

open class CSRecordStore: CSRecordStoreBase {

    private let parentString = "Parent"
    
    open func syncUp(_ target: SFSyncUpTarget? = nil, onCompletion completion: ((Bool) -> Void)? = nil) {
        
        let settings: CSSettings = CSSettingsStore.instance.read()

        let referencableObjects = CSStoreManager.instance.storeList + [parentString]
        let referenced: [(String, String, String)] = settings.object(objectType).map { $0.fields }!.filter { $0.type == CSFieldType.Reference && referencableObjects.contains($0.referenceTo ?? "") && $0.referenceTo != objectType }.map { ($0.referenceTo!, $0.relationshipName!, $0.name) }

        if referenced.count == 0 {
            doSyncUp(target, onCompletion: completion)
        }
        
        for (index, (var parentName, var relationshipName, var fieldName)) in referenced.enumerated() {
            if parentName != self.objectType {
                
                if relationshipName == parentString { // NOTES AND ATTACHMENTS
                    fieldName = "ParentId"
                    relationshipName = "Parent__r"
                    parentName = "fv_Visit__c" // HARD CODE FOR NOW - CAN ONLY BE ON VISITS
                }
                let parentRecordStore = CSStoreManager.instance.retrieveStore(parentName)
                
                parentRecordStore.syncUp(target) { success in
                    parentRecordStore.doSyncUp(target) { success in
                        
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
                }
            }
        }
    }

    private func doSyncUp(_ target: SFSyncUpTarget? = nil, onCompletion completion: ((Bool) -> Void)? = nil) {
        let updateBlock: SFSyncSyncManagerUpdateBlock = { [unowned self] (syncState: SFSyncState?) in
            if let syncState = syncState {
                if syncState.isDone() || syncState.hasFailed() {
                    self.semaphore.signal()
                    DispatchQueue.main.async {
                        if syncState.hasFailed() {
                            SFLogger.log(SFLogLevel.error, msg: "syncUp \(self.objectType) failed")
                        }
                        else {
                            self.expireStore()
                            SFLogger.log(SFLogLevel.debug, msg: "syncUp \(self.objectType) done")
                        }
                        CSStoreManager.instance.retrieveStore(self.objectType).objectObservable.onNext([])
                        completion?(syncState.hasFailed() == false)
                    }
                }
            }
        }
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            _ = self.semaphore.wait(timeout: DispatchTime.distantFuture)
            let options: SFSyncOptions = SFSyncOptions.newSyncOptions(forSyncUp: self.readFields.array)
            if let target: SFSyncUpTarget = target {
                self.smartSync.syncUp(with: target, options: options, soupName: self.objectType, update: updateBlock)
            }
            else {
                let target: CSSyncUpTarget = CSSyncUpTarget.newSyncTarget(self.objectType, createFields: self.createFields.set, updateFields: self.updateFields.set)
                self.smartSync.syncUp(with: target, options: options, soupName: self.objectType, update: updateBlock)
            }
        }
    }
    
    private func readLocallyCreated<R: CSRecord>(parent: String, fieldName: String) -> [R] {
        let query = "SELECT {\(objectType):_soup} FROM {\(objectType)}, {\(parent)} WHERE {\(objectType):\(fieldName)} = {\(parent):MobileExternalId__c}"
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

    open func createAndSyncUp(_ record: CSRecord, onCompletion completion: ((Void) -> Void)?) -> CSRecord {
        let refreshed: CSRecord = create(record)
        completion?()
        //child?.objectObservable.onNext([refreshed])
        syncUp() { (isSynced: Bool) in
            self.child?.objectObservable.onNext([refreshed])
        }
        return refreshed
    }
    
    open func updateAndSyncUp(_ record: CSRecord, onCompletion completion: ((Void) -> Void)?) -> CSRecord {
        let refreshed: CSRecord = update(record)
        //child?.objectObservable.onNext([record])
        completion?()
        syncUp() { (isSynced: Bool) in
            self.child?.objectObservable.onNext([record])
        }
        return refreshed
    }
    
    open func deleteAndSyncUp(_ record: CSRecord, onCompletion completion: ((Void) -> Void)? = nil) {
        delete(record)
        //child?.objectObservable.onNext([])
        completion?()
        syncUp() { (isSynced: Bool) in
            self.child?.objectObservable.onNext([])
        }
    }
    
    open func prefetch(_ beginDate: Date?, endDate: Date?, onCompletion: ((Bool) -> Void)?) {
        var queryParams: [String : String] = ["fields" : readFields.description]
        if let beginDate: String = dateFormatter.queryString(beginDate) {
            queryParams["beginDate"] = beginDate
        }
        if let endDate: String = dateFormatter.queryString(endDate) {
            queryParams["endDate"] = endDate
        }
        let path: String = "/\(SFRestAPI.sharedInstance().apiVersion)/prefetch/\(objectType.lowercased())"
        let target: ApexSyncDownTarget = ApexSyncDownTarget.newSyncTarget(path, queryParams: queryParams)
        target.endpoint = CSStoreManager.instance.endpoint
        
        let options: SFSyncOptions = SFSyncOptions.newSyncOptions(forSyncDown: SFSyncStateMergeMode.leaveIfChanged)
        smartSync.syncDown(with: target, options: options, soupName: objectType, update: { (syncState: SFSyncState?) in
            if let syncState = syncState {
                if syncState.isDone() || syncState.hasFailed() {
                    if syncState.hasFailed() {
                        SFLogger.log(SFLogLevel.error, msg: "prefetch \(self.objectType) failed")
                    }
                    else {
                        self.child?.objectObservable.onNext(self.read())
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

    open func readAndSyncDown<R: CSRecord>(_ record: R? = nil, offset: Int = 0, queryFilters: QueryBuilderBlock? = nil, onCompletion completion: @escaping RecordCompletionBlock<R>) {
        
        let recordId = record?.id
        
        var whereClause: String? = nil
        var query: CSQueryBuilder = CSQueryBuilder.forSoupName(objectType)
            
        if let recordId = recordId {
            query = query.whereEqual(CSRecord.Field.id.platformSpecificRawValue, value: recordId)
            whereClause = "\(CSRecord.Field.id.platformSpecificRawValue) = '\(recordId)'"
        } else {
           //flquery = query.whereNotNull(CSRecord.Field.id.platformSpecificRawValue)
        }
        if let queryFilters = queryFilters {
            query = queryFilters(query)
        }
        
        _ = read(query, onCompletion: completion)
        
        let soql: String = SFRestAPI.soqlQuery(withFields: readFields.array, sObject: objectType, whereClause: whereClause, groupBy: nil, having: nil, orderBy: nil, limit: NSInteger(limit))! + " offset \(offset)"
        let target: SFSyncDownTarget = SFSoqlSyncDownTarget.newSyncTarget(soql)

        syncDown(target) { (isSynced: Bool, timestamp: String) in
            if isSynced {
                self.cleanStore(query.buildCleanupForDate(timestamp), offset: offset)
            }
            //self.child?.objectObservable.onNext(self.read(query, onCompletion: completion))
            _ = self.read(query, onCompletion: completion)
        }
    }
    
    open func requestAndSyncDown<R: CSRecord>(path: String, queryParams: [AnyHashable: Any]?, onCompletion: @escaping ([R], Bool) -> Void) {
        let target: ApexSyncDownTarget = ApexSyncDownTarget.newSyncTarget(path, queryParams: queryParams)
        target.endpoint = "/services/data"
        
        syncDown(target) { (isSynced: Bool, timestamp: String) in
        }
    }

    open func requestAndSyncDownFileContentsFor(record: CSRecord, onCompletion: @escaping (Bool, String) -> Void) {
        let dictionary: [AnyHashable: Any] = [kCSRestSyncDownFileTargetId : record.id as Any]
        let target: CSRestSyncDownFileTarget = CSRestSyncDownFileTarget.newSyncTarget(dict: dictionary)
        
        syncDown(target) { (isSynced: Bool, timestamp: String) in
            //self.child?.objectObservable.onNext([record])
        }
    }
    
    open func searchAndSyncDown<R: CSRecord>(_ text: String, offset: Int = 0, onCompletion: @escaping ([R], Bool) -> Void) {
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
                    self.child?.objectObservable.onNext(records)
                    onCompletion(records, isSynced)
                }
            }
        }
        else {
            onCompletion([], false)
        }
    }
    
}
