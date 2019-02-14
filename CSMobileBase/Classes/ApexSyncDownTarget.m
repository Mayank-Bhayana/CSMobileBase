//
//  ApexSyncDownTarget.m
//  CSMobileBase
//
//  Created by Mayank Bhayana on 10/01/19.
//

#import "ApexSyncDownTarget.h"

@implementation ApexSyncDownTarget

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super initWithDict:dict];
    if (self) {
        self.queryType = SFSyncDownTargetQueryTypeCustom;
        self.path = dict[kApexSyncDownTargetPath];
        self.queryParams = dict[kApexSyncDownTargetQueryParams];
        self.endpoint = dict[kApexSyncDownTargetEndpoint];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.queryType = SFSyncDownTargetQueryTypeCustom;
    }
    return self;
}

- (void)startFetch:(SFSmartSyncSyncManager*)syncManager maxTimeStamp:(long long)maxTimeStamp errorBlock:(SFSyncDownTargetFetchErrorBlock)errorBlock completeBlock:(SFSyncDownTargetFetchCompleteBlock)completeBlock {
    
    __weak ApexSyncDownTarget *weakSelf = self;
    
    SFRestRequest* request = [SFRestRequest requestWithMethod:SFRestMethodGET path:self.path queryParams:self.queryParams];
    [request setEndpoint:self.endpoint];
    
    [SFSmartSyncNetworkUtils sendRequestWithSmartSyncUserAgent:request failBlock:errorBlock completeBlock:^(id response) {
        if ([response isKindOfClass:[NSArray class]]) {
            NSArray *array = (NSArray *)response;
            weakSelf.totalSize = array.count;
            completeBlock(array);
        } else if ([response isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dictionary = (NSDictionary *)response;
            if ([dictionary valueForKey:@"Id"] != (NSString *)[NSNull null]) {
                weakSelf.totalSize = 1;
                completeBlock(@[dictionary]);
            } else {
                NSError *error = [NSError errorWithDomain:@"apex" code:100 userInfo:@{@"msg" : @"Missing salesforce id"}];
                errorBlock(error);
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"apex" code:100 userInfo:@{@"msg" : @"Invalid response type"}];
            errorBlock(error);
        }
    }];
}

- (NSMutableDictionary *)asDict {
    NSMutableDictionary *dict = [super asDict];
    dict[kSFSyncTargetiOSImplKey] = @"ApexSyncDownTarget";
    dict[kApexSyncDownTargetPath] = self.path;
    dict[kApexSyncDownTargetQueryParams] = self.queryParams;
    dict[kApexSyncDownTargetEndpoint]  = self.endpoint;
    return dict;
}

+ (ApexSyncDownTarget *)newSyncTarget:(NSString *)path queryParams:(NSDictionary *)queryParams {
    NSDictionary *dictionary = @{kApexSyncDownTargetPath : path, kApexSyncDownTargetQueryParams : queryParams};
    return [[ApexSyncDownTarget alloc] initWithDict:dictionary];
}

@end
