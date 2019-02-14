//
//  ApexSyncUpTarget.m
//  CSMobileBase
//
//  Created by Mayank Bhayana on 10/01/19.
//

#import "ApexSyncUpTarget.h"

@implementation ApexSyncUpTarget

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super initWithDict:dict];
    if (self) {
        self.targetType = SFSyncUpTargetTypeCustom;
        self.soup = dict[kApexSyncUpTargetSoup];
        self.path = dict[kApexSyncUpTargetPath];
        self.endpoint = dict[kApexSyncUpTargetEndpoint];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.targetType = SFSyncUpTargetTypeCustom;
    }
    return self;
}

- (void)createOnServer:(NSString*)objectType fields:(NSDictionary*)fields completionBlock:(SFSyncUpTargetCompleteBlock)completionBlock failBlock:(SFSyncUpTargetErrorBlock)failBlock {
    SFRestRequest* request = [SFRestRequest requestWithMethod:SFRestMethodPOST path:self.path queryParams: fields];
    [request setEndpoint:self.endpoint];
    [SFSmartSyncNetworkUtils sendRequestWithSmartSyncUserAgent:request failBlock: failBlock completeBlock:^(id response) {
        NSNumber *objectId = [response objectForKey:@"Id"];
        if (objectId != nil) {
            completionBlock(@{@"id" : objectId});
        } else {
            failBlock(nil);
        }
    }];
}

- (void)updateOnServer:(NSString*)objectType objectId:(NSString*)objectId fields:(NSDictionary*)fields completionBlock:(SFSyncUpTargetCompleteBlock)completionBlock failBlock:(SFSyncUpTargetErrorBlock)failBlock {
    NSString *path = [self.path stringByAppendingPathComponent:objectId];
    SFRestRequest* request = [SFRestRequest requestWithMethod:SFRestMethodPATCH path:path queryParams: fields];
    [request setEndpoint:self.endpoint];
    [SFSmartSyncNetworkUtils sendRequestWithSmartSyncUserAgent:request failBlock: failBlock completeBlock:completionBlock];
}

- (void)deleteOnServer:(NSString*)objectType objectId:(NSString*)objectId completionBlock:(SFSyncUpTargetCompleteBlock)completionBlock failBlock:(SFSyncUpTargetErrorBlock)failBlock {
    NSString *path = [self.path stringByAppendingPathComponent:objectId];
    SFRestRequest* request = [SFRestRequest requestWithMethod:SFRestMethodDELETE path:path queryParams: nil];
    [request setEndpoint:self.endpoint];
    [SFSmartSyncNetworkUtils sendRequestWithSmartSyncUserAgent:request failBlock: failBlock completeBlock:completionBlock];
}

- (NSMutableDictionary *)asDict {
    NSMutableDictionary *dict = [super asDict];
    dict[kSFSyncTargetiOSImplKey] = @"ApexSyncUpTarget";
    dict[kApexSyncUpTargetSoup] = self.soup;
    dict[kApexSyncUpTargetPath] = self.path;
    dict[kApexSyncUpTargetEndpoint] = self.endpoint;
    return dict;
}

+ (ApexSyncUpTarget *)newSyncTarget:(NSString *)soup path:(NSString *)path {
    NSDictionary *dictionary = @{kApexSyncUpTargetSoup : soup, kApexSyncUpTargetPath : path};
    return [[ApexSyncUpTarget alloc] initWithDict:dictionary];
}

@end

