//
//  BSConfig.m
//  Example
//
//  Created by Simon Støvring on 05/09/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "BSConfig.h"
#import <objc/runtime.h>
#import "NSRegularExpression+BSConfig.h"
#import "NSTextCheckingResult+BSConfig.h"
#import "UIColor+BSConfig.h"

#define BSConfigDefaultFileName @"BSConfig"

@implementation BSConfig

#pragma mark -
#pragma mark Lifecycle

- (id)init
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:BSConfigDefaultFileName ofType:@"plist"];
    return [[[self class] alloc] initWithFilePath:filePath];
}

- (id)initWithFilePath:(NSString *)filePath
{
    NSAssert(filePath != nil, @"Must be initialized with a file path.");
    
    if (self = [super init])
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            plist = [NSDictionary dictionaryWithContentsOfFile:filePath];
            
            if (!plist)
            {
                [NSException raise:NSInternalInconsistencyException format:@"Could not initialize the property list."];
            }
        }
        else
        {
            [NSException raise:NSInternalInconsistencyException format:@"No property list found at path '%@'", filePath];
        }
    }
    
    return self;
}

+ (BSConfig *)sharedConfig
{
    static BSConfig *sharedConfig = nil;
    
    if (sharedConfig == nil)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedConfig = [[BSConfig alloc] init];
            [sharedConfig createGetters];
        });
    }
    
    return sharedConfig;
}

- (void)dealloc
{
    plist = nil;
    map = nil;
}

#pragma mark -
#pragma mark Private Methods

/* This is inspired my GVUserDefaults by Gangverk
 * https://github.com/gangverk/GVUserDefaults
 */
- (void)createGetters
{
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    map = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < count; ++i)
    {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        const char *attributes = property_getAttributes(property);
        
        char *getter = strstr(attributes, ",G");
        if (getter)
        {
            getter = strdup(getter + 2); // Mutable copy
            getter = strsep(&getter, ",");
        }
        else
        {
            getter = strdup(name); // Mutable copy
        }
        
        SEL selector = sel_registerName(getter);

        free(getter);
        
        NSString *typeString = [NSString stringWithUTF8String:attributes];
        NSArray *components = [typeString componentsSeparatedByString:@","];
        NSString *typeAttribute = [components objectAtIndex:0];
        NSString *propertyType = [typeAttribute substringFromIndex:1];
        
        IMP implementation = NULL;
        
        // Check if it is some sort of object
        if ([typeAttribute hasPrefix:@"T@"] && [typeAttribute length] > 1)
        {
            NSString *typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length]-4)];  // @"NSString" to "NSString" or similar
            Class typeClass = NSClassFromString(typeClassName);
            implementation = implementationForClass(typeClass);
        }
        else
        {
            // It's not an object
            const char *rawPropertyType = [propertyType UTF8String];
            implementation = implementationForRawPropertyType(rawPropertyType);
        }

        // Check if we managed to find an implementation
        if (implementation == NULL)
        {
            free(properties);
            [NSException raise:NSInternalInconsistencyException format:@"Type of property '%s' is not supported.", name];
        }
        
        char type = attributes[1];
        char types[5];
        snprintf(types, 4, "%c@:", type);

        class_addMethod([self class], selector, implementation, types);
        
        NSString *propertyName = [NSString stringWithFormat:@"%s", name];
        NSString *key = [self findKeyForPropertyName:propertyName];
        [map setValue:key forKey:NSStringFromSelector(selector)];
    }
    
    free(properties);
}

