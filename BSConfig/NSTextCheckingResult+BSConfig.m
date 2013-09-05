//
//  NSTextCheckingResult+BSConfig.m
//  Example
//
//  Created by Simon Støvring on 05/09/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "NSTextCheckingResult+BSConfig.h"

@implementation NSTextCheckingResult (BSConfig)

#pragma mark -
#pragma mark Public Methods

- (NSString *)groupAtIndex:(NSUInteger)index inString:(NSString *)string
{
    NSRange range = [self rangeAtIndex:index];
    return [string substringWithRange:range];
}

@end
