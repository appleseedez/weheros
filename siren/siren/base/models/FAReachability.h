//
//  FAReachablity.h
//  siren
//
//  Created by Zeus on 14-4-8.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FAModel.h"

@interface FAReachability : FAModel
@property(nonatomic) NSNumber *reachStatus;
@property(nonatomic) NetworkStatus networkStatus;
+ (instancetype)shared;
- (void)dispose;
- (void)startMonitor;
- (void)stopMonitor;
@end
