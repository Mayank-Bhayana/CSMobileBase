//
//  ApexSyncDownTarget.h
//  CSMobileBase
//
//  Created by Mayank Bhayana on 10/01/19.
//

#ifndef ApexSyncDownTarget_h
#define ApexSyncDownTarget_h


#endif  ApexSyncDownTarget_h

#import <Foundation/Foundation.h>
#import <SmartSync/SmartSync.h>

NSString * const kApexSyncDownTargetPath = @"path";
NSString * const kApexSyncDownTargetQueryParams = @"queryParams";
NSString * const kApexSyncDownTargetEndpoint = @"endpoint";

@interface ApexSyncDownTarget : SFSyncDownTarget

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSDictionary *queryParams;
@property (nonatomic, strong) NSString *endpoint;

+ (ApexSyncDownTarget *)newSyncTarget:(NSString *)path queryParams:(NSDictionary *)queryParams;

@end
