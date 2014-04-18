//
//  FARequest.h
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright (c) 2014年 weheros. All rights reserved.
//
//  FARequest is the base class for all the request obj
//

#import "FAModel.h"
#import "FAToken.h"
@interface FARequest : FAModel <IFARequest>
@property(nonatomic) FAToken *token;       // session token
@property(nonatomic) NSString *account;    // my account
@property(nonatomic) NSString *signalType; // what kind of signal it is
@property(nonatomic) NSNumber *status;     // what the req status. always 0
@end
