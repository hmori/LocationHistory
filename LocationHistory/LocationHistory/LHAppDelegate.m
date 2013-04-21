//
//  LHAppDelegate.m
//  LocationHistory
//
//  Created by Hidetoshi Mori on 13/04/21.
//  Copyright (c) 2013年 Hidetoshi Mori. All rights reserved.
//

#import "LHAppDelegate.h"
#import "EvernoteSession.h"
#import "ENConstants.h"

@implementation LHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString *EVERNOTE_HOST = BootstrapServerBaseURLStringSandbox;
    NSString *CONSUMER_KEY = @"hmori99-9252";
    NSString *CONSUMER_SECRET = @"b345f435d99aadc8";
    
    [EvernoteSession setSharedSessionHost:EVERNOTE_HOST
                              consumerKey:CONSUMER_KEY
                           consumerSecret:CONSUMER_SECRET];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
