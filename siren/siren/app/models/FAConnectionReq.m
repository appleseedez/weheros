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
    //    kToken : self.token,
    //    kSignalType : self.signalType,
    //    kStatus : @(0),
    //    kSeq : @([FASeqGen seq])
  };
}

- (id)body {
  return @{ @"host" : self.gateway.host, @"port" : @(self.gateway.port) };
}
@end
