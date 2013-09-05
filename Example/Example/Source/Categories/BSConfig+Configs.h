//
//  BSConfig+Configs.h
//  Example
//
//  Created by Simon Støvring on 05/09/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "BSConfig.h"

@interface BSConfig (Configs)

@property (nonatomic, readonly) int myInt;
@property (nonatomic, readonly) NSInteger myInteger;
@property (nonatomic, readonly) CGFloat myFloat;
@property (nonatomic, readonly) double myDouble;
@property (nonatomic, readonly) unsigned int myUnsignedInt;
@property (nonatomic, readonly) long myLong;
@property (nonatomic, readonly) long long myLongLong;
@property (nonatomic, readonly) unsigned long myUnsignedLong;
@property (nonatomic, readonly) unsigned long long myUnsignedLongLong;
@property (nonatomic, readonly) NSUInteger myUnsignedInteger;
@property (nonatomic, readonly) BOOL myBool;
@property (nonatomic, readonly) CGSize mySize;
@property (nonatomic, readonly) CGPoint myPoint;
@property (nonatomic, readonly) CGRect myRect;
@property (nonatomic, readonly) UIEdgeInsets myEdgeInsets;
@property (nonatomic, readonly) UIOffset myOffset;
@property (nonatomic, readonly) NSString *myString;
@property (nonatomic, readonly) NSDate *myDate;
@property (nonatomic, readonly) UIImage *myImage;
@property (nonatomic, readonly) UIImage *myStretchableImage;
@property (nonatomic, readonly) UIImage *myResizableImage;
@property (nonatomic, readonly) UIColor *myHexColor;
@property (nonatomic, readonly) UIColor *myRGBColor;
@property (nonatomic, readonly) UIColor *myRGBAColor;

@end
