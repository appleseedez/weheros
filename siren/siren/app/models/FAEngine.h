//
//  FAEngine.h
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FAModel.h"
typedef NS_ENUM(NSInteger, FAEngineState) {
  FAEngineStateShutdown = -1, FAEngineStateNetworkReady,
  FAEngineStateStarted,       FAEngineStateCameraOpened,
  FAEngineStateCameraClosed,  FAEngineStateSoundMute,
  FAEngineStateSoundUnMute,   FAEngineStateP2PInProcess,
  FAEngineStateSpeakerEabled, FAEngineStateSpeakerDisabled,
  FAEngineStateP2PSuccessed,  FAEngineStateP2PFailed,
  FAEngineStateMediaClosed,   FAEngineStateNetworkClosed
};
// used to generate localPort number
static NSUInteger _localPortSuffix = 0;
@interface FAEngine : FAModel <IFAEngine>
#pragma mark - engine life
- (void)startEngine;
- (void)shutDownEngine;
- (void)setupNetwork;
- (void)closeNetwork;
#pragma mark - engine function
- (void)openCamera;
- (void)closeCamera;
- (void)mute;
- (void)unmute;
- (void)enableSpeaker;
- (void)disableSpeaker;
- (void)startP2P;
- (void)stopP2P;
- (RACSignal *)prepareForSessionWithProbeIP:(NSString *)probeIP
                                  probePort:(NSUInteger)probePort
                                    bakPort:(NSUInteger)bakPort;
@property(nonatomic, strong) NSNumber *engineState;

#if DEBUG
- (BOOL)testSingleton;
#endif
@end
