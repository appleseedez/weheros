//
//  FAEngine.m
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FAEngine.h"
#import "weheroSDK/AVInterface.hh"

UIView *_pview_local;
@interface FAEngine ()
// current inter IP
@property(nonatomic, copy) NSString *myCurrentInterIP;
@property(nonatomic) NSUInteger myLocalPort;
@property(nonatomic) dispatch_queue_t p2pQueue;
@end
@implementation FAEngine
#pragma mark - engine life
- (instancetype)init {
  self = [super init];
  if (self) {
    self.engineState = @(FAEngineStateShutdown);
    [self startEngine];
  }
  return self;
}

/**
 *  when the media init finish. the engine is started
 */
- (void)startEngine {
  bool ret = [[self class] sharedAPI]->MediaInit();
  if (ret) {
    self.engineState = @(FAEngineStateStarted);
  }
}
- (void)shutDownEngine {
  bool ret = [[self class] sharedAPI]->Terminate();
  if (ret) {
    self.engineState = @(FAEngineStateShutdown);
  }
}

/**
 *  the network is for the p2p tunneling. all about the udp pkg
 */
- (void)setupNetwork {
  self.myLocalPort = LocalBasePort + (++_localPortSuffix) % 9;
  bool ret = [[self class] sharedAPI]->OpenNetWork(self.myLocalPort);
  if (ret) {
    self.engineState = @(FAEngineStateNetworkReady);
  }
}
- (void)closeNetwork {
  bool ret = [[self class] sharedAPI]->CloseNetWork();
  if (ret) {
    self.engineState = @(FAEngineStateNetworkClosed);
  }
}

#pragma mark - engine function
- (void)openCamera {
}
- (void)closeCamera {
}
- (void)mute {
  // TODO: SetMuteEnable should have return type
  [[self class] sharedAPI]->SetMuteEnble(MTVoe, false);
  self.engineState = @(FAEngineStateSoundMute);
}
- (void)unmute {
  [[self class] sharedAPI]->SetMuteEnble(MTVoe, true);
  self.engineState = @(FAEngineStateSoundUnMute);
}
- (void)enableSpeaker {
  NSError *error = nil;
  [[AVAudioSession sharedInstance] setActive:YES error:&error];
  [[AVAudioSession sharedInstance]
      setCategory:AVAudioSessionCategoryPlayAndRecord
      withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
            error:&error];
  if (nil == error) {
    self.engineState = @(FAEngineStateSpeakerEabled);
  }
}
- (void)disableSpeaker {
  NSError *error = nil;
  [[AVAudioSession sharedInstance] setActive:YES error:&error];
  [[AVAudioSession sharedInstance]
      setCategory:AVAudioSessionCategoryPlayAndRecord
      withOptions:AVAudioSessionCategoryOptionDuckOthers
            error:&error];
  if (nil == error) {
    self.engineState = @(FAEngineStateSpeakerDisabled);
  }
}
- (void)startP2P {
  self.engineState = @(FAEngineStateP2PInProcess);
}
- (void)stopP2P {
}
// get the interIP & port, localIP & port for the negotiation data struction
- (RACSignal *)fetchParamsForSessionWithProbeIP:(NSString *)probeIP
                                      probePort:(NSUInteger)probePort
                                        bakPort:(NSUInteger)bakPort {
  RACReplaySubject *subject = [RACReplaySubject subject];
  // need the network be setup;
  [self setupNetwork];
  // get the localIP & port;
  NSString *localIP = [FAModel getIpLocally:kNetInterfaceWIFI ipVersion:4];
  if (nil == localIP) {
    localIP = [FAModel getIpLocally:kNetInterfaceCellular ipVersion:4];
    if (localIP == nil) {
      localIP = BLANK_STRING;
    }
  }

  char self_inter_ip[16];
  uint16_t self_inter_port;
  NSString *interIP = BLANK_STRING;
  //获取本机外网ip和端口
  // 1st time
  NSLog(@"use backport:%d for the 1st get", bakPort);
  [[self class] sharedAPI]->GetSelfInterAddr([probeIP UTF8String], bakPort,
                                             self_inter_ip, self_inter_port);
  // 2nd time
  NSLog(@"use probeport:%d for the 2nd get", probePort);
  int ret = [[self class] sharedAPI]->GetSelfInterAddr([probeIP UTF8String],
                                                       probePort, self_inter_ip,
                                                       self_inter_port);
  if (ret != 0) {
    interIP = BLANK_STRING;
  } else {
    interIP = [NSString stringWithUTF8String:self_inter_ip];
  }
  [subject sendNext:@{
                      @"localIP" : localIP,
                      @"localPort" : @(self.myLocalPort),
                      @"interIP" : interIP,
                      @"interPort" : @(self_inter_port)
                    }];
  [subject sendCompleted];
  return subject;
}
- (RACSignal *)prepareForSessionWithProbeIP:(NSString *)probeIP
                                  probePort:(NSUInteger)probePort
                                    bakPort:(NSUInteger)bakPort {

  return [self fetchParamsForSessionWithProbeIP:probeIP
                                      probePort:probePort
                                        bakPort:bakPort];
}
#pragma mark - accessors
+ (CAVInterfaceAPI *)sharedAPI {
  static CAVInterfaceAPI *_api = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ _api = new CAVInterfaceAPI(); });
  return _api;
}

@synthesize p2pQueue = _p2pQueue;
- (dispatch_queue_t)p2pQueue {
  const NSString *p2pQueueTag = @"com.weheros.p2pQueue";
  if (nil == _p2pQueue) {
    _p2pQueue =
        dispatch_queue_create([p2pQueueTag UTF8String], DISPATCH_QUEUE_SERIAL);
  }
  return _p2pQueue;
}
// this section is for the test. because the C++ class could not expose to the
// header. #sharedAPI only can be a private method. so for the testing,i have to
// tweak it.
#if DEBUG
#pragma mark - test methods
- (BOOL)testSingleton {
  CAVInterfaceAPI *foo1 = [[self class] sharedAPI];
  CAVInterfaceAPI *foo2 = [[self class] sharedAPI];
  CAVInterfaceAPI *foo3 = [[self class] sharedAPI];
  return foo1 == foo2 && foo2 == foo3 && foo1 == foo3 & foo1 != nil;
}
#endif
@end
