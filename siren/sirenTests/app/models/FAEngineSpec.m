//
//  FAEngineSpec.m
//  siren
//
//  Created by Zeus on 14-4-20.
//  Copyright 2014年 weheros. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "FAEngine.h"

SPEC_BEGIN(FAEngineSpec)

describe(@"FAEngine", ^{
  context(@"given a instance", ^{
    FAEngine *sut = [FAEngine new];
    it(@"should exist", ^{ [[theValue([sut testSingleton]) should] beYes]; });
  });
  context(@"engine state", ^{
    FAEngine *sut = [FAEngine new];
    it(@"should in the right state", ^{
      // 1. start the engine when init fiinish
      [[theValue([[sut engineState] integerValue]) should]
          equal:theValue(FAEngineStateDidStart)];
      // 2. setup the network for udp pkg
      sut.engineState = @(FAEngineStateNetworkShouldReady);
      [[theValue([[sut engineState] integerValue]) should]
          equal:theValue(FAEngineStateNetworkDidReady)];
    });
           
#if HAS_NET // not have connection
    // this is interesting!
    it(@"should get local ip address", ^{
      [[[[sut class] getIpLocally:kNetInterfaceCellular
                        ipVersion:4] shouldNot] beNil];
    });
#else
    it(@"should not get local ip address", ^{
      [[[[sut class] getIpLocally:kNetInterfaceWIFI ipVersion:4] should] beNil];
    });
#endif
  });
  context(@"engine function", ^{
    // given
    FAEngine *sut = [FAEngine new];

    it(@"should be mute", ^{
      // when
      sut.engineState = @(FAEngineStateSoundShouldMute);
      [[theValue([[sut engineState] integerValue]) should]
          equal:theValue(FAEngineStateSoundDidMute)];
    });

    it(@"should be unmute", ^{
      // when
      sut.engineState = @(FAEngineStateSoundShouldUnmute);
      [[theValue([[sut engineState] integerValue]) should]
          equal:theValue(FAEngineStateSoundDidUnmute)];
    });
    it(@"should enableSpeaker", ^{
      sut.engineState = @(FAEngineStateSpeakerShouldEnable);
      [[theValue([[sut engineState] integerValue]) should]
          equal:theValue(FAEngineStateSpeakerDidEable)];
    });
    it(@"should disableSpeaker", ^{
      sut.engineState = @(FAEngineStateSpeakerShouldDisable);
      [[theValue([[sut engineState] integerValue]) should]
          equal:theValue(FAEngineStateSpeakerDidDisable)];
    });
  });
  context(@"engine p2p process", ^{
    FAEngine *sut = [FAEngine new];
    it(@"should start P2P process", ^{
      sut.engineState = @(FAEngineStateShouldStartP2P);
      [[theValue([[sut engineState] integerValue]) should]
          equal:theValue(FAEngineStateP2PInProcess)];
      sleep(30);

      [[theValue([[sut engineState] integerValue]) should]
          equal:theValue(FAEngineStateP2PDidFail)];
    });
  });
});

SPEC_END
