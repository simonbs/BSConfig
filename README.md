BSConfig
========

BSConfig provides an easy way to manage configurations in your iOS app.

There are a lot of uses for this. You can easily take most of the constants in your app and put them into a property list to easily change them later on. This is especially useful for designers who can are not comfortable with code. Using BSConfig they can change constants, insets, offsets, strings, images and colors through a property list.

BSConfig is inspired by [episode 15](http://www.imore.com/debug-15-simmons-wiskus-gruber-and-vesper) of the [Guy English](https://twitter.com/gte) and [Rene Ritchies](https://twitter.com/reneritchie) podcast Debug in which [Brent Simmons](https://twitter.com/brentsimmons), [Dave Wiskus](https://twitter.com/dwiskus) and [John Gruber](https://twitter.com/daringfireball) explains how they have used a property list to manage constants in their [Vesper app](http://vesperapp.co).

The implementation is greatly inspired by [GVUserDefaults](https://github.com/gangverk/GVUserDefaults) developed by [Gangverk](https://github.com/gangverk).

## Installation

Just clone this repository and copy the `BSControls/` directory into your project. There are no dependencies.

## Usage

There are two ways to use BSConfig. Create a category on BSConfi, add properties to the category and remember to make the properties `@dynamic`.
Now, create `BSConfig.plist` and add the key/value pairs where the key is the name of the property on the category.

	// .h
	@interface BSConfig (Configs)
	
	@property (nonatomic, readonly) CGSize someSize;
	@property (nonatomic, readonly) CGPoint somePoint;
	@property (nonatomic, readonly) UIOffset someOffset;
	@property (nonatomic, readonly) NSString *someString;
	@property (nonatomic, readonly) UIImage *someImage;
	@property (nonatomic, readonly) UIColor *someColor;
	
	@end
	
	// .m
	@implementation BSConfig (Configs)
	
	@dynamic someSize, somePoint, someOffset, someString, someImage, someColor;
	
	@end

You can now access the constants in your plist using the properties in your category like so:

	UIImage *image = [BSConfig sharedConfig].someImage;

This is shown in greater detail in the example project.

You can also create an instance of BSConfig using `-initWithFilePath:`. Just give the file path to some property list. Now you can access the constants in your plist using a wide range of methods BSConfig. For example, if you want an image, you can do:

	BSConfig *config = [[BSConfig alloc] initWithFilePath:myFilePath];
	UIImage *image = [config imageForKeyPath:@"someImage"];

The structure of your plist is not important when using this approach. Every method takes a key path as its argument, so you can have

	BSConfig *config = [[BSConfig alloc] initWithFilePath:myFilePath];
	UIColor *color = [config colorForKeyPath:@"colors.someColor"];
	
This approach (in contrary to using the `sharedConfig`) allows you to have multiple config files.

## Custom key names

If you are using the category approach, BSConfig will look for a key in the plist with the same name as the property on your category. If you want to change this, you can do so by implementing `-keyForPropertyName:` in your category. For example, if you have prefixed all keys in your plist with "BS", then you want to tell BSConfig to look for this. You can do it like so:

	- (NSString *)keyForPropertyName:(NSString *)propertyName
	{
	    return [NSString stringWithFormat:@"BS%@", propertyName];
	}

## Syntax

BSConfig comes with a special syntax for values in the property list. This allows you to store instances of CGSize, CGRect, UIColor, UIImage and more.
Strings, integers, floats, bools, dates and much more are as you would expect but I would like to go over those which may not  be completley obvious - but which are really handy.

All of these are created by adding a property with the same type on the category or by calling the corresponding method with a key path on an instance of BSConfig.

#### CGSize

A value of `100 , 300` or `100 ; 300` translates to`CGSizeMake(100, 300)`

#### CGPoint

A value of `20 , 5` or `20 ; 5` translates to`CGPointMake(20, 5)`

#### CGRect

A value of `20 , 5 , 100 , 300` or `20 ; 5 ; 100 ; 300` translates to `CGRectMake(20, 5, 100, 300)`

#### UIEdgeInsets

A value of `3, 6, 4, 2` or `3 ; 6 ; 4 ; 2` translates to `UIEdgeInsetsMake(3, 6, 4, 2)`

#### UIOffset

A value of `10, 5` or `10 ; 5` translates to `UIOffsetMake(10, 5)`

#### UIImage

A value of `colosseum.jpg` translates to `[UIImage imageNamed:@"colosseum.jpg"]`

A value of `colosseum.jpg 5 , 10` or `colosseum.jpg 5 ; 10` translates to `[[UIImage imageNamed:@"colosseum.jpg"] stretchableImageWithLeftCapWidth:10 topCapHeight:5]`

A value of `colosseum.jpg 5 , 10 , 3 , 7` or `colosseum.jpg 5 ; 10 ; 3 ; 7` translates to `[[UIImage imageNamed:@"colosseum.jpg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 10, 3, 7)]`

#### UIColor

UIColors can be created with either HEX, RGB or RGBA values. For example:

A value of `#ff0000` translates to `[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f]`

A value of `#ff00004b` translates to `[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.75f]`

A value of `255, 128, 0` translates to `[UIColor colorWithRed:255/255.0f green:128.0f/255.0f blue:0.0f/255.0f alpha:1.0f]`

A value of `255, 128, 0, 0.75` translates to `[UIColor colorWithRed:255/255.0f green:128.0f/255.0f blue:0.0f/255.0f alpha:0.75f]`

## Example Project

This repository includes a simple example project which shows how to create a category on BSConfig and add properties to the category. The project also comes with a sample property list.

## Credits

BSConfig is developed by [@simonbs](http://twitter.com/simonbs), [simonbs.dk](http://simonbs.dk) Feel free to fork the repository and send pull requests if you have made something awesome.

## License

BSConfig is released under the MIT license. Please see the LICENSE file for more information.