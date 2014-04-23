//
//  FASeqGen.m
//  siren
//
//  Created by Zeus on 14-4-23.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FASeqGen.h"
static NSUInteger SeqNumber = 1;
@implementation FASeqGen
+ (NSUInteger)seq {
  return SeqNumber++;
}
@end
