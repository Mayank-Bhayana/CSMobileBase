//
//  NSDictionary+LowercasedKeys.m
//  Pods
//
//  Created by Nicholas McDonald on 3/30/17.
//
//

#import "NSDictionary+LowercasedKeys.h"

@implementation NSDictionary (LowercasedKeys)

+ (NSDictionary<NSString *, id> *)toLowercasedKeysDictionary:(NSDictionary<NSString *, id> *)from {
    NSArray *lowercaseObjects = [NSDictionary recursivelyFindAndLowercaseDictionaryKeys:[from allValues]];
    
    NSArray *keys = [from allKeys];
    NSMutableArray *lowercaseKeys = [NSMutableArray arrayWithCapacity:[keys count]];
    [keys enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [lowercaseKeys addObject:[obj lowercaseString]];
    }];
    NSMutableDictionary *lowerCasedDictionary = [NSMutableDictionary dictionaryWithObjects:lowercaseObjects forKeys:lowercaseKeys];
    
    return [NSDictionary dictionaryWithDictionary:lowerCasedDictionary];
}

+ (NSArray *)recursivelyFindAndLowercaseDictionaryKeys:(NSArray *)inArray {
    NSMutableArray *lowercasedObjects = [NSMutableArray arrayWithCapacity:[inArray count]];
    [inArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *objDict = (NSDictionary *)obj;
            [lowercasedObjects addObject:[NSDictionary toLowercasedKeysDictionary:objDict]];
        } else if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *arrayObj = (NSArray *)obj;
            [lowercasedObjects addObject:[self recursivelyFindAndLowercaseDictionaryKeys:arrayObj]];
        } else {
            [lowercasedObjects addObject:obj];
        }
    }];
    return [NSArray arrayWithArray:lowercasedObjects];
}

@end
