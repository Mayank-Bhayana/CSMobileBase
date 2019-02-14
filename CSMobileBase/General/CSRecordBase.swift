//
//  CSRecord.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 6/24/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift
import CoreLocation

open class CSRecordBase: Equatable {
    
    public enum Field: String {
        case id = "Id"
        case externalId = "MobileExternalId__c"
        case recordTypeId = "RecordTypeId"
        case currencyIsoCode = "CurrencyIsoCode"
        case createdDate = "CreatedDate"
        case lastModifiedDate = "LastModifiedDate"
        case name = "Name"
    }
    
    internal lazy var dateFormatter: DateFormatter = DateFormatter()
    
    open var objectType: String { return self.json.value["attributes"]["type"].stringValue }
    
    open fileprivate(set) lazy var id: String? = self.getString(Field.id.platformSpecificRawValue)
    open fileprivate(set) lazy var externalId: String? = self.getString(Field.externalId.platformSpecificRawValue)
    open fileprivate(set) lazy var createdDate: Date? = self.getDateTime(Field.createdDate.platformSpecificRawValue)
    open fileprivate(set) lazy var lastModifiedDate: Date? = self.getDateTime(Field.lastModifiedDate.platformSpecificRawValue)
    
    open var recordTypeId: String? {
        get { return getString(Field.recordTypeId.platformSpecificRawValue) }
        set { setString(Field.recordTypeId.platformSpecificRawValue, value: newValue) }
    }
    
    open var currencyIsoCode: String? {
        get { return getString(Field.currencyIsoCode.platformSpecificRawValue) }
        set { setString(Field.currencyIsoCode.platformSpecificRawValue, value: newValue) }
    }
    
    open var json: Variable<JSON>
    
    public required init(dictionary: NSDictionary) {
        self.json = Variable(JSON(dictionary))
    }
    
    public required init(json: JSON) {
        self.json = Variable(json)
    }
    
    public required init(objectType: String) {
        self.json = Variable(JSON([:]))
        self.json.value["attributes"] = JSON(["type" : objectType])
        let uuid = UUID().uuidString
        setString(Field.externalId.platformSpecificRawValue, value: uuid)
        setString(Field.id.platformSpecificRawValue, value: uuid)
    }
    
    open func setString(_ name: String, value: String?) {
        if let value: String = value {
            json.value[name] = JSON(value)
        }
        else {
            json.value[name] = JSON.null
        }
    }
    
    open func setInteger(_ name: String, value: Int?) {
        if let value: Int = value {
            json.value[name] = JSON(value)
        }
        else {
            json.value[name] = JSON.null
        }
    }
    
    open func setDouble(_ name: String, value: Double?) {
        if let value: Double = value {
            json.value[name] = JSON(value)
        }
        else {
            json.value[name] = JSON.null
        }
    }
    
    open func setBoolean(_ name: String, value: Bool) {
        json.value[name] = JSON(value)
    }
    
    open func setDate(_ name: String, value: Date?) {
        if let value: Date = value {
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
            dateFormatter.dateFormat = "yyyy-MM-dd"
            json.value[name] = JSON(dateFormatter.string(from: value))
        }
        else {
            json.value[name] = JSON.null
        }
    }
    
    open func setDateTime(_ name: String, value: Date?) {
        if let value: Date = value {
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
            json.value[name] = JSON(dateFormatter.string(from: value))
        }
        else {
            json.value[name] = JSON.null
        }
    }
    
    open func setAddress(_ name: String, value: CSAddress?, streetField: String, cityField: String, stateCodeField: String, postalCodeField: String, countryCodeField: String) {
        if let value: CSAddress = value {
            json.value[name] = JSON(value.dictionary)
            json.value[streetField] = value.street == nil ? JSON.null : JSON(value.street!)
            json.value[cityField] = value.city == nil ? JSON.null : JSON(value.city!)
            json.value[stateCodeField] = value.stateCode == nil ? JSON.null : JSON(value.stateCode!)
            json.value[postalCodeField] = value.postalCode == nil ? JSON.null : JSON(value.postalCode!)
            json.value[countryCodeField] = value.countryCode == nil ? JSON.null : JSON(value.countryCode!)
        }
        else {
            json.value[name] = JSON.null
            json.value[streetField] = JSON.null
            json.value[cityField] = JSON.null
            json.value[stateCodeField] = JSON.null
            json.value[postalCodeField] = JSON.null
            json.value[countryCodeField] = JSON.null
        }
    }
    
