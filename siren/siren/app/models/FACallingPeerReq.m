//
//  FACallingPeerReq.m
//  siren
//
//  Created by Zeus on 14-4-26.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FACallingPeerReq.h"

@implementation FACallingPeerReq
- (id)head {
  return @{
    kToken : [self token],
    kSeq : [FASeqGen seq],
    kStatus : @(0),
    kSignalType : @(FASignalTypeCallingPeer)
  };
}

- (id)body {
  return @{
    kPeerAccount : self.myAccount,
    kPeerInterIP : self.myInterIP,
    kPeerInterPort : @(self.myInterPort),
    kPeerLocalIP : self.myLocalIP,
    kPeerLocalPort : @(self.myLocalPort),
    kPeerSessionID : @(self.mySessionID),
    kMyAccount : self.peerAccount,
    kMySessionID : @(self.peerSessionID),
    kRelayIP : self.relayIP,
    kRelayPort : @(self.relayPort),
  };
}
- (id)dictionary {
  return @{ kHead : [self head], kBody : [self body] };
}
@end
