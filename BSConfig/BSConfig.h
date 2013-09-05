//
//  BSConfig.h
//  Example
//
//  Created by Simon Støvring on 05/09/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSConfig : NSObject
{
    NSDictionary *plist;
    NSMutableDictionary *map;
}

- (id)initWithFilePath:(NSString *)filePath;
+ (BSConfig *)sharedConfig;

- (int)intForKeyPath:(NSString *)keyPath;
- (float)floatForKeyPath:(NSString *)keyPath;
- (double)doubleForKeyPath:(NSString *)keyPath;
- (unsigned int)unsignedIntForKeyPath:(NSString *)keyPath;
- (long)longForKeyPath:(NSString *)keyPath;
- (long long)longLongForKeyPath:(NSString *)keyPath;
- (unsigned long)unsignedLongForKeyPath:(NSString *)keyPath;
- (unsigned long long)unsignedLongLongForKeyPath:(NSString *)keyPath;
- (BOOL)boolForKeyPath:(NSString *)keyPath;
- (CGSize)sizeForKeyPath:(NSString *)keyPath;
- (CGPoint)pointForKeyPath:(NSString *)keyPath;
- (CGRect)rectForKeyPath:(NSString *)keyPath;
- (UIEdgeInsets)edgeInsetsForKeyPath:(NSString *)keyPath;
- (UIOffset)offsetForKeyPath:(NSString *)keyPath;
- (NSString *)stringForKeyPath:(NSString *)keyPath;
- (NSDate *)dateForKeyPath:(NSString *)keyPath;
- (UIImage *)imageForKeyPath:(NSString *)keyPath;
- (UIColor *)colorForKeyPath:(NSString *)keyPath;

@end
