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
  [self.tcpDataSubscription dispose];
  [self.tcpConnectionStatusSubscription dispose];
  [self.engineSubscription dispose];
}

#pragma mark - logic

- (void)setupTCPDataSubscription {
    RACSignal *tcpSignal =
    [RACObserve(self.tcpConnection, response) map:^id(id<IFAResponse> res) {
      return [res body];
    }];
    self.tcpDataSubscription =
    [tcpSignal subscribeNext:^(NSDictionary * payload) {
      NSLog(@"recevied payload :%@", payload);
    }];
}

- (void)setupTCPConnectionStatusSubscription {
  // combine signal to determine whether reconnect is needed.
  RACSignal *tcpConnectionStatusSignal =
    [RACSignal combineLatest:@[
                               RACObserve(self.tcpConnection, status),
                               RACObserve(self.reach, reachStatus)
                               ]
                      reduce:^id(NSNumber* connectionStatus,NSNumber* reachabilityStatus){
    // 1. reachability is false then no need to do reconnect. maybe just tip the
    // user.
    // 2.otherwise reconnect is needed. because this signal indecates that
    // network has changed but still reachable(reachStatus signal),or socket
    // just been disconnected (tcpConnection signal).
    if (![reachabilityStatus boolValue]) {
      return @(FAConnectionActionFlagNotConnected);
    } else {
      return @(FAConnectionActionFlagNeedReconnect);
    }
  }];

  @weakify(self);
  self.tcpConnectionStatusSubscription =
      [tcpConnectionStatusSignal subscribeNext:^(NSNumber * stat) {
    @strongify(self);
    if ([stat integerValue] == FAConnectionActionFlagNeedReconnect) {
      [self.tcpConnection reconnect];
    } else {
      // TODO: tip the user
      NSLog(@"TIP:Current Network is not reachable. Please check.");
    }
  }];
}

- (void)setupEngineSubscription {
  RACSignal *engineSignal = nil;
  // should handle engine signal;
  [engineSignal subscribeNext:^(id x) {
                                 //
                               }];
}

#pragma mark - accessors
@synthesize reach = _reach;
- (FAReachability *)reach {
  _reach = [FAReachability shared];
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
