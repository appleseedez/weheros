//
//  FAReachablity.m
//  siren
//
//  Created by Zeus on 14-4-8.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FAReachability.h"
static FAReachability *_instance;
@interface FAReachability ()
@property(nonatomic) Reachability *reach;
@end

@implementation FAReachability
+ (void)initialize {
  if (self == [FAReachability class]) {
    _instance = [FAReachability new];
  }
}

+ (instancetype)shared {
  return _instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    NSString *host = ReachabilityHost;
    self.reach = [Reachability reachabilityWithHostname:host];
    // The model update its property by observe the Notification of Reachability
    // object.
    RAC(self, reachStatus,
        @(0)) = [[[[NSNotificationCenter defaultCenter]
                      rac_addObserverForName:kReachabilityChangedNotification
                                      object:nil]
                     takeUntil:[self rac_willDeallocSignal]]
        map:^id(NSNotification * note) {
      // i dont care if this connection is Wifi or WLan.
      Reachability *result = (Reachability *)note.object;
      return @([result isReachable]);
    }];
    [self startMonitor];
  }
  return self;
}

- (void)dispose {
  // do nothing
}
- (void)startMonitor {
  [self.reach startNotifier];
}
- (void)stopMonitor {
  [self.reach stopNotifier];
}

@end
