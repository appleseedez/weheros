//
//  FAModel.h
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,
                FASignalType) { FASignalTypeHeartBeat = 0,
                                FASignalTypeLoginRequest = 1,
                                FASignalTypeLoginResponse = 1 << 4,
                                FASignalTypeStartSessionRequest = 2,
                                FASignalTypeStartSessionResponse = 2 << 4,
                                FASignalTypeCallingPeer = 401,
                                FASignalTypeAnsweringPeer = 402,
                                FASignalTypeEndSessionPeer = 403 };

typedef NS_ENUM(NSInteger, FAEndReason) { FAEndReasonNormal = 0,
                                          FAEndReasonBusy = 1,
                                          FAEndReasonRefuse = 3 };
typedef NS_ENUM(NSInteger, FABizType) { FABizTypeCalling = 1024,
                                        FABizTypeAnswering = 2048,
                                        FABizTypeEndSession = 4096 };
@interface FAModel : NSObject
+ (NSDictionary *)data2Dic:(NSData *)data;
+ (NSString *)getIpLocally:(NSString *)networkInterface
                 ipVersion:(int)ipVersion;
@end
