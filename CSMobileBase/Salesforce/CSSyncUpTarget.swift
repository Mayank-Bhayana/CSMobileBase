//
//  CSRestSyncDownTarget.swift
//  FieldVisit
//
//  Created by Mayank Bhayana on 3/22/18.
//  Copyright © 2017 Textron, Inc. All rights reserved.
//

import Foundation
import SmartSync

public let kCSSyncUpTargetSoup = "soup"
public let kCSSyncUpTargetUpdateFields = "updateFields"
public let kCSSyncUpTargetCreateFields = "createFields"

@objc(CSSyncUpTarget)
class CSSyncUpTarget: SFSyncUpTarget {

    private var soup: String?
    private var updateFields: Set<String>?
    private var createFields: Set<String>?
    
    
    override public init!(dict: [AnyHashable : Any]!) {
        self.soup = dict[kCSSyncUpTargetSoup] as! String?
        self.createFields = dict[kCSSyncUpTargetCreateFields] as! Set?
        self.updateFields = dict[kCSSyncUpTargetUpdateFields] as! Set?
        super.init(dict: dict)
        targetType = .custom
    }
    
    override func asDict() -> NSMutableDictionary {
        let dict: NSMutableDictionary = super.asDict()
        dict[kSFSyncTargetiOSImplKey] = String(describing: type(of: self))
        dict[kCSSyncUpTargetSoup] = soup
        dict[kCSSyncUpTargetCreateFields] = createFields
        dict[kCSSyncUpTargetUpdateFields] = updateFields
        return dict
    }
    
    static func newSyncTarget(dict: [AnyHashable : Any]!) -> CSSyncUpTarget {
        return CSSyncUpTarget(dict: dict)
    }

    static func newSyncTarget(_ objectType: String, createFields: Set<String>, updateFields: Set<String>) -> CSSyncUpTarget {
        return CSSyncUpTarget(dict: [kCSSyncUpTargetSoup : objectType, kCSSyncUpTargetUpdateFields : updateFields, kCSSyncUpTargetCreateFields : createFields])
    }
    
    override func create(onServer objectType: String!, fields: [AnyHashable : Any]!, completionBlock: SFSyncUpTargetCompleteBlock!, fail failBlock: SFSyncUpTargetErrorBlock!) {
            
        let filteredFields = fields.filter { createFields?.contains($0.key as! String) ?? false }
        var filteredDictionary: [AnyHashable : Any] {
            var result: [AnyHashable : Any] = [:]
            filteredFields.enumerated().forEach { (offset: Int, element: (key: AnyHashable, value: Any)) in
                return result[element.key] = element.value
            }
            return result
        }
        super.create(onServer: objectType, fields: filteredDictionary, completionBlock: completionBlock, fail: failBlock)
    }
    
    override func update(onServer objectType: String!, objectId: String!, fields: [AnyHashable : Any]!, completionBlock: SFSyncUpTargetCompleteBlock!, fail failBlock: SFSyncUpTargetErrorBlock!) {
        let filteredFields = fields.filter { updateFields?.contains($0.key as! String) ?? false }
        var filteredDictionary: [AnyHashable : Any] {
            var result: [AnyHashable : Any] = [:]
            filteredFields.enumerated().forEach { (offset: Int, element: (key: AnyHashable, value: Any)) in
                return result[element.key] = element.value
            }
            return result
        }
        super.update(onServer: objectType, objectId: objectId, fields: filteredDictionary, completionBlock: completionBlock, fail: failBlock)
    }
}
