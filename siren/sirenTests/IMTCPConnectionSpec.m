//
//  IMTCPConnectionSpec.m
//  siren
//
//  Created by Pharaoh on 14-3-22.
//  Copyright 2014年 weheros. All rights reserved.
//

#import "Kiwi.h"

SPEC_BEGIN(IMTCPConnectionSpec)
describe(@"Connection Test",
         ^{
            // Test TCP connection process
            //    context(@"when given an endpoit 112.124.110.206:1337", ^{
            //        IMTCPConnection *connection = [[IMTCPConnection alloc]
            // init];
            //        IMEndpoint *endpoint = [IMEndpoint new];
            //        endpoint.host = kForwardHost;
            //        endpoint.port = @(kForwardPort);
            //        it(@"socket should  be connected to that endpoit
            // sucessfully ", ^{
            //            connection.endpoint = endpoint;
            //            sleep(4); // wait for the connection result
            //            [[theValue(connection.isConnected) should]
            // equal:theValue(YES)];
            //        });
            //
            //        IMEndpoint *otherPoint = [IMEndpoint new];
            //        otherPoint.host = @"112.124.110.206";
            //        otherPoint.port = @(1336);
            //        it(@"socket should  be connected to other endpoint
            // unsuccessfully ", ^{
            //            connection.endpoint = otherPoint;
            //            sleep(4); // wait for the connection result
            //            [[theValue(connection.isConnected) should]
            // equal:theValue(NO)];
            //        });
            //    });
          });

SPEC_END
