
//  HerokuSyncUpTarget.swift
//  CSMobileBase
//
//  Created by Nicholas McDonald on 4/14/17.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import Foundation
import SmartSync
import SmartStore
import SalesforceSDKCore


@objc(HerokuBaseSyncUpTarget)
public class HerokuBaseSyncUpTarget:SFSyncUpTarget {
    public var soup:String = ""
    public var path:String = "/magic/apex/apex/"
    public var host:String = "https://fieldvisit.herokuapp.com"
//    public var host:String = "http://172.18.27.110:3000"
    public var params:Dictionary<String, String> = [:]
    public var endpoint:String = ""
    
    override init() {
        super.init()
        self.targetType = .custom
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
        if let soup:String = d[HerokuTargetConstants.kHerokuSyncTargetSoup] as! String? {
            self.soup = soup
        }
        if let params:Dictionary<String, String> = d[HerokuTargetConstants.kHerokuSyncTargetQueryParams] as! Dictionary<String, String>? {
            self.params = params
        }
    }
}


@objc(HerokuApexSyncUpTarget)
public class HerokuApexSyncUpTarget:HerokuBaseSyncUpTarget {
    
    override public func asDict() -> NSMutableDictionary! {
        let dict = super.asDict()
        dict?[kSFSyncTargetiOSImplKey] = "HerokuApexSyncUpTarget"
        dict?[HerokuTargetConstants.kHerokuSyncTargetSoup] = self.soup
        dict?[HerokuTargetConstants.kHerokuSyncTargetPath] = self.path
        dict?[HerokuTargetConstants.kHerokuSyncTargetEndpoint] = self.endpoint
        return dict!
    }
    
}

@objc(HerokuSFSyncUpTarget)
public class HerokuSFSyncUpTarget:HerokuBaseSyncUpTarget {
    private var id:String?
    
    override init() {
        super.init()
        self.path = "/magic/"
    }
    
    convenience init(dict: [AnyHashable:Any]!) {
        self.init()
        let d = dict as! Dictionary<String, AnyObject>
        
        let loweredParams = NSDictionary.toLowercasedKeysDictionary(d)
        if let id = loweredParams?[HerokuTargetConstants.kHerokuSyncTargetIdField] as? String? {
            self.id = id
        }
        
        if let path:String = loweredParams?[HerokuTargetConstants.kHerokuSyncTargetPath] as? String {
            self.path = path
        }
        if let host:String = loweredParams?[HerokuTargetConstants.kHerokuSyncTargetHost] as? String {
            self.host = host
        }
        if let endpoint:String = loweredParams?[HerokuTargetConstants.kHerokuSyncTargetEndpoint] as? String {
            self.endpoint = endpoint
        }
        if let soup:String = loweredParams?[HerokuTargetConstants.kHerokuSyncTargetSoup] as? String {
            self.soup = soup
        }
        if let params:Dictionary<String, String> = d[HerokuTargetConstants.kHerokuSyncTargetQueryParams] as! Dictionary<String, String>? {
            self.params = params
        }
    }
    
    override public func asDict() -> NSMutableDictionary! {
        let dict = super.asDict()
        dict?[kSFSyncTargetiOSImplKey] = "HerokuSFSyncUpTarget"
        dict?[HerokuTargetConstants.kHerokuSyncTargetSoup] = self.soup
        dict?[HerokuTargetConstants.kHerokuSyncTargetPath] = self.path
        dict?[HerokuTargetConstants.kHerokuSyncTargetEndpoint] = self.endpoint
        dict?[HerokuTargetConstants.kHerokuSyncTargetIdField] = self.id
        dict?[HerokuTargetConstants.kHerokuSyncTargetHost] = self.host
        dict?[HerokuTargetConstants.kHerokuSyncTargetQueryParams] = self.params
        return dict!
    }
    
    private func validStringDictionaryFrom(dict:Dictionary<AnyHashable, Any>) -> Dictionary<String, String> {
        var filtered:Dictionary<String, String> = [:]
        dict.forEach { (key, value) in
            if key as? String != nil && value as? String != nil {
                filtered[(key as! String).lowercased()] = value as! String
            }
        }
        return filtered
    }
    
