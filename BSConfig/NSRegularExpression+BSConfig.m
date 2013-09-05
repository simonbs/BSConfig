//
//  NSRegularExpression+BSConfig.m
//  Example
//
//  Created by Simon Støvring on 05/09/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "NSRegularExpression+BSConfig.h"

@implementation NSRegularExpression (BSConfig)

#pragma mark -
#pragma mark Public Methods

+ (NSRegularExpression *)regexWithPattern:(NSString *)pattern
{
    return [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
}

- (NSArray *)matchesInString:(NSString *)string
{
    return [self matchesInString:string options:0 range:NSMakeRange(0, string.length)];
}

- (NSUInteger)numberOfMatchesInString:(NSString *)string
{
    return [self numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)];
}

@end
