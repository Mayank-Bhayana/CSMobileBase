//
//  CSSettings.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 10/01/19.
//


import Foundation
import SwiftyJSON

open class CSSettings: CustomStringConvertible {
    
    enum Attribute: String {
        case id = "Id"
        case objects = "ObjectInfo"
    }
    
    open fileprivate(set) lazy var objectTypes: [String] = self.getObjectTypes()
    
    open var json: JSON
    
    public required init(json: JSON) {
        self.json = json
    }
    
    open var description: String {
        return json.description
    }
    
    open func objectForObjectType(_ objectType: String) -> CSObject? {
        if let json: JSON = json[Attribute.objects.rawValue][objectType] {
            if json.isEmpty == false {
                return CSObject(json: json)
            }
        }
        return nil
    }
    
    fileprivate func getObjectTypes() -> [String] {
        if let dictionary: [String : AnyObject] = json[Attribute.objects.rawValue].dictionaryObject! as [String : AnyObject]  {
            return Array(dictionary.keys)
        }
        return []
    }
    
    open static func fromStoreEntry<S: CSSettings>(_ storeEntry: AnyObject?) -> S {
        if let storeEntry: NSDictionary = storeEntry as? NSDictionary {
            let json: JSON = JSON(storeEntry)
            return S(json: json)
        }
        return S(json: JSON.null)
    }
    
}

