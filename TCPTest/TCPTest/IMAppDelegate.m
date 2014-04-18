//
//  IMAppDelegate.m
//  TCPTest
//
//  Created by Zeus on 14-4-4.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "IMAppDelegate.h"

@implementation IMAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  //  struct sockaddr_in addr;
  //  memset(&addr, 0, sizeof(struct sockaddr_in));
  //  addr.sin_family = AF_INET;
  //  addr.sin_port = htons(9989);
  //  addr.sin_addr.s_addr = inet_addr("115.29.145.142");
  //
  //  struct sockaddr_in callAddress;
  //  callAddress.sin_len = sizeof(callAddress);
  //  callAddress.sin_family = AF_INET;
  //  callAddress.sin_port = htons(9989);
  //  callAddress.sin_addr.s_addr = inet_addr("115.29.145.142");

  //  Reachability *reach = [Reachability reachabilityWithAddress:&callAddress];
  Reachability *reach =
      [Reachability reachabilityWithHostname:@"115.29.145.142"];
  NSLog(@"sdasdfasda");
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(reachabilityChanged:)
             name:kReachabilityChangedNotification
           object:nil];

  [reach startNotifier];
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state.
  // This can occur for certain types of temporary interruptions (such as an
  // incoming phone call or SMS message) or when the user quits the application
  // and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down
  // OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate
  // timers, and store enough application state information to restore your
  // application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called
  // instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state;
  // here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the
  // application was inactive. If the application was previously in the
  // background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if
  // appropriate. See also applicationDidEnterBackground:.
}

- (void)reachabilityChanged:(NSNotification *)notify {
  Reachability *reach = notify.object;

  NSLog(@"当前的状态:是哪种方式连接:%d", [reach currentReachabilityStatus]);
  NSLog(@"当前的状态:是否可达:%d", [reach isReachable]);
  NSLog(@"当前的状态:是否是通过 wifi 可达:%d", [reach isReachableViaWiFi]);
  NSLog(@"当前的状态:是否需要连接:%d", [reach isConnectionRequired]);
  NSLog(@"当前的状态:是否需要用户连接:%d", [reach isInterventionRequired]);
}
@end
