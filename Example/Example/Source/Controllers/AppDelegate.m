//
//  AppDelegate.m
//  Example
//
//  Created by Simon Støvring on 05/09/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "BSConfig+Configs.h"

@implementation AppDelegate

#pragma mark -
#pragma mark Lifecycke

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[ViewController alloc] init];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    BSConfig *config = [BSConfig sharedConfig];
    
    NSLog(@"%i", config.myInt);
    NSLog(@"%i", config.myInteger);
    NSLog(@"%f", config.myFloat);
    NSLog(@"%f", config.myDouble);
    NSLog(@"%u", config.myUnsignedInt);
    NSLog(@"%u", config.myUnsignedInteger);
    NSLog(@"%ld", config.myLong);
    NSLog(@"%lld", config.myLongLong);
    NSLog(@"%lu", config.myUnsignedLong);
    NSLog(@"%llu", config.myUnsignedLongLong);
    NSLog(@"%i", config.myBool);
    NSLog(@"%@", NSStringFromCGSize(config.mySize));
    NSLog(@"%@", NSStringFromCGPoint(config.myPoint));
    NSLog(@"%@", NSStringFromCGRect(config.myRect));
    NSLog(@"%@", NSStringFromUIEdgeInsets(config.myEdgeInsets));
    NSLog(@"%@", NSStringFromUIOffset(config.myOffset));
    NSLog(@"%@", config.myString);
    NSLog(@"%@", config.myDate);
    NSLog(@"%@", config.myImage);
    NSLog(@"%@", config.myStretchableImage);
    NSLog(@"%@", config.myResizableImage);
    NSLog(@"%@", config.myHexColor);
    NSLog(@"%@", config.myRGBColor);
    NSLog(@"RGBA: %@", config.myRGBAColor);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
