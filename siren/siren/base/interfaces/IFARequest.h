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
- (id)head; // head info of request
- (id)body; // body info of request
@end
