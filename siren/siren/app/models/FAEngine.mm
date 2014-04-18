//
//  FAEngine.m
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FAEngine.h"
#import "weheroSDK/AVInterface.hh"

UIView *_pview_local;
@interface FAEngine ()
// the api
@property(nonatomic, readonly) CAVInterfaceAPI *api;
// current inter IP
@property(nonatomic, copy) NSString *myCurrentInterIP;
@end
@implementation FAEngine

#pragma mark - accessors
@synthesize api = _api;
- (CAVInterfaceAPI *)api {
  if (nil == _api) {
    _api = new CAVInterfaceAPI();
  }
  return _api;
}
@end
