//
//  FAModel.m
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FAModel.h"

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
                            reason:@"收到的数据包格式错误"
                          userInfo:nil];
        }
        return response;

}
@end