static IMP implementationForRawPropertyType(const char *rawPropertyType)
{
    if (strcmp(rawPropertyType, @encode(int)) == 0) return (IMP)intGetter;
    else if (strcmp(rawPropertyType, @encode(float)) == 0) return (IMP)floatGetter;
    else if (strcmp(rawPropertyType, @encode(double)) == 0) return (IMP)doubleGetter;
    else if (strcmp(rawPropertyType, @encode(unsigned int)) == 0) return (IMP)unsignedIntGetter;
    else if (strcmp(rawPropertyType, @encode(long)) == 0) return (IMP)longGetter;
    else if (strcmp(rawPropertyType, @encode(long long)) == 0) return (IMP)longLongGetter;
    else if (strcmp(rawPropertyType, @encode(unsigned long)) == 0) return (IMP)unsignedLongGetter;
    else if (strcmp(rawPropertyType, @encode(unsigned long long)) == 0) return (IMP)unsignedLongLongGetter;
    else if (strcmp(rawPropertyType, @encode(BOOL)) == 0) return (IMP)boolGetter;
    else if (strcmp(rawPropertyType, @encode(CGSize)) == 0) return (IMP)sizeGetter;
    else if (strcmp(rawPropertyType, @encode(CGPoint)) == 0) return (IMP)pointGetter;
    else if (strcmp(rawPropertyType, @encode(CGRect)) == 0) return (IMP)rectGetter;
    else if (strcmp(rawPropertyType, @encode(UIEdgeInsets)) == 0) return (IMP)edgeInsetsGetter;
    else if (strcmp(rawPropertyType, @encode(UIOffset)) == 0) return (IMP)offsetGetter;
    
    return NULL;
}

static IMP implementationForClass(Class class)
{
    if (class == [NSString class]) return (IMP)stringGetter;
    else if (class == [NSDate class]) return (IMP)dateGetter;
    else if (class == [UIImage class]) return (IMP)imageGetter;
    else if (class == [UIColor class]) return (IMP)colorGetter;
    
    return NULL;
}

- (NSString *)findKeyForPropertyName:(NSString *)propertyName
{
    if ([self respondsToSelector:@selector(keyForPropertyName:)])
    {
        return [self performSelector:@selector(keyForPropertyName:) withObject:propertyName];
    }
    
    return propertyName;
}

- (NSString *)configKeyForSelector:(SEL)selector
{
    return [map objectForKey:NSStringFromSelector(selector)];
}

#pragma mark -
#pragma mark Getters

static int intGetter(BSConfig *config, SEL selector)
{
    NSString *key = [config configKeyForSelector:selector];
    return [config intForKeyPath:key];
}

static float floatGetter(BSConfig *config, SEL selector)
{
    NSString *key = [config configKeyForSelector:selector];
    return [config floatForKeyPath:key];
}

static double doubleGetter(BSConfig *config, SEL selector)
{
    NSString *key = [config configKeyForSelector:selector];
    return [config doubleForKeyPath:key];
}

static unsigned int unsignedIntGetter(BSConfig *config, SEL selector)
{
    NSString *key = [config configKeyForSelector:selector];
    return [config unsignedIntForKeyPath:key];
}

static long longGetter(BSConfig *config, SEL selector)
{
    NSString *key = [config configKeyForSelector:selector];
    return [config longForKeyPath:key];
}

static long long longLongGetter(BSConfig *config, SEL selector)
{
    NSString *key = [config configKeyForSelector:selector];
    return [config longForKeyPath:key];
}

static unsigned long unsignedLongGetter(BSConfig *config, SEL selector)
{
    NSString *key = [config configKeyForSelector:selector];
    return [config unsignedLongForKeyPath:key];
}

static unsigned long long unsignedLongLongGetter(BSConfig *config, SEL selector)
{
    NSString *key = [config configKeyForSelector:selector];
    return [config unsignedLongLongForKeyPath:key];
}

static BOOL boolGetter(BSConfig *config, SEL selector)
{
    NSString *key = [config configKeyForSelector:selector];
    return [config boolForKeyPath:key];
}

static CGSize sizeGetter(BSConfig *config, SEL selector)
{
    NSString *key = [config configKeyForSelector:selector];
    return [config sizeForKeyPath:key];
}

