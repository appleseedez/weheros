//
//  FAEngine.m
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FAEngine.h"
#import "weheroSDK/AVInterface.hh"
#import "weheroSDK/NatTypeImpl.h"

UIView *_pview_local;
@interface FAEngine ()
// current inter IP
@property(nonatomic, copy) NSString *myCurrentInterIP;
@property(nonatomic) NSUInteger myLocalPort;
@property(nonatomic) dispatch_queue_t p2pQueue;
@property(nonatomic) NSNumber *stateLock;
@property(nonatomic) NSInteger selfNATType;
@end
@implementation FAEngine
#pragma mark - engine life
- (instancetype)init {
  self = [super init];
  if (self) {

    self.stateLock = @(0);
    [[[RACObserve(self, engineState) filter:^BOOL(NSNumber* state) {
      return state != nil && [state unsignedIntegerValue] !=
                                 [self.stateLock unsignedIntegerValue];
    }] map:^id(NSNumber * state) {
      self.stateLock = state;
      NSUInteger stateCase = [state unsignedIntegerValue];
      switch (stateCase) {
      case FAEngineStateShouldShutdown: {
        if ([self shutDownEngine]) {
          self.engineState = @(FAEngineStateDidShutdown);
        }
      } break;
      case FAEngineStateShouldStart: {
        if ([self startEngine]) {
          self.engineState = @(FAEngineStateDidStart);
        }
      } break;
      case FAEngineStateNetworkShouldReady: {
        if ([self setupNetwork]) {
          self.engineState = @(FAEngineStateNetworkDidReady);
        }
      } break;
      case FAEngineStateNetworkShouldClosed: {
        if ([self closeNetwork]) {
          self.engineState = @(FAEngineStateNetworkDidClosed);
        }
      } break;
      case FAEngineStateSoundShouldMute: {
        if ([self mute]) {
          self.engineState = @(FAEngineStateSoundDidMute);
        }
      } break;
      case FAEngineStateSoundShouldUnmute: {
        if ([self unmute]) {
          self.engineState = @(FAEngineStateSoundDidUnmute);
        }
      } break;
      case FAEngineStateSpeakerShouldEnable: {
        if ([self enableSpeaker]) {
          self.engineState = @(FAEngineStateSpeakerDidEable);
        }
      } break;
      case FAEngineStateSpeakerShouldDisable: {
        if ([self disableSpeaker]) {
          self.engineState = @(FAEngineStateSpeakerDidDisable);
        }
      } break;
      case FAEngineStateShouldStartP2P: {
        self.engineState = @(FAEngineStateP2PInProcess);
          [[[[[self startP2P:@{kPeerInterIP:@"",
                               kPeerInterPort:@(2112),
                               kPeerLocalIP:@"",
                               kPeerLocalPort:@(23213),
                               kRelayIP:@"",
                               kRelayPort:@(213),
                               kPeerSessionID:@(1112),
                               kPeerNATType:@(1)}] subscribeOn:[RACScheduler scheduler]]
             deliverOn:[RACScheduler mainThreadScheduler]]
            map:^id(NSDictionary* p2pResult) {
            if ([[p2pResult valueForKey:@"code"] boolValue]) {
              self.engineState = @(FAEngineStateP2PDidSuccess);
              // start data transport
              [self startTransportMediaData];
            } else {
              // p2p just failed. it's the caller's response to trigger stopP2P
              self.engineState = @(FAEngineStateP2PDidFail);
            }
            return p2pResult;
          }] subscribeNext:^(NSDictionary* result) {
            NSLog(@"p2p process result:%@", result);
          }];
      } break;
      case FAEngineStateShouldStopP2P: {
        if ([self stopP2P]) {
          self.engineState = @(FAEngineStateDidStopP2P);
        }
      } break;
      default:
        break;
      }
      return state;
    }] subscribeNext:^(NSNumber* state) {
      NSLog(@"engine state is %@", state);
    }];
    self.engineState = @(FAEngineStateShouldStart);
  }
  return self;
}

/**
 *  when the media init finish. the engine is started
 */
- (bool)startEngine {
  self.engineState = @(FAEngineStateShouldShutdown);
  return [[self class] sharedAPI]->MediaInit();
}
- (bool)shutDownEngine {
  return [[self class] sharedAPI]->Terminate();
}

/**
 *  the network is for the p2p tunneling. all about the udp pkg
 */
- (bool)setupNetwork {
  self.engineState = @(FAEngineStateNetworkShouldClosed);
  self.myLocalPort = LocalBasePort + (++_localPortSuffix) % 9;
  return [[self class] sharedAPI]->OpenNetWork((int)self.myLocalPort);
}
- (bool)closeNetwork {
  return [[self class] sharedAPI]->CloseNetWork();
}