    override public func create(onServer objectType: String!, fields: [AnyHashable : Any]!, completionBlock: SFSyncUpTargetCompleteBlock!, fail failBlock: SFSyncUpTargetErrorBlock!) {
        print("createOnServer: objectType: \(objectType), fields: \(fields)")
        var filtered:Dictionary<String, String> = self.validStringDictionaryFrom(dict: fields)
        
        if let endPointObject = self.params["recordType"] {
            filtered["recordType"] = endPointObject.lowercased() as String
        }
//        if let id = self.id {
//            filtered["id"] = id
//        }
        let mobileExternalId = filtered["mobileexternalid__c"]
        
//        if filtered["mobileexternalid__c"] != nil {
//            filtered.removeValue(forKey: "mobileexternalid__c")
//        }
        filtered.forEach { (key, value) in
            if key.contains("fv_account__r.") {
                filtered.removeValue(forKey: key)
            }
        }

        let path:String = self.path
        
        let request = SFRestRequest(method: .POST, path: self.path, queryParams: filtered)
        request.action.pathPrefix = ""
        request.requiresAuthentication = false
        if let host = URL(string: self.host) {
            request.action.baseURL = host
        }
        
        SFSmartSyncNetworkUtils.sendRequest(withSmartSyncUserAgent: request, fail: { (error) in
            failBlock(error)
        }) { (response) in
            
            if response is Dictionary<String, Any> {
                let dictionary = response as! Dictionary<String, Any>
                let lowercase = NSDictionary.toLowercasedKeysDictionary(dictionary)
                if let pg = (lowercase?["pgid"]) {
                    let pgNum = pg as! NSNumber
                    
                    completionBlock(["id":pgNum.stringValue as Any])
                    
                    // TODO: Need to find referencing children and update to point to the updated reference
                    
                    if let external = mobileExternalId {
                        let smartstore = SFSmartStore.sharedStore(withName: kDefaultSmartStoreName) as! SFSmartStore
                        let query = CSQueryBuilder.forSoupName(objectType.lowercased()).whereEqual("mobileexternalid__c", value: external)
                        let spec = SFQuerySpec.newSmartQuerySpec(query.build(), withPageSize:100)
                        let entries = try? smartstore.query(with: spec, pageIndex:0)
                        if let stored = entries?.first {
                            let recordArray = stored as! Array<Dictionary<String, Any>>
                            if let rec = recordArray.first {
                                var r = rec
                                r["pgid"] = pgNum.stringValue
                                let updated = smartstore.upsertEntries([r], toSoup: objectType.lowercased())
                                print("HerokuSyncUpTarget:create updated entries \(updated)")
                            }
                        }
                    }
                    
                } else {
                    let error = NSError(domain: "heroku", code: 100, userInfo: ["msg":"Missing postgress id"])
                    failBlock(error)
                }
            } else {
                let error = NSError(domain: "heroku", code: 100, userInfo: ["msg":"Invalid response type"])
                failBlock(error)
            }
        }
    }
    
    override public func update(onServer objectType: String!, objectId: String!, fields: [AnyHashable : Any]!, completionBlock: SFSyncUpTargetCompleteBlock!, fail failBlock: SFSyncUpTargetErrorBlock!) {
        
        var filtered:Dictionary<String, String> = self.validStringDictionaryFrom(dict: fields)
        
        if let endPointObject = self.params["recordType"] {
            filtered["recordType"] = endPointObject.lowercased() as String
        }
        if let id = self.id {
            filtered["id"] = id
        }
        var path:String = self.path
        print("request path: \(path)")
        let request = SFRestRequest(method: .PATCH, path: path, queryParams: filtered)
        request.action.pathPrefix = ""
        request.requiresAuthentication = false
        if let hostURL = URL(string: self.host) {
            request.action.baseURL = hostURL
        }
        
        print("request : \(request)")
        SFSmartSyncNetworkUtils.sendRequest(withSmartSyncUserAgent: request, fail: { [weak self] (error) in
            print(error)
            failBlock(error)
        }) { [weak self] (response) in
            print(response)
            completionBlock(nil)
        }
    }
    
    override public func delete(onServer objectType: String!, objectId: String!, completionBlock: SFSyncUpTargetCompleteBlock!, fail failBlock: SFSyncUpTargetErrorBlock!) {
        
        var path:String = self.path
        if let id = self.id {
            let idString = NSString(format: "%@", id) as String
            path = path.appending(idString)
        }
        if let endPointObject = self.params["recordType"] {
            let recordString = NSString(format: "?recordType=%@", endPointObject) as String
            path = path.appending(recordString)
        }
        
        let request = SFRestRequest(method: .DELETE, path: path, queryParams: nil)
        request.action.pathPrefix = ""
        request.requiresAuthentication = false
        if let hostURL = URL(string: self.host) {
            request.action.baseURL = hostURL
        }
        
        SFSmartSyncNetworkUtils.sendRequest(withSmartSyncUserAgent: request, fail: { [weak self] (error) in
            print(error)
            failBlock(error)
        }) { [weak self] (response) in
            print(response)
            completionBlock(nil)
        }
    }
}





