//
//  ApexSyncUpTarget.h
//  CSMobileBase
//
//  Created by Mayank Bhayana on 10/01/19.
//

#ifndef ApexSyncUpTarget_h
#define ApexSyncUpTarget_h


#endif /* ApexSyncUpTarget_h */

#import <Foundation/Foundation.h>
#import <SmartSync/SmartSync.h>

NSString * const kApexSyncUpTargetSoup = @"soup";
NSString * const kApexSyncUpTargetPath = @"path";
NSString * const kApexSyncUpTargetEndpoint = @"endpoint";

@interface ApexSyncUpTarget : SFSyncUpTarget

@property (nonatomic, strong) NSString *soup;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *endpoint;

+ (ApexSyncUpTarget *)newSyncTarget:(NSString *)soup path:(NSString *)path;

@end
