//
//  FACallingPeerReq.h
//  siren
//
//  Created by Zeus on 14-4-26.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FAControlReq.h"

@interface FACallingPeerReq : FAControlReq
@property(nonatomic, copy) NSString *myAccount;
@property(nonatomic) NSUInteger mySessionID;
@property(nonatomic, copy) NSString *myLocalIP;
@property(nonatomic) NSUInteger myLocalPort;
@property(nonatomic, copy) NSString *myInterIP;
@property(nonatomic) NSUInteger myInterPort;
@property(nonatomic, copy) NSString *relayIP;
@property(nonatomic) NSUInteger relayPort;
@property(nonatomic) NSUInteger peerSessionID;
@property(nonatomic, copy) NSString *peerAccount;
@end
