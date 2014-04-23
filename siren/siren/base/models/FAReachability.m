//
//  FAReachablity.m
//  siren
//
//  Created by Zeus on 14-4-8.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FAReachability.h"
@interface FAReachability ()
@property(nonatomic) Reachability *reach;
@end

@implementation FAReachability

+ (instancetype)shared {
  static FAReachability *_instance = nil;
  static dispatch_once_t onceTokenReachability;
  dispatch_once(&onceTokenReachability, ^{ _instance = [FAReachability new]; });
  return _instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    self.reachStatus = @(NO);
    NSString *host = ReachabilityHost;
    self.reach = [Reachability reachabilityWithHostname:host];
    // The model update its property by observe the Notification of Reachability
    // object.
    RAC(self, reachStatus,
        @(NO)) = [[[[NSNotificationCenter defaultCenter]
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
