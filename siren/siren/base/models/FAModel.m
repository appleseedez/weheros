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
  NSError *error;
  /* parse the response. we need to know the type for delegate method
   * invoking. and status for success or failed */
  /* 和服务器约定, 返回的数据都是UTF8编码后的.
   * 所以在此处只需要将获取的数据转换成utf8字符串. 然后再转换为json*/
  /* 补充: 此处不能直接使用data进行json转换的原因是数据在末尾添加了结束符*/
  NSString *responseString =
      [NSString stringWithUTF8String:(const char *)[data bytes]];
  NSDictionary *response = [NSJSONSerialization
      JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                 options:NSJSONReadingMutableContainers
                   error:&error];
  if (error) {
    [NSException exceptionWithName:@"500:data serialization error."
                            reason:@"Wrong format"
                          userInfo:nil];
  }
  return response;
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