    open func setImage(_ name: String, value: UIImage?) {
        if let image = value {
            let imageData: Data = UIImageJPEGRepresentation(image, 0.0)!
            let imageString: String = imageData.base64EncodedString()
            setString(name, value: imageString)
        }
    }
    
    public func setGeolocation(_ name: String, value: CSGeolocation?) {
        if let value: CSGeolocation = value {
            json.value[name] = JSON(value.dictionary)
            if let range = name.range(of: "__c") {
                let locationName: String = name.substring(to: range.lowerBound)
                json.value[locationName + CSGeolocation.Name.latitudeS.platformSpecificRawValue] = JSON(value.latitude ?? 0.0)
                json.value[locationName + CSGeolocation.Name.longitudeS.platformSpecificRawValue] = JSON(value.longitude ?? 0.0)
            }
        }
        else {
            json.value[name] = JSON.null
        }
    }
    
    open func setReference<R: CSRecord>(_ name: String, value: R?, relationshipName: String) {
        if let value: R = value, let id: String = value.id {
            json.value[name] = JSON(id)
            json.value[relationshipName] = value.json.value
        }
        else {
            json.value[name] = JSON.null
            json.value[relationshipName] = JSON.null
        }
    }
    
    open func getString(_ name: String) -> String? {
        return json.value[name].string
    }
    
    open func getBoolean(_ name: String) -> Bool {
        return json.value[name].boolValue
    }
    
    open func getInteger(_ name: String) -> Int? {
        return json.value[name].int
    }
    
    open func getDouble(_ name: String) -> Double? {
        if let range = name.range(of: CSGeolocation.Name.latitudeS.platformSpecificRawValue) {
            let locationName: String = name.substring(to: range.lowerBound) + "__c"
            let location: CSGeolocation? = getGeolocation(locationName)
            return location?.latitude
        }
        if let range = name.range(of: CSGeolocation.Name.longitudeS.platformSpecificRawValue) {
            let locationName: String = name.substring(to: range.lowerBound) + "__c"
            let location: CSGeolocation? = getGeolocation(locationName)
            return location?.longitude
        }
        return json.value[name].double
    }
    
    open func getDate(_ name: String) -> Date? {
        if let value: String = json.value[name].string {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.date(from: value)?.toGMT()
        }
        return nil
    }
    
    open func getDateTime(_ name: String) -> Date? {
        if let value: String = json.value[name].string {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
            return dateFormatter.date(from: value)
        }
        return nil
    }
    
    open func getAddress(_ name: String) -> CSAddress? {
        let value: JSON = json.value[name]
        if value.isEmpty {
            return nil
        }
        return CSAddress(json: value)
    }
    
    open func getImage(_ name: String) -> UIImage? {
        if let imageString = getString(name) {
            if let data = NSData(fromBase64String: imageString) {
                let createdImage: UIImage? = UIImage(data: data as Data)
                return createdImage
            }
        }
        return nil
    }
    
    public func getGeolocation(_ name: String) -> CSGeolocation? {
        let value: JSON = json.value[name]
        if value.isEmpty {
            return nil
        }
        return CSGeolocation(json: value)
    }
    
    open func getReference<R: CSRecord>(_ name: String) -> R? {
        let value: JSON = json.value[name]
        if value.isEmpty {
            return nil
        }
        return R(json: value)
    }
    
    open func getReference<R: CSRecord>(_ objectName: String, id: String) -> R? where R: ReferenceReadable {
        return R.read(objectName, id: id)
    }

    open func getReference<R: CSRecord>(_ objectName: String, id: String) -> [R]? where R: ReferenceReadable {
        return R.read(objectName, id: id)
    }

    open func toStoreEntry() -> [String : AnyObject] {
        return json.value.dictionaryObject! as [String : AnyObject]
    }
    
    open func printToConsole() {
        print(json)
    }
    
}

public func ==(left: CSRecordBase, right: CSRecordBase) -> Bool {
    if left.id != nil && right.id != nil && left.id == right.id {
        return true
    }
    if left.externalId != nil && right.externalId != nil && left.externalId == right.externalId {
        return true
    }
    return false
}

public protocol ReferenceReadable {
    static func read<R: CSRecordBase>(_ objectName: String, id: String) -> [R]?
    static func read<R: CSRecordBase>(_ objectName: String, id: String) -> R?
}
