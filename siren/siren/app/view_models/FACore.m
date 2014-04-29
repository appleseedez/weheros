//
//  FACore.m
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FACore.h"
#import "FACallingPeerReq.h"
@interface FACore ()
// tcp data subscription.
@property(nonatomic, strong) RACDisposable *tcpDataSubscription;
// tcp conncetion status subscription
@property(nonatomic, strong) RACDisposable *tcpConnectionStatusSubscription;
// engine subscription.
@property(nonatomic, strong) RACDisposable *engineSubscription;
// what the state is current session state
@property(nonatomic, strong) NSNumber *sessionState;
// route the res data to the right logic
- (void)routeFromData:(NSDictionary *)data;
@end

@implementation FACore

#pragma mark - life cycle

- (instancetype)init {
  self = [super init];
  if (self) {
    [self setSessionState:@(FASessionStateIdle)];
    [self setupTCPDataSubscription];
    [self setupTCPConnectionStatusSubscription];
    [self setupEngineSubscription];
  }
  return self;
}

- (void)dealloc {
  // when the core is tear down, dispose the subscription.
  [self dispose];
}

#pragma mark - logic
- (RACSignal *)sessionStateSignal {
  return RACObserve(self, sessionState);
}
- (void)setupTCPDataSubscription {
    RACSignal *tcpSignal =
    [[[RACObserve(self.tcpConnection, response) filter:^BOOL(id value) {
      return nil != value;
    } ] map:^id(id<IFAResponse> res) {
      NSDictionary *resData = [[res body] valueForKey:@"payload"];
      // data process here.
      // put the logic in the map block instead of subscribNext will get rid of
      // the self cycle problem.
      [self routeFromData:resData];
      return resData;
    }] subscribeOn:[RACScheduler scheduler]];
    self.tcpDataSubscription =
    [tcpSignal subscribeNext:^(NSDictionary * payload) {
      // subscribeNext nee no logic just for debug.
      NSLog(@"recevied payload :%@", payload);
    }];
}
/**
 combine signal to determine whether reconnect is needed.
 1. reachability is false then no need to do reconnect. maybe just tip the
 user.
 2.otherwise reconnect is needed. because this signal indecates that
 network has changed but still reachable(reachStatus signal),or socket
 just been disconnected (tcpConnection signal).
 **/
- (void)setupTCPConnectionStatusSubscription {
  RACSignal *tcpConnectionStatusSignal =
    [[[RACSignal combineLatest:@[ RACObserve(self.tcpConnection, status), RACObserve(self.reach, reachStatus)] reduce:^id(NSNumber* connectionStatus,NSNumber* reachabilityStatus){

    NSLog(@"what is the reduce :%@,%@", connectionStatus, reachabilityStatus);
    if (![reachabilityStatus boolValue]) {
      return @(FAConnectionActionFlagNotReachable);
    } else if ([connectionStatus integerValue] ==
               FAConnectionStatusDisconnected) {
      return @(FAConnectionActionFlagNeedReconnect);
    } else {
      return @(FAConnectionActionFlagDoNothing);
    }
  }] map:^id(NSNumber* stat) {
    if ([stat integerValue] == FAConnectionActionFlagNeedReconnect) {
      NSLog(@"not connect,be able to connect to server");
      [self.tcpConnection reconnect];
    } else if ([stat integerValue] == FAConnectionActionFlagDoNothing) {
      NSLog(@"still connected. Nothing to do!");
    } else {
      // TODO: tip the user
      NSLog(@"TIP:Current Network is not reachable. Please check.");
      [self.tcpConnection disconnect];
    }
    return stat;
  }] subscribeOn:[RACScheduler scheduler]] ;
    self.tcpConnectionStatusSubscription = [tcpConnectionStatusSignal
        subscribeNext:^(NSNumber *
                        stat) {
      NSLog(@"get the tcp connect status code "
             "{FAConnectionActionFlagNeedReconnect:1,"
             "FAConnectionActionFlagDoNothing:0"
             "FAConnectionActionFlagNotConnected:-1} "
             "value is :%@",
            stat);
    }];
}

- (void)setupEngineSubscription {
  RACSignal *engineSignal = nil;
  // should handle engine signal;
  [engineSignal subscribeNext:^(id x) {
                                 //
                               }];
}

/**
 *  One kind of data routing implement.
 *
 *  @param data :the data flow from the socket
 */