static CGPoint pointGetter(BSConfig *config, SEL selector)
{
    NSString *key = [config configKeyForSelector:selector];
    return [config pointForKeyPath:key];
}

static CGRect rectGetter(BSConfig *config, SEL selector)
{
    NSString *key = [config configKeyForSelector:selector];
    return [config rectForKeyPath:key];
}

static UIEdgeInsets edgeInsetsGetter(BSConfig *config, SEL selector)
{
    NSString *key = [config configKeyForSelector:selector];
    return [config edgeInsetsForKeyPath:key];
}

static UIOffset offsetGetter(BSConfig *config, SEL selector)
{
    NSString *key = [config configKeyForSelector:selector];
    return [config offsetForKeyPath:key];
}

static NSString* stringGetter(BSConfig *config, SEL selector)
{
    NSString *key = [config configKeyForSelector:selector];
    return [config stringForKeyPath:key];
}

static NSDate* dateGetter(BSConfig *config, SEL selector)
{
    NSString *key = [config configKeyForSelector:selector];
    return [config dateForKeyPath:key];
}

static UIImage* imageGetter(BSConfig *config, SEL selector)
{
    NSString *key = [config configKeyForSelector:selector];
    return [config imageForKeyPath:key];
}

static UIColor* colorGetter(BSConfig *config, SEL selector)
{
    NSString *key = [config configKeyForSelector:selector];
    return [config colorForKeyPath:key];
}

#pragma mark -
#pragma mark Public Methods

- (int)intForKeyPath:(NSString *)keyPath
{
    return [[plist valueForKeyPath:keyPath] intValue];
}

- (float)floatForKeyPath:(NSString *)keyPath
{
    return [[plist valueForKeyPath:keyPath] floatValue];
}

- (double)doubleForKeyPath:(NSString *)keyPath
{
    return [[plist valueForKeyPath:keyPath] doubleValue];
}

- (unsigned int)unsignedIntForKeyPath:(NSString *)keyPath
{
    return [[plist valueForKeyPath:keyPath] unsignedIntValue];
}

- (long)longForKeyPath:(NSString *)keyPath
{
    id value = [plist valueForKeyPath:keyPath];
    
    if ([value isKindOfClass:[NSNumber class]])
    {
        return [value longValue];
    }
    else if ([value isKindOfClass:[NSString class]])
    {
        return strtol([value UTF8String], NULL, 0);
    }
    
    return 0;
}

- (long long)longLongForKeyPath:(NSString *)keyPath
{
    id value = [plist valueForKeyPath:keyPath];
    
    if ([value isKindOfClass:[NSNumber class]])
    {
        return [value longValue];
    }
    else if ([value isKindOfClass:[NSString class]])
    {
        return strtoll([value UTF8String], NULL, 0);
    }
    
    return 0;
}

- (unsigned long)unsignedLongForKeyPath:(NSString *)keyPath
{
    id value = [plist valueForKeyPath:keyPath];
    
    if ([value isKindOfClass:[NSNumber class]])
    {
        return [value longValue];
    }
    else if ([value isKindOfClass:[NSString class]])
    {
        return strtoul([value UTF8String], NULL, 0);
    }
    
    return 0;
}

- (unsigned long long)unsignedLongLongForKeyPath:(NSString *)keyPath
{
    id value = [plist valueForKeyPath:keyPath];
    
    if ([value isKindOfClass:[NSNumber class]])
    {
        return [value longValue];
    }
    else if ([value isKindOfClass:[NSString class]])
    {
        return strtoull([value UTF8String], NULL, 0);
    }
    
    return 0;
}

- (BOOL)boolForKeyPath:(NSString *)keyPath
{
    return [[plist valueForKeyPath:keyPath] boolValue];
}

