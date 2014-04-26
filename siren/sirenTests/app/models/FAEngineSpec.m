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
          equal:theValue(FAEngineStateStarted)];
      // 2. setup the network for udp pkg
      [sut setupNetwork];
      [[theValue([[sut engineState] integerValue]) should]
          equal:theValue(FAEngineStateNetworkReady)];
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
      [sut mute];
      [[theValue([[sut engineState] integerValue]) should]
          equal:theValue(FAEngineStateSoundMute)];
    });

    it(@"should be unmute", ^{
      // when
      [sut unmute];
      [[theValue([[sut engineState] integerValue]) should]
          equal:theValue(FAEngineStateSoundUnMute)];
    });
    it(@"should enableSpeaker", ^{
      [sut enableSpeaker];

      [[theValue([[sut engineState] integerValue]) should]
          equal:theValue(FAEngineStateSpeakerEabled)];
    });
    it(@"should disableSpeaker", ^{
      [sut disableSpeaker];
      [[theValue([[sut engineState] integerValue]) should]
          equal:theValue(FAEngineStateSpeakerDisabled)];
    });
  });
  context(@"engine p2p process", ^{
    FAEngine *sut = [FAEngine new];
    it(@"should start P2P process", ^{
      [sut startP2P];
      [[theValue([[sut engineState] integerValue]) should]
          equal:theValue(FAEngineStateP2PInProcess)];
    });
  });
});

SPEC_END
