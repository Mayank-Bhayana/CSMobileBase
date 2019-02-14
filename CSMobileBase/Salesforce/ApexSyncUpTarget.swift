//
//  CSRestSyncDownTarget.swift
//  FieldVisit
//
//  Created by Mayank Bhayana on 3/22/18.
//  Copyright © 2018 Textron, Inc. All rights reserved.
//

import Foundation
import SmartSync

public let kApexSyncUpTargetId = "Id"
public let kApexSyncUpTargetSoup = "soup"
public let kApexSyncUpTargetPath = "path"
public let kApexSyncUpTargetEndpoint = "endpoint"

@objc(ApexSyncUpTarget)
class ApexSyncUpTarget: SFSyncUpTarget {

    private var soup: String
    private var path: String
    private var endpoint: String
    
    override public init!(dict: [AnyHashable : Any]!) {
        self.soup = dict[kApexSyncUpTargetSoup] as! String
        self.path = dict[kApexSyncUpTargetPath] as! String
        self.endpoint = dict[kApexSyncUpTargetEndpoint] as! String
        super.init(dict: dict)
        targetType = .custom
    }
    
    override func asDict() -> NSMutableDictionary {
        let dict: NSMutableDictionary = super.asDict()
        dict[kSFSyncTargetiOSImplKey] = String(describing: type(of: self))
        dict[kApexSyncUpTargetSoup] = soup
        dict[kApexSyncUpTargetPath] = path
        dict[kApexSyncUpTargetEndpoint] = endpoint
        return dict
    }
    
    static func newSyncTarget(dict: [AnyHashable : Any]!) -> ApexSyncUpTarget {
        return ApexSyncUpTarget(dict: dict)
    }

    static func newSyncTarget(_ soup: String, path: String, endpoint: String? = nil) -> ApexSyncUpTarget {
        return ApexSyncUpTarget(dict: [kApexSyncUpTargetSoup : soup, kApexSyncUpTargetPath : path, kApexSyncUpTargetEndpoint: endpoint ?? ""])
    }
    
    
    override func create(onServer objectType: String!, fields: [AnyHashable : Any]!, completionBlock: SFSyncUpTargetCompleteBlock!, fail failBlock: SFSyncUpTargetErrorBlock!) {
        if let fields = fields as? [String : String] {
            let request: SFRestRequest = SFRestRequest(method: .POST, path: path, queryParams: fields)
            request.endpoint = endpoint
            
            SFSmartSyncNetworkUtils.sendRequest(withSmartSyncUserAgent: request, fail: failBlock) { response in
                if let dictionaryResponse = response as? Dictionary<String,String>, let objectId = dictionaryResponse[kApexSyncUpTargetId] {
                    completionBlock([kApexSyncUpTargetId : objectId])
                } else {
                    failBlock(nil)
                }
            }
        }
    }
    
    override func update(onServer objectType: String!, objectId: String!, fields: [AnyHashable : Any]!, completionBlock: SFSyncUpTargetCompleteBlock!, fail failBlock: SFSyncUpTargetErrorBlock!) {
        let path = self.path.appending(objectId)
        if let fields = fields as? [String : String] {
            let request: SFRestRequest = SFRestRequest(method: .PATCH, path: path, queryParams: fields)
            request.endpoint = endpoint
            
            SFSmartSyncNetworkUtils.sendRequest(withSmartSyncUserAgent: request, fail: failBlock) { response in
                if let dictionaryResponse = response as? Dictionary<String,String>, let objectId = dictionaryResponse[kApexSyncUpTargetId] {
                    completionBlock([kApexSyncUpTargetId : objectId])
                } else {
                    failBlock(nil)
                }
            }
        }
    }

    override func delete(onServer objectType: String!, objectId: String!, completionBlock: SFSyncUpTargetCompleteBlock!, fail failBlock: SFSyncUpTargetErrorBlock!) {
        let path = self.path.appending(objectId)
        let request: SFRestRequest = SFRestRequest(method: .DELETE, path: path, queryParams: nil)
        request.endpoint = endpoint
        
        SFSmartSyncNetworkUtils.sendRequest(withSmartSyncUserAgent: request, fail: failBlock, complete: completionBlock as! SFRestResponseBlock)
    }
}
