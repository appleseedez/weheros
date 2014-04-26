//
//  IFACore.h
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFARequest.h"
@protocol IFACore <NSObject>
- (void)dial:(id<IFARequest>)someOne;
@end
