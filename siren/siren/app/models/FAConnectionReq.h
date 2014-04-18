//
//  FAConnectionReq.h
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright (c) 2014年 weheros. All rights reserved.
//
//  This is the requst used to connect to SS

#import "FARequest.h"
#import "FAGateway.h"
@interface FAConnectionReq : FARequest
@property(nonatomic) FAGateway *gateway;
@end
