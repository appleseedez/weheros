//
//  FACore.h
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FAViewModel.h"
#import "FATCPConnection.h"
#import "FAEngine.h"
#import "FAReachability.h"
@interface FACore : FAViewModel <IFACore>
// the wrapper of the RTC SDK.
@property(nonatomic, strong, readonly) FAEngine *engine;
// the control connection
@property(nonatomic, strong, readonly) FATCPConnection *tcpConnection;
@property(nonatomic, strong, readonly) FAReachability *reach;
// use this when core need to reclaim all the resource.
- (void)dispose;
@end

typedef NS_ENUM(NSInteger, FAConnectionActionFlag) {
  FAConnectionActionFlagNeedReconnect = 1, FAConnectionActionFlagDoNothing = 0,
  FAConnectionActionFlagNotReachable = -1
};
typedef NS_ENUM(NSInteger, FASessionState) { FASessionStateIdle = 0,
                                             FASessionStateCalling = 1,
                                             FASessionStateAnswering = 2,
                                             FASessionStateInSession = 3,
                                             FASessionStateEnding = 4 };