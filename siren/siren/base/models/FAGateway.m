//
//  FAGateway.m
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FAGateway.h"

@implementation FAGateway
+ (instancetype)gatewayWithHost:(NSString *)host port:(NSUInteger)port {
  FAGateway *gateway = [FAGateway new];
  gateway.host = host;
  gateway.port = port;
  return gateway;
}
@end