- (void)routeFromData:(NSDictionary *)data {
  // the data has the fix format
  // head+body pure JSON
  NSDictionary *head = [data valueForKey:kHead];
  NSDictionary *body = [data valueForKey:kBody];
  NSInteger signalType = [[head valueForKey:kSignalType] integerValue];
  switch (signalType) {
  case FASignalTypeLoginResponse: {
    //  login success
    // login failed
  } break;

  case FASignalTypeStartSessionResponse: {
    /**
     *  waiting for the engine to get ready for rolling
     *
     *  @param sessionParams @{@"localIP":string,@"localPort":1234}
     *
     *  @return void
     */
    // the probe ip address must be reachable. or there will be crash.
    [[[self.engine prepareForSessionWithProbeIP:@"115.29.145.142" probePort:11117 bakPort:11110 stunServer:@""] map:^id(NSDictionary* sessionParams) {
      FACallingPeerReq *callingPeerReq;
      callingPeerReq =
          [self buildCallingPeerReqWithStartSessionRes:body
                                         sessionParams:sessionParams];
      // send the calling peer request.
      [self.tcpConnection send:callingPeerReq];
      return callingPeerReq;
    }] subscribeNext:^(FACallingPeerReq* data) {
      NSLog(@"the calling peer request send to the peer : %@", data);
    }];

  } break;

  case FASignalTypeAnsweringPeer: {
    // as a caller, i recevied answering.
  } break;
  case FASignalTypeCallingPeer: {
    // as a idel peer , i recevied calling.
  } break;
  case FASignalTypeHeartBeat: {
    // as a client i receive heartbeat.
  } break;
  default:
    break;
  }
}

- (void)dispose {
  // when the core is tear down, dispose the subscription.
  [self.tcpDataSubscription dispose];
  [self.tcpConnectionStatusSubscription dispose];
  [self.engineSubscription dispose];
  [self.tcpConnection disconnect];
}

#pragma mark - protocal
- (void)dial:(id<IFARequest>)someOne {
  [self.tcpConnection send:someOne];
}

#pragma mark - private
// do the mess work. build the calling peer request.
- (FACallingPeerReq *)
    buildCallingPeerReqWithStartSessionRes:(NSDictionary *)startSessionReqBody
                             sessionParams:(NSDictionary *)sessionParams {
  // into calling process or just stop the whole process
  // using the data res from the SS to generate the callingPeer data
  // structure.
  NSString *relayIP = [startSessionReqBody valueForKey:kRelayIP];
  NSUInteger relayPort =
      [[startSessionReqBody valueForKey:kRelayPort] integerValue];
  NSUInteger mySessionID =
      [[startSessionReqBody valueForKey:kSessionID] integerValue];
  // this is the session start moment, sessionIDs are generated by SS, they
  // are pairs. calling peer get the smaller one from SS,
  // it is the calling peer's duty to give the other part of sessionID pair
  // to
  // the answering peer.
  NSUInteger peerSessionID = mySessionID + 1;
  NSString *peerAccount = [startSessionReqBody valueForKey:kPeerAccount];
  NSString *myAccount = [startSessionReqBody valueForKey:kMyAccount];

  FACallingPeerReq *callingPeerReq = [FACallingPeerReq new];
  callingPeerReq.myAccount = myAccount;
  callingPeerReq.mySessionID = mySessionID;
  callingPeerReq.myLocalIP = [sessionParams valueForKey:@"localIP"];
  callingPeerReq.myLocalPort =
      [[sessionParams valueForKey:@"localPort"] integerValue];
  callingPeerReq.myInterIP = [sessionParams valueForKey:@"interIP"];
  callingPeerReq.myInterPort =
      [[sessionParams valueForKey:@"interPort"] integerValue];
  callingPeerReq.relayIP = relayIP;
  callingPeerReq.relayPort = relayPort;
  callingPeerReq.peerAccount = peerAccount;
  callingPeerReq.peerSessionID = peerSessionID;
  return callingPeerReq;
}

#pragma mark - accessors
@synthesize reach = _reach;
- (FAReachability *)reach {
  if (nil == _reach) {
    _reach = [FAReachability shared];
  }
  return _reach;
}

@synthesize tcpConnection = _tcpConnection;
- (FATCPConnection *)tcpConnection {
  if (nil == _tcpConnection) {
    _tcpConnection = [FATCPConnection new];
  }
  return _tcpConnection;
}

@synthesize engine = _engine;
- (FAEngine *)engine {
  if (nil == _engine) {
    _engine = [FAEngine new];
  }
  return _engine;
}
@end
