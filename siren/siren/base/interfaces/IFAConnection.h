//
//  IFAConnection.h
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFARequest.h"
typedef NS_ENUM(NSInteger,
                FAConnectionStatus) { FAConnectionStatusConnected = 1,
                                      FAConnectionStatusDisconnected = -1 };
@protocol IFAConnection <NSObject>
@optional
- (BOOL)connect;
- (BOOL)connectWithRequest:(id<IFARequest>)request;
- (BOOL)reconnect;
- (void)disconnect;
- (NSInteger)send:(id<IFARequest>)data;
- (NSNumber *)status;
@end
