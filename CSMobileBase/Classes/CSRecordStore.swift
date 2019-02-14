//
//  CSRecordStore.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 10/01/19.
//


import Foundation
import SmartStore
import SmartSync

open class CSRecordStore{
    static var NumberOfCallsToSetVisible:NSInteger = 0
    fileprivate let endpoint: String = Bundle.main.object(forInfoDictionaryKey: "SFDCEndpoint") as! String
    fileprivate let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    fileprivate var dontenter = false
    
    
    fileprivate var smartStore: SFSmartStore {
        let store: SFSmartStore = SFSmartStore.sharedStore(withName: kDefaultSmartStoreName) as! SFSmartStore
        SFSyncState.setupSyncsSoupIfNeeded(store)
        if store.soupExists(objectType) == false {
            do {
                let indexSpecs: [AnyObject] = SFSoupIndex.asArraySoupIndexes(indexes)! as [AnyObject]
                try store.registerSoup(objectType, withIndexSpecs: indexSpecs, error: ())
            } catch let error as NSError {
                SFLogger.log(SFLogLevel.error, msg: "\(objectType) failed to register soup: \(error.localizedDescription)")
            }
        }
        return store
    }
    open func setNetworkActivityIndicatorVisible(_ setVisible: Bool) -> Void {
        
        if (setVisible) {
            CSRecordStore.NumberOfCallsToSetVisible += 1
        } else {
            CSRecordStore.NumberOfCallsToSetVisible -= 1
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = CSRecordStore.NumberOfCallsToSetVisible > 0
        
    }
    
    
    fileprivate var syncManager: SFSmartSyncSyncManager {
        let store: SFSmartStore = smartStore
        let manager: SFSmartSyncSyncManager = SFSmartSyncSyncManager.sharedInstance(for: store)!
        return manager
    }
    
    lazy var notificationCenter: NotificationCenter = NotificationCenter.default
    lazy var dateFormatter: DateFormatter = DateFormatter()
    
    open var objectType: String
    open var limit: UInt { return 25 }
    
    open var indexes: [AnyObject] {
        let object: CSObject? = CSSettingsStore.instance.read().objectForObjectType(objectType)
        let nameField: String = object?.nameField ?? CSRecord.Field.id.rawValue
        //-----Fixed by Mayank-----//
        var indexes = [[String:AnyObject]]()
        // var indexes: [AnyObject] = []
        indexes.append(["path" : CSRecord.Field.id.rawValue as AnyObject, "type" : kSoupIndexTypeString as AnyObject])
        indexes.append(["path" : CSRecord.Field.mobileExternalId.rawValue as AnyObject, "type" : kSoupIndexTypeString as AnyObject])
        indexes.append(["path" : nameField as AnyObject, "type" : kSoupIndexTypeString as AnyObject])
        indexes.append(["path" : "__local__" as AnyObject, "type" : kSoupIndexTypeInteger as AnyObject])
        indexes.append(["path" : "__locally_deleted__" as AnyObject, "type" : kSoupIndexTypeInteger as AnyObject])
        for searchableField: String in object?.searchableFields ?? [] {
            indexes.append(["path" : searchableField as AnyObject, "type" : kSoupIndexTypeFullText as AnyObject])
        }
        return indexes as [AnyObject]
    }
    
    open var readFields: CSFieldSet {
        let settings: CSSettings = CSSettingsStore.instance.read()
        if let object: CSObject = settings.objectForObjectType(objectType) {
            return CSFieldSet.forRead()
                .withObject(object)
                .withField(CSRecord.Field.id.rawValue)
                .withField(object.nameField ?? CSRecord.Field.id.rawValue)
        }
        return CSFieldSet.forRead().withField(CSRecord.Field.id.rawValue)
    }
    
    open var writeFields: CSFieldSet {
        let settings: CSSettings = CSSettingsStore.instance.read()
        if let object: CSObject = settings.objectForObjectType(objectType) {
            return CSFieldSet.forWrite()
                .withObject(object)
        }
        return CSFieldSet.forWrite()
    }
    
    public init(objectType: String) {
        self.objectType = objectType
    }
    
    open func indexStore() {
        if smartStore.soupExists(objectType) {
            let indexSpecs: [AnyObject] = SFSoupIndex.asArraySoupIndexes(indexes)! as [AnyObject]
            do {
                try smartStore.alterSoup(objectType, withIndexSpecs: indexSpecs, reIndexData: false)
            } catch {
                print("Something went wrong!")
            }
            SFLogger.log(SFLogLevel.info, msg: "\(objectType) updated index specs")
        }
    }
    
    open func queryStore(_ query: String, offset: Int = 0) -> [CSRecord] {
        do {
            let querySpec: SFQuerySpec = SFQuerySpec.newSmartQuerySpec(query, withPageSize: limit)
            let pageIndex: UInt = UInt(ceil(Double(offset) / Double(limit)))
            let entries: [AnyObject] = try smartStore.query(with: querySpec, pageIndex: pageIndex) as [AnyObject]
            let dictionaries: [NSDictionary] = entries.map { return ($0 as! [NSDictionary])[0] }
            return CSRecord.fromStoreEntries(dictionaries)
        } catch let error as NSError {
            SFLogger.log(SFLogLevel.error, msg: "\(objectType) failed to query store: \(error.localizedDescription)")
        }
        return []
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
    
    open func refresh(_ record: CSRecord) -> CSRecord {
        let entry: [String : AnyObject] = record.toStoreEntry()
        if let soupEntryId: AnyObject = entry["_soupEntryId"] {
            let entries: [AnyObject] = smartStore.retrieveEntries([soupEntryId], fromSoup: objectType) as! [AnyObject]
            return CSRecord.fromStoreEntries(entries).first ?? record
        }
        return record
    }
    
    open func create(_ record: CSRecord) -> CSRecord {
        record.setInteger("__local__", value: 1)
        record.setInteger("__locally_created__", value: 1)
        record.setInteger("__locally_deleted__", value: 0)
        let entries: [AnyObject] = smartStore.upsertEntries([record.toStoreEntry()], toSoup: objectType) as! [AnyObject]
        return CSRecord.fromStoreEntries(entries).first!
    }
    
    open func update(_ record: CSRecord) -> CSRecord {
        record.setInteger("__local__", value: 1)
        record.setInteger("__locally_updated__", value: 1)
        let entries: [AnyObject] = smartStore.upsertEntries([record.toStoreEntry()], toSoup: objectType) as! [AnyObject]
        return CSRecord.fromStoreEntries(entries).first!
    }
    
    open func delete(_ record: CSRecord) {
        record.setInteger("__local__", value: 1)
        record.setInteger("__locally_created__", value: 0)
        record.setInteger("__locally_updated__", value: 0)
        record.setInteger("__locally_deleted__", value: 1)
        smartStore.upsertEntries([record.toStoreEntry()], toSoup: objectType)
    }
    
    open func syncDown(_ target: SFSyncDownTarget, onCompletion: @escaping (Bool, String) -> Void) {
        let timestamp: String = Int64(Date().timeIntervalSince1970 * 1000).description
        let options: SFSyncOptions = SFSyncOptions.newSyncOptions(forSyncDown: SFSyncStateMergeMode.leaveIfChanged)
        setNetworkActivityIndicatorVisible(true)
        syncManager.syncDown(with: target, options: options, soupName: objectType, update: { (syncState: SFSyncState!) in
            if syncState.isDone() || syncState.hasFailed() {
                DispatchQueue.main.async {
                    if syncState.hasFailed() {
                        SFLogger.log(SFLogLevel.error, msg: "syncDown \(self.objectType) failed")
                    }
                    else {
                        SFLogger.log(SFLogLevel.info, msg: "syncDown \(self.objectType) returned \(syncState.totalSize)")
                    }
                    onCompletion(syncState.hasFailed() == false, timestamp)
                    self.setNetworkActivityIndicatorVisible(false)
                }
            }
        })
    }
    
    open func syncUp(_ target: SFSyncUpTarget? = nil, onCompletion: ((Bool) -> Void)?) {
        setNetworkActivityIndicatorVisible(true)
        let updateBlock: SFSyncSyncManagerUpdateBlock = { (syncState: SFSyncState!) in
            if syncState.isDone() || syncState.hasFailed() {
                self.semaphore.signal()
                DispatchQueue.main.async {
                    if syncState.hasFailed() {
                        SFLogger.log(SFLogLevel.error, msg: "syncUp \(self.objectType) failed")
                    }
                    else {
                        self.expireStore()
                        SFLogger.log(SFLogLevel.info, msg: "syncUp \(self.objectType) done")
                    }
                    onCompletion?(syncState.hasFailed() == false)
                    self.setNetworkActivityIndicatorVisible(false)
                    
                }
            }
        }
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            self.semaphore.wait(timeout: DispatchTime.distantFuture)
            let options: SFSyncOptions = SFSyncOptions.newSyncOptions(forSyncUp: self.writeFields.array)
            if let target: SFSyncUpTarget = target {
                self.syncManager.syncUp(with: target, options: options, soupName: self.objectType, update: updateBlock)
            }
            else {
                self.syncManager.syncUp(with: options, soupName: self.objectType, update: updateBlock)
            }
        }
    }
    
    open func prefetch(_ beginDate: Date?, endDate: Date?, onCompletion: ((Bool) -> Void)?) {
        var queryParams: [String : String] = ["fields" : readFields.description]
        if let beginDate: String = dateFormatter.queryStringFromDateTime(beginDate) {
            queryParams["beginDate"] = beginDate
        }
        if let endDate: String = dateFormatter.queryStringFromDateTime(endDate) {
            queryParams["endDate"] = endDate
        }
        let path: String = "/\(SFRestAPI.sharedInstance().apiVersion)/prefetch/\(objectType.lowercased())"
        let target: ApexSyncDownTarget = ApexSyncDownTarget.newSyncTarget(path, queryParams: queryParams)
        target.endpoint = endpoint
        
        syncDown(target) { (succeeded: Bool, timestamp: String) in
            onCompletion?(succeeded)
        }
    }
    
    open func readAndSyncDown(_ id: String, onCompletion: @escaping (CSRecord?, Bool) -> Void) {
        if CSSettingsStore.instance.read().objectForObjectType(objectType) != nil {
            let query: CSQueryBuilder = CSQueryBuilder.forSoupName(objectType)
                .isEqual(CSRecord.Field.id.rawValue, value: id)
            onCompletion(queryStore(query.build()).first, true)
            
            let soql: String = SFRestAPI.soqlQuery(withFields: readFields.array, sObject: objectType, whereClause: "\(CSRecord.Field.id.rawValue) = '\(id)'", limit: NSInteger(limit))!
            let target: SFSyncDownTarget = SFSoqlSyncDownTarget.newSyncTarget(soql)
            
            syncDown(target) { (succeeded: Bool, timestamp: String) in
                if succeeded {
                    self.cleanStore(query.buildCleanupForDate(timestamp))
                }
                onCompletion(self.queryStore(query.build()).first, succeeded)
            }
        }
    }
    
    open func readAndSyncDown(_ record: CSRecord, onCompletion: @escaping (CSRecord?, Bool) -> Void) {
        if CSSettingsStore.instance.read().objectForObjectType(objectType) != nil {
            onCompletion(refresh(record), true)
            
            if let id: String = record.id {
                let soql: String = SFRestAPI.soqlQuery(withFields: readFields.array, sObject: objectType, whereClause: "\(CSRecord.Field.id.rawValue) = '\(id)'", limit: NSInteger(limit))!
                let target: SFSyncDownTarget = SFSoqlSyncDownTarget.newSyncTarget(soql)
                
                syncDown(target) { (succeeded: Bool, timestamp: String) in
                    let query: CSQueryBuilder = CSQueryBuilder.forSoupName(self.objectType)
                        .isEqual(CSRecord.Field.id.rawValue, value: id)
                    if succeeded {
                        self.cleanStore(query.buildCleanupForDate(timestamp))
                    }
                    onCompletion(self.queryStore(query.build()).first, succeeded)
                }
            }
        }
    }
    
    open func readAndSyncDown(offset: Int = 0, onCompletion: @escaping ([CSRecord], Bool) -> Void) {
        if let object: CSObject = CSSettingsStore.instance.read().objectForObjectType(objectType) {
            let nameField: String = object.nameField ?? CSRecord.Field.id.rawValue
            let query: CSQueryBuilder = CSQueryBuilder.forSoupName(objectType)
                .isNotNull(CSRecord.Field.id.rawValue)
                .orderByAscending(nameField)
            onCompletion(queryStore(query.build(), offset: offset), true)
            
            let soql: String = SFRestAPI.soqlQuery(withFields: readFields.array, sObject: objectType, whereClause: nil, groupBy: nil, having: nil, orderBy: [nameField], limit: NSInteger(limit))! + " offset \(offset)"
            let target: SFSyncDownTarget = SFSoqlSyncDownTarget.newSyncTarget(soql)
            
            syncDown(target) { (succeeded: Bool, timestamp: String) in
                if succeeded {
                    self.cleanStore(query.buildCleanupForDate(timestamp), offset: offset)
                }
                onCompletion(self.queryStore(query.build(), offset: offset), succeeded)
            }
        }
    }
    
    open func searchAndSyncDown(_ text: String, offset: Int = 0, onCompletion: @escaping ([CSRecord], Bool) -> Void) {
        if text.characters.count > 1, let object: CSObject = CSSettingsStore.instance.read().objectForObjectType(objectType) {
            let nameField: String = object.nameField ?? CSRecord.Field.id.rawValue
            let query: CSQueryBuilder = CSQueryBuilder.forSoupName(objectType)
                .orderByAscending(nameField)
            onCompletion(queryStore(query.buildSearchForText(text), offset: offset), true)
            
            let sosl: String = "FIND {\(text)*} IN ALL FIELDS RETURNING \(objectType)(\(readFields.description) LIMIT \(limit) OFFSET \(offset))"
            let target: SFSyncDownTarget = SFSoslSyncDownTarget.newSyncTarget(sosl)
            
            syncDown(target) { (succeeded: Bool, timestamp: String) in
                onCompletion(self.queryStore(query.buildSearchForText(text), offset: offset), succeeded)
            }
        }
        else {
            onCompletion([], false)
        }
    }
    
}

extension DateFormatter {
    
    func queryStringFromDateTime(_ date: Date?) -> String? {
        if let date: Date = date {
            timeZone = TimeZone(abbreviation: "GMT")
            dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            return string(from: date)
        }
        return nil
    }
    
}

