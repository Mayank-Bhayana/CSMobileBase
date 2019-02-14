
//  HerokuSyncDownTarget.swift
//  FieldVisit
//
//  Created by Nicholas McDonald on 3/24/17.
//  Copyright © 2017 Salesforce, Inc. All rights reserved.
//

import Foundation
import SmartSync
import SmartStore
import SalesforceSDKCore

public struct HerokuTargetConstants {
    static let kHerokuSyncTargetSoup = "soup"
    static let kHerokuSyncTargetPath = "path"
    static let kHerokuSyncTargetHost = "host"
    static let kHerokuSyncTargetQueryParams = "queryParams"
    static let kHerokuSyncTargetEndpoint = "endpoint"
    static let kHerokuSyncTargetIdField = "id"
    static let kHerokuSyncTargetObjectType = "objectType"
}

@objc(HerokyBaseSyncDownTarget)
public class HerokuBaseSyncDownTarget:SFSyncDownTarget {
    public var path:String = "/magic/apex/apex"
    public var host:String = "https://fieldvisit.herokuapp.com"
//    public var host:String = "http://172.18.27.110:3000"
    public var params:Dictionary<String, String> = [:]
    public var endpoint:String = ""
    open var objectType: String = ""
    
    override init() {
        super.init()
        self.queryType = .custom
        self.idFieldName = "id"
        self.modificationDateFieldName = "lastmodifieddate"
    }
    
    override convenience init!(dict: [AnyHashable : Any]!) {
        self.init()
        let d = dict as! Dictionary<String, AnyObject>
        if let path:String = d[HerokuTargetConstants.kHerokuSyncTargetPath] as! String? {
            self.path = path
        }
        if let host:String = d[HerokuTargetConstants.kHerokuSyncTargetHost] as! String? {
            self.host = host
        }
        if let endpoint:String = d[HerokuTargetConstants.kHerokuSyncTargetEndpoint] as! String? {
            self.endpoint = endpoint
        }
        if let params:Dictionary<String, String> = d[HerokuTargetConstants.kHerokuSyncTargetQueryParams] as! Dictionary<String, String>? {
            self.params = params
        }
        if let objectType:String = d[HerokuTargetConstants.kHerokuSyncTargetObjectType] as! String? {
            self.objectType = objectType
        }
    }
    
    func updateRecordId(_ record:[String:Any], inStore:SFSmartStore) -> [String:Any]? {
        
        if let pgid = record["pgid"], let id = record["id"], let pg = pgid as? NSNumber, let sfid = id as? String {
            let query = CSQueryBuilder.forSoupName(self.objectType).whereEqual("id", value:pg.stringValue)
            let spec = SFQuerySpec.newSmartQuerySpec(query.build(), withPageSize: 100)
            let entry = try? inStore.query(with: spec, pageIndex: 0)
            
            if let storedRecord = entry?.first {
                let recordArray = storedRecord as! Array<Dictionary<String, Any>>
                if let rec = recordArray.first {
                    let recordPdId = rec["pgid"]
                    let recordfv_pgid = rec["fv_pgid__c"]
                    var r = rec
                    r["id"] = sfid
                    if self.objectType.characters.count > 0 {
                        let upserted = inStore.upsertEntries([r], toSoup: self.objectType)
                    }
                }
            }
            return record
        }
        return nil
    }
    
    func handleResponse(_ response:Any?, errorBlock: SFSyncDownTargetFetchErrorBlock, completeBlock: SFSyncDownTargetFetchCompleteBlock) {
        let smartstore = SFSmartStore.sharedStore(withName: kDefaultSmartStoreName) as! SFSmartStore
        if response is Array<Any> {
            let array = response as! Array<Dictionary<String, Any>>
            
            
            self.totalSize = UInt(array.count)
            if array.count > 0 {
                let lowercase = NSDictionary.recursivelyFindAndLowercaseDictionaryKeys(array) as! Array<Dictionary<String, Any>>
                var updated:Array<Dictionary<String, Any>> = []
                for record in lowercase {
                    if let u = self.updateRecordId(record, inStore: smartstore) {
                        updated.append(u)
                    }
                }
                if updated.count > 0 {
                    completeBlock(updated)
                } else {
                    let error = NSError(domain: "heroku", code: 100, userInfo: ["msg":"Missing salesforce id"])
                    errorBlock(error)
                }
            } else {
                completeBlock(array)
            }
        } else if response is Dictionary<String, Any> {
            let dictionary = response as! Dictionary<String, Any>
            if let lowercase = NSDictionary.toLowercasedKeysDictionary(dictionary) {
                if let u = self.updateRecordId(lowercase, inStore: smartstore) {
                    self.totalSize = 1
                    completeBlock([u])
                } else {
                    let error = NSError(domain: "heroku", code: 100, userInfo: ["msg":"Missing salesforce id"])
                    errorBlock(error)
                }
            } else {
                let error = NSError(domain: "heroku", code: 100, userInfo: ["msg":"Missing salesforce id"])
                errorBlock(error)
            }
        } else {
            let error = NSError(domain: "heroku", code: 100, userInfo: ["msg":"Invalid response type"])
            errorBlock(error)
        }
    }
    