#pragma mark - engine function
- (bool)openCamera {
  return false;
}
- (bool)closeCamera {
  return false;
}
- (bool)mute {
  // TODO: SetMuteEnable should have return type
  [[self class] sharedAPI]->SetMuteEnble(MTVoe, false);
  return true;
}
- (bool)unmute {
  [[self class] sharedAPI]->SetMuteEnble(MTVoe, true);
  return true;
}
- (bool)enableSpeaker {
  NSError *error = nil;
  [[AVAudioSession sharedInstance] setActive:YES error:&error];
  [[AVAudioSession sharedInstance]
      setCategory:AVAudioSessionCategoryPlayAndRecord
      withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
            error:&error];
  return nil == error;
}
- (bool)disableSpeaker {
  NSError *error = nil;
  [[AVAudioSession sharedInstance] setActive:YES error:&error];
  [[AVAudioSession sharedInstance]
      setCategory:AVAudioSessionCategoryPlayAndRecord
      withOptions:AVAudioSessionCategoryOptionDuckOthers
            error:&error];
  return nil == error;
}
- (RACSignal *)startP2P:(NSDictionary *)params {
  RACReplaySubject *subject = [RACReplaySubject subject];
  TP2PPeerArgc p2pArgc;
  ::memset(&p2pArgc, 0, sizeof(TP2PPeerArgc));
  //  NSAssert([params valueForKey:kPeerInterIP], @"no such key");
  // 外网地址
  ::strncpy(p2pArgc.otherInterIP,
            [[params valueForKey:kPeerInterIP] UTF8String],
            sizeof(p2pArgc.otherInterIP));
  p2pArgc.otherInterPort = [[params valueForKey:kPeerInterPort] intValue];
  // 内网地址
  ::strncpy(p2pArgc.otherLocalIP,
            [[params valueForKey:kPeerLocalIP] UTF8String],
            sizeof(p2pArgc.otherLocalIP));
  p2pArgc.otherLocalPort = [[params valueForKey:kPeerLocalPort] intValue];
  // 转发地址
  ::strncpy(p2pArgc.otherForwardIP, [[params valueForKey:kRelayIP] UTF8String],
            sizeof(p2pArgc.otherForwardIP));
  p2pArgc.otherForwardPort = [[params valueForKey:kRelayPort] intValue];

  // 对方的ssid
  p2pArgc.otherSsid = [[params valueForKey:kPeerSessionID] intValue];
  // 自己的ssid
  p2pArgc.selfSsid = [[params valueForKey:kMySessionID] intValue];

  p2pArgc.otherNATType = [[params valueForKey:kPeerNATType] intValue];
  p2pArgc.selfNATType = self.selfNATType;
  // should i just use local detect
  p2pArgc.localEnble = YES;
  if (0 == [[self class] sharedAPI]->GetP2PPeer(p2pArgc)) {
    [subject sendNext:@{ @"code" : @(YES) }];
  } else {
    [subject sendNext:@{ @"code" : @(NO) }];
  }
  [subject sendCompleted];
  return subject;
}
- (bool)stopP2P {
  return false;
}

- (bool)startTransportMediaData {
  return YES;
}
// get the interIP & port, localIP & port for the negotiation data struction
- (RACSignal *)fetchParamsForSessionWithProbeIP:(NSString *)probeIP
                                      probePort:(NSUInteger)probePort
                                        bakPort:(NSUInteger)bakPort
                                     stunServer:(NSString *)stunServer {
  RACReplaySubject *subject = [RACReplaySubject subject];
  // need the network be setup;
  self.engineState = @(FAEngineStateNetworkShouldReady);
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
  // if the probeIP is not reachable, then this method will through bad address
  // access.
  NSLog(@"use backport:%lu for the 1st get", (unsigned long)bakPort);
  [[self class] sharedAPI]->GetSelfInterAddr([probeIP UTF8String], bakPort,
                                             self_inter_ip, self_inter_port);
  // 2nd time
  NSLog(@"use probeport:%lu for the 2nd get", (unsigned long)probePort);
  int ret = [[self class] sharedAPI]->GetSelfInterAddr([probeIP UTF8String],
                                                       probePort, self_inter_ip,
                                                       self_inter_port);
  if (ret != 0) {
    interIP = BLANK_STRING;
  } else {
    interIP = [NSString stringWithUTF8String:self_inter_ip];
  }

  // get myself the nat type
  NatTypeImpl nat;
  self.selfNATType = nat.GetNatType([stunServer UTF8String]);
  // shoud i free the nat ?
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
                                    bakPort:(NSUInteger)bakPort
                                 stunServer:(NSString *)stunSever {

  return [self fetchParamsForSessionWithProbeIP:probeIP
                                      probePort:probePort
                                        bakPort:bakPort
                                     stunServer:stunSever];
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
