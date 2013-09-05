//
//  NSRegularExpression+BSConfig.h
//  Example
//
//  Created by Simon Støvring on 05/09/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSRegularExpression (BSConfig)

+ (NSRegularExpression *)regexWithPattern:(NSString *)pattern;
- (NSArray *)matchesInString:(NSString *)string;
- (NSUInteger)numberOfMatchesInString:(NSString *)string;

@end
