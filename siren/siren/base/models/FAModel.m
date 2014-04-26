//
//  FAModel.m
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FAModel.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@implementation FAModel
+ (NSDictionary *)data2Dic:(NSData *)data {
  NSAssert(data != nil, @"data is nil");
  NSError *error;
  /* parse the response. we need to know the type for delegate method
   * invoking. and status for success or failed */
  /* 和服务器约定, 返回的数据都是UTF8编码后的.
   * 所以在此处只需要将获取的数据转换成utf8字符串. 然后再转换为json*/
  /* 补充: 此处不能直接使用data进行json转换的原因是数据在末尾添加了结束符*/
  NSString *responseString =
      [NSString stringWithUTF8String:(const char *)[data bytes]];
  NSAssert(responseString != nil, @"not parsed to string");
  NSDictionary *response = [NSJSONSerialization
      JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                 options:NSJSONReadingMutableContainers
                   error:&error];
  if (error) {
    [NSException exceptionWithName:@"500:data serialization error."
                            reason:@"Wrong format"
                          userInfo:nil];
    response = @{};
  }
  return response;
}
+ (NSData *)dic2Data:(NSDictionary *)dic {

  /*构造发送到信令服务器的数据包*/
  NSError *error;
  // 将NSDictionary 序列化为JSON数据.
  NSData *jsonData =
      [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
  if (error) {
    [NSException exceptionWithName:@"400:data serialzation error"
                            reason:@"数据序列化出错鸟"
                          userInfo:nil];
  }

  /*
   在所有请求头部都必须包含2个字节的包长度数据.
   we need to prepend the length of the request in bytes.This is protocol with
   server.
   all the exchange data between client and server should have the package
   length ahead.
   */
  uint16_t pkgLength = (uint16_t)[jsonData length]; // calculate the length of
                                                    // the data package in
                                                    // bytes.
  pkgLength++; // we need to append a '\0' to the package.so that need count in.
  pkgLength = htons(pkgLength); // big end/small end transform.
  /* append the '\0' */
  NSMutableData *data = [NSMutableData data];
  //    [requestData appendShort:pkgLength];
  [data appendData:[NSData dataWithBytes:&pkgLength length:sizeof(uint16_t)]];
  [data appendData:jsonData];
  [data appendByte:'\0'];
  return [data copy];
}
+ (NSString *)getIpLocally:(NSString *)networkInterface
                 ipVersion:(int)ipVersion {
  if (ipVersion != 4 && ipVersion != 6) {
    NSLog(@"getIpLocally unknown version of IP: %i", ipVersion);
    return nil;
  }

  NSString *networkInterfaceRef;

  if ([networkInterface isEqualToString:kNetInterfaceCellular]) {
    networkInterfaceRef = @"pdp_ip0";
  } else if ([networkInterface isEqualToString:kNetInterfaceWIFI]) {
    networkInterfaceRef = @"en0"; // en1 on simulator if mac on wifi
  } else {
    NSLog(@"getIpLocally unknown interface: %@", networkInterface);
    return nil;
  }

  NSString *address = nil;
  struct ifaddrs *interfaces = NULL;
  struct ifaddrs *temp_addr = NULL;
  struct sockaddr_in *s4;
  struct sockaddr_in6 *s6;
  char buf[64];
  int success = 0;

  // retrieve the current interfaces - returns 0 on success
  success = getifaddrs(&interfaces);
  if (success == 0) {
    // Loop through linked list of interfaces
    temp_addr = interfaces;
    while (temp_addr != NULL) {
      if ((ipVersion == 4 && temp_addr->ifa_addr->sa_family == AF_INET) ||
          (ipVersion == 6 && temp_addr->ifa_addr->sa_family == AF_INET6)) {
        NSLog(@"Network Interface: %@",
              [NSString stringWithUTF8String:temp_addr->ifa_name]);

        // Check if interface is en0 which is the wifi connection on the iPhone
        if ([[NSString stringWithUTF8String:temp_addr->ifa_name]
                isEqualToString:networkInterfaceRef]) {
          if (ipVersion == 4) {
            s4 = (struct sockaddr_in *)temp_addr->ifa_addr;

            if (inet_ntop(temp_addr->ifa_addr->sa_family,
                          (void *)&(s4->sin_addr), buf, sizeof(buf)) == NULL) {
              NSLog(@"%s: inet_ntop failed for v4!\n", temp_addr->ifa_name);
            } else {
              address = [NSString stringWithUTF8String:buf];
            }
          }
          if (ipVersion == 6) {
            s6 = (struct sockaddr_in6 *)(temp_addr->ifa_addr);

            if (inet_ntop(temp_addr->ifa_addr->sa_family,
                          (void *)&(s6->sin6_addr), buf, sizeof(buf)) == NULL) {
              NSLog(@"%s: inet_ntop failed for v6!\n", temp_addr->ifa_name);
            } else {
              address = [NSString stringWithUTF8String:buf];
            }
          }
        }
      }

      temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
 	freeifaddrs(interfaces);
    NSLog(@"local ip address is :%@",address);
 	return address;
}
@end