    func handleApexResponse(_ response:Any?, errorBlock: SFSyncDownTargetFetchErrorBlock, completeBlock: SFSyncDownTargetFetchCompleteBlock) {
        if response is Array<Any> {
            let array = response as! Array<Dictionary<String, Any>>
            
            self.totalSize = UInt(array.count)
            if array.count > 0 {
                let lowercase = NSDictionary.recursivelyFindAndLowercaseDictionaryKeys(array) as! Array<Dictionary<String, Any>>
                completeBlock(lowercase)
            } else {
                let error = NSError(domain: "heroku", code: 100, userInfo: ["msg":"No Records"])
                errorBlock(error)
            }
        } else if response is Dictionary<String, Any> {
            let dictionary = response as! Dictionary<String, Any>
            if let lowercase = NSDictionary.toLowercasedKeysDictionary(dictionary) {
                self.totalSize = 1
                completeBlock([lowercase])
            } else {
                let error = NSError(domain: "heroku", code: 100, userInfo: ["msg":"No Records"])
                errorBlock(error)
            }
        } else {
            let error = NSError(domain: "heroku", code: 100, userInfo: ["msg":"Invalid response type"])
            errorBlock(error)
        }
    }
}

@objc(HerokuApexSyncDownTarget)
public class HerokuApexSyncDownTarget:HerokuBaseSyncDownTarget {
    
    override public func asDict() -> NSMutableDictionary! {
        let dict = super.asDict()
        dict?[kSFSyncTargetiOSImplKey] = "HerokuApexSyncDownTarget"
        dict?[HerokuTargetConstants.kHerokuSyncTargetPath] = self.path
        dict?[HerokuTargetConstants.kHerokuSyncTargetHost] = self.host
        dict?[HerokuTargetConstants.kHerokuSyncTargetQueryParams] = self.params
        dict?[HerokuTargetConstants.kHerokuSyncTargetEndpoint] = self.endpoint
        dict?[HerokuTargetConstants.kHerokuSyncTargetObjectType] = self.objectType
        return dict
    }
    
    public class func newSyncTarget(path:String?, params:[String:AnyObject]) -> HerokuApexSyncDownTarget {
        var dict:Dictionary<AnyHashable, Any> = [HerokuTargetConstants.kHerokuSyncTargetQueryParams:params]
        if let p = path {
            dict[HerokuTargetConstants.kHerokuSyncTargetPath] = p
        }
        return HerokuApexSyncDownTarget(dict: dict)
    }
    
    override public func startFetch(_ syncManager: SFSmartSyncSyncManager!, maxTimeStamp: Int64, errorBlock: SFSyncDownTargetFetchErrorBlock!, complete completeBlock: SFSyncDownTargetFetchCompleteBlock!) {
        
        
        let request = SFRestRequest(method: .GET, path: "\(self.endpoint)\(self.path)", queryParams: self.params)
        request.action.pathPrefix = "" //remove default path prefix
        request.requiresAuthentication = false
        if let hostURL = URL(string: self.host) {
            request.action.baseURL = hostURL
        }
        
        SFSmartSyncNetworkUtils.sendRequest(withSmartSyncUserAgent: request, fail: errorBlock) { (response) in
            self.handleApexResponse(response, errorBlock: errorBlock, completeBlock: completeBlock)
        }
    }
}

@objc(HerokuSFDBSyncDownTarget)
public class HerokuSFDBSyncDownTarget:HerokuBaseSyncDownTarget {
    
    override init() {
        super.init()
        self.path = "/magic"
        self.idFieldName = HerokuTargetConstants.kHerokuSyncTargetIdField
    }
    
    override public func asDict() -> NSMutableDictionary! {
        let dict = super.asDict()
        dict?[kSFSyncTargetiOSImplKey] = "HerokuSFDBSyncDownTarget"
        dict?[HerokuTargetConstants.kHerokuSyncTargetPath] = self.path
        dict?[HerokuTargetConstants.kHerokuSyncTargetHost] = self.host
        dict?[HerokuTargetConstants.kHerokuSyncTargetQueryParams] = self.params
        dict?[HerokuTargetConstants.kHerokuSyncTargetEndpoint] = self.endpoint
        dict?[HerokuTargetConstants.kHerokuSyncTargetObjectType] = self.objectType
        return dict
    }
    
    public class func newSyncTarget(path:String?, params:[String:AnyObject]) -> HerokuSFDBSyncDownTarget {
        var dict:Dictionary<AnyHashable, Any> = [HerokuTargetConstants.kHerokuSyncTargetQueryParams:params]
        if let p = path {
            dict[HerokuTargetConstants.kHerokuSyncTargetPath] = p
        }
        return HerokuSFDBSyncDownTarget(dict: dict)
    }
    
