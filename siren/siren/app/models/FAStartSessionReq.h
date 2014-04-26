//
//  FAStartSessionReq.h
//  siren
//
//  Created by Zeus on 14-4-24.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FAControlReq.h"

@interface FAStartSessionReq : FAControlReq
@property(nonatomic, copy) NSString *myAccount;
@property(nonatomic, copy) NSString *peerAccount;
@end
