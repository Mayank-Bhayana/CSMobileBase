//
//  NSDictionary+LowercasedKeys.h
//  Pods
//
//  Created by Nicholas McDonald on 3/30/17.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (LowercasedKeys)

+ (NSDictionary<NSString *, id> *)toLowercasedKeysDictionary:(NSDictionary<NSString *, id> *)from;
+ (NSArray *)recursivelyFindAndLowercaseDictionaryKeys:(NSArray *)inArray;

@end
