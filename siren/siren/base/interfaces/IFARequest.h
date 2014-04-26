//
//  IFARequest.h
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IFARequest <NSObject>
@optional
- (id)head;       // head info of request
- (id)body;       // body info of request
- (id)dictionary; // return the dic format of the reqeust
- (id)bin;        // return the binary format of the request
@end