    override public func startFetch(_ syncManager: SFSmartSyncSyncManager!, maxTimeStamp: Int64, errorBlock: SFSyncDownTargetFetchErrorBlock!, complete completeBlock: SFSyncDownTargetFetchCompleteBlock!) {
        
        let request = SFRestRequest(method: .GET, path: "\(self.endpoint)\(self.path)", queryParams: self.params)
        request.action.pathPrefix = "" //remove default path prefix
        request.requiresAuthentication = false
        if let hostURL = URL(string: self.host) {
            request.action.baseURL = hostURL
        }
        
        SFSmartSyncNetworkUtils.sendRequest(withSmartSyncUserAgent: request, fail: errorBlock) { (response) in
            self.handleResponse(response, errorBlock: errorBlock, completeBlock: completeBlock)
        }
    }
}

@objc(HerokuRestSyncDownFileTarget)
public class HerokuRestSyncDownFileTarget:HerokuBaseSyncDownTarget {
    
    private var id:String?
    
    override init() {
        super.init()
        self.path = "/magic"
        self.idFieldName = HerokuTargetConstants.kHerokuSyncTargetIdField
    }
    
    convenience init!(dict: [AnyHashable : Any]!) {
        self.init()
        if let queryParams:Dictionary<String, Any> = dict[HerokuTargetConstants.kHerokuSyncTargetQueryParams] as! Dictionary<String, Any>? {
            let loweredParams = NSDictionary.toLowercasedKeysDictionary(queryParams)
            self.id = loweredParams?[HerokuTargetConstants.kHerokuSyncTargetIdField] as! String?
        }
        if let path:String = dict[HerokuTargetConstants.kHerokuSyncTargetPath] as! String? {
            self.path = path
        }
        if let host:String = dict[HerokuTargetConstants.kHerokuSyncTargetHost] as! String? {
            self.host = host
        }
        if let endpoint:String = dict[HerokuTargetConstants.kHerokuSyncTargetEndpoint] as! String? {
            self.endpoint = endpoint
        }
        if let params:Dictionary<String, String> = dict[HerokuTargetConstants.kHerokuSyncTargetQueryParams] as! Dictionary<String, String>? {
            self.params = params
        }
    }
    
    override public func asDict() -> NSMutableDictionary! {
        let dict = super.asDict()
        dict?[kSFSyncTargetiOSImplKey] = "HerokuRestSyncDownFileTarget"
        dict?[HerokuTargetConstants.kHerokuSyncTargetPath] = self.path
        dict?[HerokuTargetConstants.kHerokuSyncTargetHost] = self.host
        dict?[HerokuTargetConstants.kHerokuSyncTargetQueryParams] = self.params
        dict?[HerokuTargetConstants.kHerokuSyncTargetEndpoint] = self.endpoint
        return dict
    }
    
    public class func newSyncTarget(path:String?, params:[String:AnyObject]) -> HerokuRestSyncDownFileTarget {
        var dict:Dictionary<AnyHashable, Any> = [HerokuTargetConstants.kHerokuSyncTargetQueryParams:params]
        if let p = path {
            dict[HerokuTargetConstants.kHerokuSyncTargetPath] = p
        }
        return HerokuRestSyncDownFileTarget(dict: dict)
    }
    
    override public func startFetch(_ syncManager: SFSmartSyncSyncManager!, maxTimeStamp: Int64, errorBlock: SFSyncDownTargetFetchErrorBlock!, complete completeBlock: SFSyncDownTargetFetchCompleteBlock!) {
        
        var path = ""
        if let attachmentId = self.id {
            path = NSString(format: "%@%@/attachment/%@", self.endpoint, self.path, attachmentId) as String
        }
        let request = SFRestRequest(method: .GET, path: path, queryParams: nil)
        request.action.pathPrefix = "" //remove default path prefix
        request.requiresAuthentication = false
        if let hostURL = URL(string: self.host) {
            request.action.baseURL = hostURL
        }
        
        SFSmartSyncNetworkUtils.sendRequest(withSmartSyncUserAgent: request, fail: errorBlock) { [weak self] (response) in
            
            if response is Dictionary<String, Any> {
                let dictionary = response as! Dictionary<String, Any>
                
                if self?.id != nil {
                    // is an attachment
                    if let bytes = dictionary["data"] as? Array<UInt8> {
                        let data = NSData(bytes: bytes, length:bytes.count)
                        let base64 = data.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                        var response:[AnyHashable : Any] = ["image" : base64]
                        response[HerokuTargetConstants.kHerokuSyncTargetIdField] = self?.id
                        self?.totalSize = 1
                        completeBlock([response])
                    }
                } else {
                    self?.handleResponse(dictionary, errorBlock: errorBlock, completeBlock: completeBlock)
                }
            }
        }
    }
}











