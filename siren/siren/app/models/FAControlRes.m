//
//  FAControlRes.m
//  siren
//
//  Created by Zeus on 14-4-18.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FAControlRes.h"

@implementation FAControlRes
- (id)head {
  return @{};
}
- (id)body {
  return @{ @"payload" : [FAModel data2Dic:self.binPayLoad] };
}
@end
