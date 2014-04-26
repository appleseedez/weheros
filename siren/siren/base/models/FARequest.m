//
//  FARequest.m
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FARequest.h"

@implementation FARequest
- (NSDictionary *)tokenDic {
  return @{ @"s" : @"abcdefghijklmnopqrstuvwxyz" };
}
- (NSString *)token {
  return @"abcdefghijklmnopqrstuvwxyz";
}
@end