- (CGSize)sizeForKeyPath:(NSString *)keyPath
{
    NSString *value = [plist valueForKeyPath:keyPath];
    if (!value)
    {
        return CGSizeZero;
    }
    
    NSString *pattern = @"^[\t, ]*(-?\\d+\\.\\d+|-?\\d+)[\t, ]*[x,X,\\*][\t, ]*(-?\\d+\\.\\d+|-?\\d+)[\t, ]*$";
    NSRegularExpression *regex = [NSRegularExpression regexWithPattern:pattern];
    NSArray *matches = [regex matchesInString:value];
    if ([matches count] == 0)
    {
        return CGSizeZero;
    }
    
    NSTextCheckingResult *match = [matches objectAtIndex:0];
    
    CGFloat width = [[match groupAtIndex:1 inString:value] floatValue];
    CGFloat height = [[match groupAtIndex:2 inString:value] floatValue];

    return CGSizeMake(width, height);
}

- (CGPoint)pointForKeyPath:(NSString *)keyPath
{
    NSString *value = [plist valueForKeyPath:keyPath];
    if (!value)
    {
        return CGPointZero;
    }
    
    NSString *pattern = @"^[\t, ]*(-?\\d+\\.\\d+|-?\\d+)[\t, ]*[\\,;][\t, ]*(-?\\d+\\.\\d+|-?\\d+)[\t, ]*$";
    NSRegularExpression *regex = [NSRegularExpression regexWithPattern:pattern];
    NSArray *matches = [regex matchesInString:value];
    if ([matches count] == 0)
    {
        return CGPointZero;
    }
    
    NSTextCheckingResult *match = [matches objectAtIndex:0];
    
    CGFloat x = [[match groupAtIndex:1 inString:value] floatValue];
    CGFloat y = [[match groupAtIndex:2 inString:value] floatValue];
    
    return CGPointMake(x, y);
}

- (CGRect)rectForKeyPath:(NSString *)keyPath
{
    NSString *value = [plist valueForKeyPath:keyPath];
    if (!value)
    {
        return CGRectZero;
    }
    
    NSString *pattern = @"^[\t, ]*(-?\\d+\\.\\d+|-?\\d+)[\t, ]*[\\,;][\t, ]*(-?\\d+\\.\\d+|-?\\d+)[\t, ]*[\\,;][\t, ]*(-?\\d+\\.\\d+|-?\\d+)[\t, ]*[\\,;][\t, ]*(-?\\d+\\.\\d+|-?\\d+)[\t, ]*$";
    NSRegularExpression *regex = [NSRegularExpression regexWithPattern:pattern];
    NSArray *matches = [regex matchesInString:value];
    if ([matches count] == 0)
    {
        return CGRectZero;
    }
    
    NSTextCheckingResult *match = [matches objectAtIndex:0];
    
    CGFloat x = [[match groupAtIndex:1 inString:value] floatValue];
    CGFloat y = [[match groupAtIndex:2 inString:value] floatValue];
    CGFloat width = [[match groupAtIndex:3 inString:value] floatValue];
    CGFloat height = [[match groupAtIndex:4 inString:value] floatValue];
    
    return CGRectMake(x, y, width, height);
}

- (UIEdgeInsets)edgeInsetsForKeyPath:(NSString *)keyPath
{
    NSString *value = [plist valueForKeyPath:keyPath];
    if (!value)
    {
        return UIEdgeInsetsZero;
    }
    
    NSString *pattern = @"^[\t, ]*(-?\\d+\\.\\d+|-?\\d+)[\t, ]*[\\,;][\t, ]*(-?\\d+\\.\\d+|-?\\d+)[\t, ]*[\\,;][\t, ]*(-?\\d+\\.\\d+|-?\\d+)[\t, ]*[\\,;][\t, ]*(-?\\d+\\.\\d+|-?\\d+)[\t, ]*$";
    NSRegularExpression *regex = [NSRegularExpression regexWithPattern:pattern];
    NSArray *matches = [regex matchesInString:value];
    if ([matches count] == 0)
    {
        return UIEdgeInsetsZero;
    }
    
    NSTextCheckingResult *match = [matches objectAtIndex:0];
    
    CGFloat top = [[match groupAtIndex:1 inString:value] floatValue];
    CGFloat left = [[match groupAtIndex:2 inString:value] floatValue];
    CGFloat bottom = [[match groupAtIndex:3 inString:value] floatValue];
    CGFloat right = [[match groupAtIndex:4 inString:value] floatValue];
    
    return UIEdgeInsetsMake(top, left, bottom, right);
}

