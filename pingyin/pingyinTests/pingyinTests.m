//
//  pingyinTests.m
//  pingyinTests
//
//  Created by Zeus on 14-4-24.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "pinyin.h"
@interface pingyinTests : XCTestCase

@end

@implementation pingyinTests

- (void)setUp {
  [super setUp];
  // Put setup code here. This method is called before the invocation of each
  // test method in the class.
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each
  // test method in the class.
  [super tearDown];
}

- (void)testExample {
  NSString *test = @"马克西姆";
  NSString *eTest = @"Mark Handsom";
  printf("=============================> %c,<================ %c",
         pinyinFirstLetter([test characterAtIndex:0]),
         pinyinFirstLetter([eTest characterAtIndex:0]));
}

@end
