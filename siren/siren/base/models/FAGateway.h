//
//  FAGateway.h
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FAGateway : NSObject
@property(nonatomic, copy) NSString *host;
@property(nonatomic) NSUInteger port;

+ (instancetype)gatewayWithHost:(NSString *)host port:(NSUInteger)port;
@end
