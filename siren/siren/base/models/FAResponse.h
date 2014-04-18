//
//  FAResponse.h
//  siren
//
//  Created by Zeus on 14-4-18.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FAModel.h"

@interface FAResponse : FAModel <IFAResponse>
@property(nonatomic) NSDictionary *payload;
@end
