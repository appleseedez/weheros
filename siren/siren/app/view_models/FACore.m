//
//  FACore.m
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FACore.h"
@interface FACore ()
// tcp data subscription.
@property(nonatomic, strong) RACDisposable *tcpDataSubscription;
// tcp conncetion status subscription
@property(nonatomic, strong) RACDisposable *tcpConnectionStatusSubscription;
// engine subscription.
@property(nonatomic, strong) RACDisposable *engineSubscription;
@end

@implementation FACore

#pragma mark - life cycle

- (instancetype)init {
  self = [super init];
  if (self) {
    [self setupTCPDataSubscription];
    [self setupTCPConnectionStatusSubscription];
    [self setupEngineSubscription];
  }
  return self;
}

- (void)dealloc {
  // when the core is tear down, dispose the subscription.
  [self dispose];
}

#pragma mark - logic

- (void)setupTCPDataSubscription {
    RACSignal *tcpSignal =
    [[RACObserve(self.tcpConnection, response) filter:^BOOL(id value) {
      return nil != value;
    } ] map:^id(id<IFAResponse> res) {
      NSDictionary *resData = [[res body] valueForKey:@"payload"];
      // data process here.
      // put the logic in the map block instead of subscribNext will get rid of
      // the self cycle problem.
      [self routeFromData:resData];
      return resData;
    }];
    self.tcpDataSubscription =
    [tcpSignal subscribeNext:^(NSDictionary * payload) {
      // subscribeNext nee no logic just for debug.
      NSLog(@"recevied payload :%@", payload);
    }];
}
/**
 combine signal to determine whether reconnect is needed.
 1. reachability is false then no need to do reconnect. maybe just tip the
 user.
 2.otherwise reconnect is needed. because this signal indecates that
 network has changed but still reachable(reachStatus signal),or socket
 just been disconnected (tcpConnection signal).
 **/
- (void)setupTCPConnectionStatusSubscription {
  RACSignal *tcpConnectionStatusSignal =
    [[RACSignal combineLatest:@[ RACObserve(self.tcpConnection, status), RACObserve(self.reach, reachStatus)] reduce:^id(NSNumber* connectionStatus,NSNumber* reachabilityStatus){

    NSLog(@"what is the reduce :%@,%@", connectionStatus, reachabilityStatus);
    if (![reachabilityStatus boolValue]) {
      return @(FAConnectionActionFlagNotReachable);
    } else if ([connectionStatus integerValue] ==
               FAConnectionStatusDisconnected) {
      return @(FAConnectionActionFlagNeedReconnect);
    } else {
      return @(FAConnectionActionFlagDoNothing);
    }
  }] map:^id(NSNumber* stat) {
    if ([stat integerValue] == FAConnectionActionFlagNeedReconnect) {
      NSLog(@"not connect,be able to connect to server");
      [self.tcpConnection reconnect];
    } else if ([stat integerValue] == FAConnectionActionFlagDoNothing) {
      NSLog(@"still connected. Nothing to do!");
    } else {
      // TODO: tip the user
      NSLog(@"TIP:Current Network is not reachable. Please check.");
      [self.tcpConnection disconnect];
    }
    return stat;
  }] ;
    self.tcpConnectionStatusSubscription = [tcpConnectionStatusSignal
        subscribeNext:^(NSNumber *
                        stat) {
      NSLog(@"get the tcp connect status code "
             "{FAConnectionActionFlagNeedReconnect:1,"
             "FAConnectionActionFlagDoNothing:0"
             "FAConnectionActionFlagNotConnected:-1} "
             "value is :%@",
            stat);
    }];
}

- (void)setupEngineSubscription {
  RACSignal *engineSignal = nil;
  // should handle engine signal;
  [engineSignal subscribeNext:^(id x) {
                                 //
                               }];
}

- (void)routeFromData:(NSDictionary *)data {
}

- (void)dispose {
  // when the core is tear down, dispose the subscription.
  [self.tcpDataSubscription dispose];
  [self.tcpConnectionStatusSubscription dispose];
  [self.engineSubscription dispose];
  [self.tcpConnection disconnect];
}
#pragma mark - accessors
@synthesize reach = _reach;
- (FAReachability *)reach {
  if (nil == _reach) {
    _reach = [FAReachability shared];
  }
  return _reach;
}

@synthesize tcpConnection = _tcpConnection;
- (FATCPConnection *)tcpConnection {
  if (nil == _tcpConnection) {
    _tcpConnection = [FATCPConnection new];
  }
  return _tcpConnection;
}

@synthesize engine = _engine;
- (FAEngine *)engine {
  if (nil == _engine) {
    _engine = [FAEngine new];
  }
  return _engine;
}
@end
