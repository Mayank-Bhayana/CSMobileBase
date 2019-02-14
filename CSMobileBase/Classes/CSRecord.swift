//
//  CSRecord.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 10/01/19.
//


import Foundation
import SwiftyJSON

open class CSRecord {
    
    public enum Field: String {
        case id = "Id"
        case recordTypeId = "RecordTypeId"
        case currencyIsoCode = "CurrencyIsoCode"
        case lastModifiedDate = "LastModifiedDate"
        case createdDate = "CreatedDate"
        case mobileExternalId = "FSO__MobileExternalId__c"
    }
    
    lazy var dateFormatter: DateFormatter = DateFormatter()
    
    open fileprivate(set) lazy var id: String? = self.getString(Field.id.rawValue)
    open fileprivate(set) lazy var createdDate: Date? = self.getDateTime(Field.createdDate.rawValue)
    open fileprivate(set) lazy var lastModifiedDate: Date? = self.getDateTime(Field.lastModifiedDate.rawValue)
    open fileprivate(set) lazy var mobileExternalId: String? = self.getString(Field.mobileExternalId.rawValue)
    open var objectType: String {
        get {
            if let attributes = self.getObject("attributes") {
                if let type: String =  attributes["type"]  as? String {
                    return type
                }
            }
            return "Unknown"
        }
    }
    
    open var recordTypeId: String? {
        get { return getString(Field.recordTypeId.rawValue) }
        set { setString(Field.recordTypeId.rawValue, value: newValue) }
    }
    
    open var currencyIsoCode: String? {
        get { return getString(Field.currencyIsoCode.rawValue) }
        set { setString(Field.currencyIsoCode.rawValue, value: newValue) }
    }
    
    open var json: JSON
    
    public required init(json: JSON) {
        self.json = json
    }
    
    public required init(objectType: String, json: JSON = JSON([:])) {
        self.json = json
        setObject("attributes", value: ["type" : objectType as AnyObject])
    }
    
    open func setString(_ name: String, value: String?) {
        if let value: String = value {
            json[name] = JSON(value)
        }
        else {
            json[name] = JSON.null
        }
    }
    
    open func setInteger(_ name: String, value: Int?) {
        if let value: Int = value {
            json[name] = JSON(value)
        }
        else {
            json[name] = JSON.null
        }
    }
    
    open func setDouble(_ name: String, value: Double?) {
        if let value: Double = value {
            json[name] = JSON(value)
        }
        else {
            json[name] = JSON.null
        }
    }
    
    open func setBoolean(_ name: String, value: Bool) {
        json[name] = JSON(value)
    }
    
    open func setDate(_ name: String, value: Date?) {
        if let value: Date = value {
            dateFormatter.timeZone = TimeZone.autoupdatingCurrent
            dateFormatter.dateFormat = "yyyy-MM-dd"
            json[name] = JSON(dateFormatter.string(from: value))
        }
        else {
            json[name] = JSON.null
        }
    }
    
    open func setDateTime(_ name: String, value: Date?) {
        if let value: Date = value {
            dateFormatter.timeZone = TimeZone.autoupdatingCurrent
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
            json[name] = JSON(dateFormatter.string(from: value))
        }
        else {
            json[name] = JSON.null
        }
    }
    
    open func setObject(_ name: String, value: [String : AnyObject]?) {
        if let value: [String : AnyObject] = value {
            json[name] = JSON(value)
        }
        else {
            json[name] = JSON.null
        }
    }
    
    open func setReference(_ name: String, relationshipName: String, value: CSRecord?) {
        if let value: CSRecord = value, let id: String = value.id {
            json[name] = JSON(id)
            json[relationshipName] = value.json
        }
        else {
            json[name] = JSON.null
            json[relationshipName] = JSON.null
        }
    }
    
    open func setAddress(_ name: String, value: Dictionary<String, String>) {
        if let value: Dictionary = value {
            for (key, keyValue) in value {
                json[name][key] = JSON(keyValue)
            }
        }
        else {
            json[name] = JSON.null
        }
    }
    
    open func getString(_ name: String) -> String? {
        return json[name].string
    }
    
    open func getMultiString(_ name: String) -> [String]? {
        
        //-----Fixed by Mayank-----//
        return (json[name].string?.characters.split{$0 == ";"}.map(String.init)) ?? nil
        
        
        //   return(json[name].string?.characters.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: <#T##Bool#>)
    }
    
    open func getBoolean(_ name: String) -> Bool {
        return json[name].boolValue
    }
    
    open func getInteger(_ name: String) -> Int? {
        return json[name].int
    }
    
    open func getDouble(_ name: String) -> Double? {
        return json[name].double
    }
    
    open func getDate(_ name: String) -> Date? {
        if let value: String = json[name].string {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.date(from: value)
        }
        return nil
    }
    
    open func getDateTime(_ name: String) -> Date? {
        if let value: String = json[name].string {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
            return dateFormatter.date(from: value)
        }
        return nil
    }
    
    open func getObject(_ name: String) -> [String : AnyObject]? {
        //Fixed by Mayank
        //  return json[name].dictionaryObject as! [String : AnyObject]
        return json[name].dictionaryObject! as [String : AnyObject]
    }
    
    open func getReference(_ name: String) -> CSRecord? {
        let value: JSON = json[name]
        if value.isEmpty {
            return nil
        }
        return CSRecord(json: value)
    }
    
    open func toStoreEntry() -> [String : AnyObject] {
        return json.dictionaryObject! as [String : AnyObject]
    }
    
    open func printToConsole() {
        print(json)
    }
    
    open static func fromStoreEntries(_ storeEntries: [AnyObject]) -> [CSRecord] {
        var array: [CSRecord] = []
        if let storeEntries: [NSDictionary] = storeEntries as? [NSDictionary] {
            for storeEntry: NSDictionary in storeEntries {
                array.append(CSRecord(json: JSON(storeEntry)))
            }
        }
        return array
    }
    
}

private extension Date {
    
    func toGMT() -> Date {
        let timeZone: TimeZone = TimeZone.autoupdatingCurrent
        let seconds: NSInteger = -timeZone.secondsFromGMT(for: self)
        return self.addingTimeInterval(TimeInterval(seconds))
    }
    
}

