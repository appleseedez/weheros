//
//  FAEngine.h
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FAModel.h"
/**

 **/
typedef NS_ENUM(NSUInteger, FAEngineState) {
  FAEngineStateShouldShutdown = 1,   FAEngineStateDidShutdown,
  FAEngineStateShouldStart,          FAEngineStateDidStart,
  FAEngineStateNetworkShouldClosed,  FAEngineStateNetworkDidClosed,
  FAEngineStateNetworkShouldReady,   FAEngineStateNetworkDidReady,
  FAEngineStateShouldStartP2P,       FAEngineStateP2PInProcess,
  FAEngineStateP2PDidSuccess,        FAEngineStateP2PDidFail,
  FAEngineStateShouldStopP2P,        FAEngineStateDidStopP2P,
  FAEngineStateSoundShouldMute,      FAEngineStateSoundDidMute,
  FAEngineStateSoundShouldUnmute,    FAEngineStateSoundDidUnmute,
  FAEngineStateSpeakerShouldDisable, FAEngineStateSpeakerDidDisable,
  FAEngineStateSpeakerShouldEnable,  FAEngineStateSpeakerDidEable,
  FAEngineStateCameraShouldClose,    FAEngineStateCameraDidClose,
  FAEngineStateCameraShouldOpen,     FAEngineStateCameraDidOpen
};
// used to generate localPort number
static NSUInteger _localPortSuffix = 0;
@interface FAEngine : FAModel <IFAEngine>
#pragma mark - engine life
- (bool)startEngine;
- (bool)shutDownEngine;
- (bool)setupNetwork;
- (bool)closeNetwork;
#pragma mark - engine function
- (bool)openCamera;
- (bool)closeCamera;
- (bool)mute;
- (bool)unmute;
- (bool)enableSpeaker;
- (bool)disableSpeaker;
- (RACSignal *)startP2P:(NSDictionary *)params;
- (bool)stopP2P;
- (RACSignal *)prepareForSessionWithProbeIP:(NSString *)probeIP
                                  probePort:(NSUInteger)probePort
                                    bakPort:(NSUInteger)bakPort
                                 stunServer:(NSString *)stunServer;
@property(nonatomic, strong) NSNumber *engineState;

#if DEBUG
- (BOOL)testSingleton;
#endif
@end
