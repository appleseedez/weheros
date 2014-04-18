//
//  FATCPConnection.m
//  siren
//
//  Created by Zeus on 14-4-7.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FATCPConnection.h"
#import "FAConnectionReq.h"
#import "FAControlReq.h"
#import "FAControlRes.h"
#define HEAD_PART 0xFA    // header part used to read length
#define PAYLOAD_PART 0xFB // actual data part

@interface FATCPConnection () <GCDAsyncSocketDelegate>
@property(nonatomic) GCDAsyncSocket *sock;
@property(nonatomic)
    dispatch_queue_t sockControlQ; // socket operation is put off main queue.
@end

@implementation FATCPConnection
- (BOOL)connect {
  if (self.request == nil) {
    return NO;
  }
  NSError *error = nil;
  [self.sock
      connectToHost:[self.request.body valueForKeyPath:@"host"]
             onPort:[[self.request.body valueForKeyPath:@"port"] shortValue]
              error:&error];

  return error == nil;
}

- (BOOL)connectWithRequest:(FAConnectionReq *)request {
  // set the request
  self.request = request;
  return [self connect];
}
- (void)disconnect {
  [self.sock disconnectAfterReadingAndWriting];
}
#pragma mark - socket delegate
// connected to host
- (void)socket:(GCDAsyncSocket *)sock
    didConnectToHost:(NSString *)host
                port:(uint16_t)port {
  self.status = @(FAConnectionStatusConnected);
  // get ready to read from socket
  [sock readDataToLength:sizeof(uint16_t) withTimeout:-1 tag:HEAD_PART];
}
// did disconnected to host
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
  self.status = @(FAConnectionStatusDisconnected);
}
#pragma mark - accessors
@synthesize sock = _sock;
- (GCDAsyncSocket *)sock {
  if (nil == _sock) {
    _sock = [[GCDAsyncSocket alloc] initWithDelegate:self
                                       delegateQueue:self.sockControlQ];
    // when created, make it the voip compatable socket.
    [_sock performBlock:^{ [_sock enableBackgroundingOnSocket]; }];
  }
  return _sock;
}
- (void)socket:(GCDAsyncSocket *)sock
    didReadData:(NSData *)data
        withTag:(long)tag {

  switch (tag) {
  case HEAD_PART: {
    if (sizeof(uint16_t) == [data length]) {
      //解析出包体长度字段.
      uint16_t pkgLength = 0;
      [data getBytes:&pkgLength length:sizeof(uint16_t)];
      // 服务器在长度字段中写入多少.我就读多少出来.
      // 然后交给[NSString stringWithUTF8String:(const char*)[data
      // bytes]]方法转换成json格式字符串.
      // 再转换为NSDictionary. 因为stringWithUTF8String:
      // 方法能够自动去掉结尾的结束符.
      pkgLength = ntohs(pkgLength);
      if (pkgLength < 0) {
        pkgLength = 0;
      }
      /*现在只需要指名需要读多少长. */
      [sock readDataToLength:pkgLength withTimeout:-1 tag:PAYLOAD_PART];
    }
    break;
  }
  case PAYLOAD_PART: {
    // always queue one operation so data can be read.
    [sock readDataToLength:sizeof(uint16_t) withTimeout:-1 tag:HEAD_PART];
    // parse the data using notification
    // shorten the process in the socket callback ASAP.
    FAControlRes *res = [FAControlRes new];
    res.binPayLoad = data;
    // this will trigger the kvo;
    self.response = res;
    break;
  }

  default:
    break;
  }
}

@synthesize sockControlQ = _sockControlQ;
- (dispatch_queue_t)sockControlQ {
  const NSString *queueTag = @"com.weheros.tcpsocketqueue";
  if (_sockControlQ == nil) {
    _sockControlQ =
        dispatch_queue_create([queueTag UTF8String], DISPATCH_QUEUE_SERIAL);
  }
  return _sockControlQ;
}
@end
