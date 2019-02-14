//
//  CSRecordType.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 10/01/19.
//


import Foundation
import SwiftyJSON

open class CSRecordType: CustomStringConvertible  {
    
    enum Name: String {
        case id = "Id"
        case label = "Label"
        case isAvailable = "IsAvailable"
    }
    
    open fileprivate(set) lazy var id: String = self.json[Name.id.rawValue].stringValue
    open fileprivate(set) lazy var label: String? = self.json[Name.label.rawValue].string
    open fileprivate(set) lazy var isAvailable: Bool = self.json[Name.isAvailable.rawValue].boolValue
    
    fileprivate var json: JSON
    
    init(json: JSON) {
        self.json = json
    }
    
    open var description: String {
        return json.description
    }
    
}

