//
//  FAConnectionReq.m
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FAConnectionReq.h"

@implementation FAConnectionReq
- (id)head {
  return @{
    @"token" : self.token,
    @"type" : self.signalType,
    @"status" : self.status,
    @"seq" : @(1)
  };
}

- (id)body {
  return @{ @"host" : self.gateway.host, @"port" : @(self.gateway.port) };
}
@end
