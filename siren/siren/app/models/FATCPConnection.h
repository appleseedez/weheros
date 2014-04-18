//
//  FATCPConnection.h
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FAModel.h"
#import "FAConnectionReq.h"

#import "FAEngine.h"
@interface FATCPConnection : FAModel <IFAConnection>
// the connection's status
@property(nonatomic, strong) NSNumber *status;
// send from self to remote
@property(nonatomic, strong) id<IFARequest> request;
// this is the response received from remote;
@property(nonatomic, strong) id<IFAResponse> response;
@end