- (UIOffset)offsetForKeyPath:(NSString *)keyPath
{
    NSString *value = [plist valueForKeyPath:keyPath];
    if (!value)
    {
        return UIOffsetZero;
    }
    
    NSString *pattern = @"^[\t, ]*(-?\\d+\\.\\d+|-?\\d+)[\t, ]*[\\,;][\t, ]*  (-?\\d+\\.\\d+|-?\\d+)[\t, ]*$";
    NSRegularExpression *regex = [NSRegularExpression regexWithPattern:pattern];
    NSArray *matches = [regex matchesInString:value];
    if ([matches count] == 0)
    {
        return UIOffsetZero;
    }
    
    NSTextCheckingResult *match = [matches objectAtIndex:0];
    
    CGFloat horizontal = [[match groupAtIndex:1 inString:value] floatValue];
    CGFloat vertical = [[match groupAtIndex:2 inString:value] floatValue];
    
    return UIOffsetMake(horizontal, vertical);
}

- (NSString *)stringForKeyPath:(NSString *)keyPath
{
    id value = [plist valueForKey:keyPath];
    if ([value isKindOfClass:[NSString class]])
    {
        return value;
    }
    else if ([value isKindOfClass:[NSNumber class]])
    {
        return [value stringValue];
    }
    
    return nil;
}

- (NSDate *)dateForKeyPath:(NSString *)keyPath
{
    id value = [plist valueForKey:keyPath];
    if ([value isKindOfClass:[NSDate class]])
    {
        return value;
    }
    
    return nil;
}

