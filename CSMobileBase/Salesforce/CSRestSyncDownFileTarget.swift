//
//  CSRestSyncDownTarget.swift
//  FieldVisit
//
//  Created by Mayank Bhayana on 3/22/18.
//  Copyright © 2018 Textron, Inc. All rights reserved.
//

import Foundation
import SmartSync

public let kCSRestSyncDownFileTargetId = "Id"

@objc(CSRestSyncDownFileTarget)
class CSRestSyncDownFileTarget: SFSyncDownTarget {

    private var id: String?
    
    override public init!(dict: [AnyHashable : Any]!) {
        if let id = dict[kCSRestSyncDownFileTargetId] as? String? {
            self.id = id
        }
        super.init(dict: dict)
        queryType = .custom
    }
    
    override func asDict() -> NSMutableDictionary {
        let dict: NSMutableDictionary = super.asDict()
        dict[kSFSyncTargetiOSImplKey] = String(describing: type(of: self))
        dict[kCSRestSyncDownFileTargetId] = id
        return dict
    }
    
    static func newSyncTarget(dict: [AnyHashable : Any]!) -> CSRestSyncDownFileTarget {
        return CSRestSyncDownFileTarget(dict: dict)
    }
    
    override func startFetch(_ syncManager: SFSmartSyncSyncManager!, maxTimeStamp: Int64, errorBlock: SFSyncDownTargetFetchErrorBlock!, complete completeBlock: SFSyncDownTargetFetchCompleteBlock!) {
        
        SFLogger.log(SFLogLevel.debug, msg: "CSRestSyncDown request")
        if let id = self.id {
            
            let path: String = "/\(SFRestAPI.sharedInstance().apiVersion)/sobjects/attachment/\(id)/body"
            let queryParams = ["fields" : "body"]
            let request: SFRestRequest = SFRestRequest(method: .GET, path:path, queryParams:queryParams)
            request.parseResponse = false
            
            SFSmartSyncNetworkUtils.sendRequest(withSmartSyncUserAgent: request, fail: { (error) in
                SFLogger.log(SFLogLevel.error, msg: "CSRestSyncDownFile request failed: \(String(describing: error?.localizedDescription))")
                errorBlock(error)
            }) { [weak self] (response) in
                if let data = response as? NSData {
                    let encodedString: String = data.base64EncodedString(options: [] )
                    var responseDictionary: [AnyHashable : Any] = ["image" : encodedString]
                    responseDictionary[kCSRestSyncDownFileTargetId] = id
                    self?.totalSize = 1
                    completeBlock([responseDictionary])
                    SFLogger.log(SFLogLevel.debug, msg: "CSRestSyncDownFile request success")
                } else {
                    SFLogger.log(SFLogLevel.error, msg: "CSRestSyncDownFile request failed: Invalid Response Type")
                }
            }
        }
    }
}
