#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SFRestAPI+Blocks.h"
#import "SFRestAPI+Files.h"
#import "SFRestAPI+QueryBuilder.h"
#import "SFRestAPI.h"
#import "SFRestAPISalesforceAction.h"
#import "SFRestRequest.h"
#import "SalesforceRestAPI.h"

FOUNDATION_EXPORT double SalesforceRestAPIVersionNumber;
FOUNDATION_EXPORT const unsigned char SalesforceRestAPIVersionString[];

