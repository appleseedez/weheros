//
//  FACoreSpec.m
//  siren
//
//  Created by Zeus on 14-4-23.
//  Copyright 2014年 weheros. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "FACore.h"
#import "FAReachability.h"
#import "FAStartSessionReq.h"
SPEC_BEGIN(FACoreSpec)

describe(@"FACore", ^{
  context(@"Core connection", ^{
    FACore *core = [FACore new];
    // first given the condition that the reachability is bad
    core.reach.reachStatus = @(NO);
    it(@"should setup ok.", ^{
      [[core.tcpConnection shouldNot] beNil];
      [[core.reach shouldNot] beNil];
    });
    it(@"should not connected.", ^{
      [[theValue([core.tcpConnection.status integerValue]) should]
          equal:theValue(FAConnectionStatusDisconnected)];
    });
    it(@"should connect sucesss when the reachablity is good", ^{
      core.reach.reachStatus = @(YES);
      sleep(3);
      [[theValue([core.tcpConnection.status integerValue]) should]
          equal:theValue(FAConnectionStatusConnected)];
    });
    it(@"should not connect when the reachablity is bad", ^{
      core.reach.reachStatus = @(NO);
      sleep(3);
      [[theValue([core.tcpConnection.status integerValue]) should]
          equal:theValue(FAConnectionStatusDisconnected)];
    });
    it(@"should reconnect when the reachability is good again", ^{
      core.reach.reachStatus = @(YES);
      sleep(3);
      [[theValue([core.tcpConnection.status integerValue]) should]
          equal:theValue(FAConnectionStatusConnected)];
    });
    it(@"should reconnect as long as  the reachability is good", ^{
      core.reach.reachStatus = @(YES);
      core.tcpConnection.status = @(FAConnectionStatusDisconnected);
      sleep(3);
      [[theValue([core.tcpConnection.status integerValue]) should]
          equal:theValue(FAConnectionStatusConnected)];
    });
    it(@"should not reconnect and remain disconnected when core dispose the "
        "tcpConnectionSubscription",
       ^{
      core.reach.reachStatus = @(YES);
      [core dispose];
      sleep(3);
      [[theValue([core.tcpConnection.status integerValue]) should]
          equal:theValue(FAConnectionStatusDisconnected)];
    });
    afterEach (^{ [core.tcpConnection disconnect]; });
  });
  context(@"Core send & recevie data", ^{
    FACore *core = [FACore new];
    core.reach.reachStatus = @(YES);
    it(@"send start session req", ^{
      sleep(3);
      FAStartSessionReq *startSessionReq = [FAStartSessionReq new];
      startSessionReq.peerAccount = @"liuyang";
      startSessionReq.myAccount = @"appleseedez";
      [core dial:startSessionReq];
      sleep(3);
    });
  });
});

SPEC_END
