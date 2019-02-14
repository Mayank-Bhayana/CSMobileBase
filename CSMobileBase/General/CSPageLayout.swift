//
//  CSPageLayout.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 6/28/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import SwiftyJSON
import SmartStore

public struct CSPageLayout: CustomStringConvertible {
    
    public var description: String
    
    public let soupLastModifiedDate: Int64
    public let recordTypeId: String?
    public let recordTypeName: String?
    public let editLayoutSections: [CSLayoutSection]
    public let detailLayoutSections: [CSLayoutSection]
    public let highlightsPanelLayoutSection: CSLayoutSection?
    public let validationInfo: [CSValidationInfo]
    
    //Deprecate this in CSMobileBase
    public let fieldLayouts: [CSFieldLayout]
    
    internal enum Name: String {
        case id = "Id"
        case objectType = "ObjectType"
        case recordTypeId = "RecordTypeId"
        case recordTypeName = "RecordTypeName"
        case layout = "Layout"
        case validationInfo = "ValidationInfo"
        
        //Deprecate this in CSMobileBase
        case fieldLayouts = "FieldLayouts"
    }
    
    internal init(json: JSON) {
        description = json.description
        soupLastModifiedDate = json[SOUP_LAST_MODIFIED_DATE].int64Value
        recordTypeId = json[Name.recordTypeId.platformSpecificRawValue].string
        recordTypeName = json[Name.recordTypeName.platformSpecificRawValue].string
        if let array: [JSON] = json[Name.layout.platformSpecificRawValue]["detailLayoutSections".platformCaseStringValue].array {
            detailLayoutSections = array.map { CSLayoutSection(json: $0) }
        }
        else {
            detailLayoutSections = []
        }
        if let array: [JSON] = json[Name.layout.platformSpecificRawValue]["editLayoutSections".platformCaseStringValue].array {
            editLayoutSections = array.map { CSLayoutSection(json: $0) }
        }
        else {
            editLayoutSections = []
        }
        if json[Name.layout.platformSpecificRawValue]["highlightsPanelLayoutSection".platformCaseStringValue].isEmpty == false {
            let json: JSON = json[Name.layout.platformSpecificRawValue]["highlightsPanelLayoutSection".platformCaseStringValue]
            highlightsPanelLayoutSection = CSLayoutSection(json: json)
        }
        else {
            highlightsPanelLayoutSection = nil
        }
        if let array: [JSON] = json[Name.fieldLayouts.platformSpecificRawValue].array {
            fieldLayouts = array.map { CSFieldLayout(json: $0) }
        }
        else {
            fieldLayouts = []
        }
        if let array: [JSON] = json[Name.validationInfo.platformSpecificRawValue]["Records".platformCaseStringValue].array {
            validationInfo = array.map { CSValidationInfo(json: $0) }
        }
        else {
            validationInfo = []
        }
        print(self)
    }
    
    internal init(dictionary: NSDictionary) {
        self.init(json: JSON(dictionary))
    }
    
    public func isValid(record: CSRecord) -> (Bool, UIAlertController?) {
        for validationInfoItem in validationInfo {
            let response = validationInfoItem.parseValidation(record: record)
            if response.0 == false {
                let alertController: UIAlertController = UIAlertController(title: SFLocalizedString("INVALID_VALUE", ""), message: response.1, preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: SFLocalizedString("DISMISS", ""), style: UIAlertActionStyle.cancel, handler: nil))

                return (false, alertController)
            }
        }
        return (true, nil)
    }
    
}