- (UIImage *)imageForKeyPath:(NSString *)keyPath
{
    id value = [plist valueForKeyPath:keyPath];
    if (![value isKindOfClass:[NSString class]])
    {
        return nil;
    }
    
    // Check if we can match a resizable image
    NSString *resizablePattern = @"^[\t, ]*(.*)[\t, ](-?\\d+\\.\\d+|-?\\d+)[\t, ]*[\\,;][\t, ]*(-?\\d+\\.\\d+|-?\\d+)[\t, ]*[\\,;][\t, ]*(-?\\d+\\.\\d+|-?\\d+)[\t, ]*[\\,;][\t, ]*(-?\\d+\\.\\d+|-?\\d+)[\t, ]*$";
    NSRegularExpression *resizableRegex = [NSRegularExpression regexWithPattern:resizablePattern];
    NSArray *resizableMatches = [resizableRegex matchesInString:value];
    if ([resizableMatches count] > 0)
    {
        NSTextCheckingResult *match = [resizableMatches objectAtIndex:0];
        
        NSString *name = [match groupAtIndex:1 inString:value];
        CGFloat top = [[match groupAtIndex:2 inString:value] floatValue];
        CGFloat left = [[match groupAtIndex:3 inString:value] floatValue];
        CGFloat bottom = [[match groupAtIndex:4 inString:value] floatValue];
        CGFloat right = [[match groupAtIndex:5 inString:value] floatValue];
        
        UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
        return [[UIImage imageNamed:name] resizableImageWithCapInsets:insets];
    }
    else
    {
        // Check if we can match a stretchable image
        NSString *stretchablePattern = @"^[\t, ]*(.*)[\t, ](-?\\d+\\.\\d+|-?\\d+)[\t, ]*[\\,;][\t, ]*(-?\\d+\\.\\d+|-?\\d+)[\t, ]*$";
        NSRegularExpression *stretchableRegex = [NSRegularExpression regexWithPattern:stretchablePattern];
        NSArray *stretchableMatches = [stretchableRegex matchesInString:value];
        if ([stretchableMatches count] > 0)
        {
            NSTextCheckingResult *match = [stretchableMatches objectAtIndex:0];
            
            NSString *name = [match groupAtIndex:1 inString:value];
            NSInteger leftCapWidth = [[match groupAtIndex:2 inString:value] integerValue];
            NSInteger topCapHeight = [[match groupAtIndex:3 inString:value] integerValue];
            
            return [[UIImage imageNamed:name] stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
        }
    }
    
    return [UIImage imageNamed:value];
}

- (UIColor *)colorForKeyPath:(NSString *)keyPath
{
    id value = [plist valueForKeyPath:keyPath];
    if (![value isKindOfClass:[NSString class]])
    {
        return nil;
    }
    
    NSString *hexPattern = @"^[\t, ]*#?[[0-9],ABCDEFabcdef]{3,8}[\t, ]*$";
    NSRegularExpression *hexRegex = [NSRegularExpression regexWithPattern:hexPattern];
    NSArray *hexMatches = [hexRegex matchesInString:value];
    if ([hexMatches count] > 0)
    {
        return [UIColor colorWithHexString:value];
    }
    else
    {
        // Check if RGBA pattern
        NSString *rgbaPattern = @"^[\t, ]*(2[0-5][0-5]|1[0-9][0-9]|0?[0-9][0-9]|0?0?[0-9])[\t, ]*[\\,;][\t, ]*(2[0-5][0-5]|1[0-9][0-9]|0?[0-9][0-9]|0?0?[0-9])[\t, ]*[\\,;][\t, ]*(2[0-5][0-5]|1[0-9][0-9]|0?[0-9][0-9]|0?0?[0-9])[\t, ]*[\\,;][\t, ]*(0+\\.\\d+|1\\.0+|0+|1)[\t, ]*$";
        NSRegularExpression *rgbaRegex = [NSRegularExpression regexWithPattern:rgbaPattern];
        NSArray *rgbaMatches = [rgbaRegex matchesInString:value];
        if ([rgbaMatches count] > 0)
        {
            NSTextCheckingResult *match = [rgbaMatches objectAtIndex:0];
            
            CGFloat r = [[match groupAtIndex:1 inString:value] floatValue];
            CGFloat g = [[match groupAtIndex:2 inString:value] floatValue];
            CGFloat b = [[match groupAtIndex:3 inString:value] floatValue];
            CGFloat a = [[match groupAtIndex:4 inString:value] floatValue];
            
            return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a];
        }
        else
        {
            // Check if RGB pattern
            NSString *rgbPattern = @"^[\t, ]*(2[0-5][0-5]|1[0-9][0-9]|0?[0-9][0-9]|0?0?[0-9])[\t, ]*[\\,;][\t, ]*(2[0-5][0-5]|1[0-9][0-9]|0?[0-9][0-9]|0?0?[0-9])[\t, ]*[\\,;][\t, ]*(2[0-5][0-5]|1[0-9][0-9]|0?[0-9][0-9]|0?0?[0-9])[\t, ]*$";
            NSRegularExpression *rgbRegex = [NSRegularExpression regexWithPattern:rgbPattern];
            NSArray *rgbMatches = [rgbRegex matchesInString:value];
            if ([rgbMatches count] > 0)
            {
                NSTextCheckingResult *match = [rgbMatches objectAtIndex:0];

                CGFloat r = [[match groupAtIndex:1 inString:value] floatValue];
                CGFloat g = [[match groupAtIndex:2 inString:value] floatValue];
                CGFloat b = [[match groupAtIndex:3 inString:value] floatValue];

                return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f];
            }
        }
    }
    
    return nil;
}

@end
