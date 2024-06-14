//
//  WCMacros.h
//  QCDeviceCenter
//
//

#ifndef WCMacros_h
#define WCMacros_h

#import <CocoaLumberjack/CocoaLumberjack.h>

#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel ddLogLevel = DDLogLevelInfo;
#endif

#endif /* WCMacros_h */

