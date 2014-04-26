//
//  FAStartSessionReq.m
//  siren
//
//  Created by Zeus on 14-4-24.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FAStartSessionReq.h"

@implementation FAStartSessionReq
- (id)head {
  return @{
    kToken : [self token],
    kSeq : [FASeqGen seq],
    kStatus : @(0),
    kSignalType : @(FASignalTypeStartSessionRequest)
  };
}

- (id)body {
  return @{ kPeerAccount : self.peerAccount, kMyAccount : self.myAccount };
}
- (id)dictionary {
  return @{ kHead : [self head], kBody : [self body] };
}

@end
