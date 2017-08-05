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

#import "MSALResult.h"
#import "MSALUIBehavior.h"
#import "MSALUser.h"
#import "MSALTelemetry.h"
#import "MSALError.h"
#import "MSALPublicClientApplication.h"
#import "MSAL.h"
#import "MSALLogger.h"
#import "MSALPublicRTApplication.h"

FOUNDATION_EXPORT double MSALVersionNumber;
FOUNDATION_EXPORT const unsigned char MSALVersionString[];

