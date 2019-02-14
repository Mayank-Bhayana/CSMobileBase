//
//  CSPageLayout.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 10/01/19.
//


import Foundation
import SwiftyJSON

open class CSPageLayout: CustomStringConvertible {
    
    enum Attribute: String {
        case id = "Id"
        case objectType = "ObjectType"
        case recordTypeId = "RecordTypeId"
        case recordTypeName = "RecordTypeName"
        case fieldLayouts = "FieldLayouts"
    }
    
    open fileprivate(set) lazy var recordTypeId: String? = self.json[Attribute.recordTypeId.rawValue].string
    open fileprivate(set) lazy var recordTypeName: String? = self.json[Attribute.recordTypeName.rawValue].string
    open fileprivate(set) lazy var fieldLayouts: [CSFieldLayout] = self.getFieldLayouts()
    
    fileprivate var json: JSON
    
    init(json: JSON) {
        self.json = json
    }
    
    open var description: String {
        return json.description
    }
    
    fileprivate func getFieldLayouts() -> [CSFieldLayout] {
        if let value: [JSON] = json[Attribute.fieldLayouts.rawValue].array {
            return value.map { CSFieldLayout(json: $0) }
        }
        return []
    }
    
    static func fromStoreEntry(_ entry: AnyObject?) -> CSPageLayout? {
        if let entry: NSDictionary = entry as? NSDictionary {
            let json: JSON = JSON(entry)
            return CSPageLayout(json: json)
        }
        return nil
    }
    
}

