//
//  FATCPConnectionSpec.m
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright 2014年 weheros. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "FATCPConnection.h"
#import "FARequest.h"
#import "FAConnectionReq.h"
SPEC_BEGIN(FATCPConnectionSpec)

describe(@"FATCPConnection", ^{
  context(@"given an request #112.124.110.206:1337#", ^{
    FATCPConnection *tcpConnection = [FATCPConnection new];
    FAConnectionReq *connectRequest = [FAConnectionReq new];
    connectRequest.gateway =
        [FAGateway gatewayWithHost:@"112.124.110.206" port:1337];
    it(@"should be connected to that endpoint", ^{
      [tcpConnection connectWithRequest:connectRequest];
      sleep(3);
      [[theValue([[tcpConnection status] integerValue]) should]
          equal:theValue(FAConnectionStatusConnected)];
    });
  });
});

SPEC_END
