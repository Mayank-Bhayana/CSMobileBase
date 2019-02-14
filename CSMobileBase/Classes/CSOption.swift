//
//  CSOption.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 10/01/19.
//

import Foundation
import SwiftyJSON

open class CSOption: CustomStringConvertible {
    
    enum Attribute: String {
        case value = "Value"
        case validFor = "ValidFor"
        case label = "Label"
        case defaultValue = "DefaultValue"
        case active = "Active"
    }
    
    fileprivate var json: JSON
    
    init(json: JSON) {
        self.json = json
    }
    
    open var description: String {
        return json.description
    }
    
    open fileprivate(set) lazy var value: String? = self.json[Attribute.value.rawValue].string
    open fileprivate(set) lazy var validFor: String? = self.json[Attribute.validFor.rawValue].string
    open fileprivate(set) lazy var label: String? = self.json[Attribute.label.rawValue].string
    open fileprivate(set) lazy var defaultValue: String? = self.json[Attribute.defaultValue.rawValue].string
    open fileprivate(set) lazy var active: String? = self.json[Attribute.active.rawValue].string
    
}

