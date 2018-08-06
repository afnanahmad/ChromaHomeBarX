#import <QuartzCore/QuartzCore.h>
#import "libcolorpicker.h"
#define chromahomebarxPrefs @"/var/mobile/Library/Preferences/com.afnanahmad.chromahomebarxpref.plist"

static NSUInteger totalColors = 2;


static NSMutableDictionary *settings;
BOOL enabled = NO;
NSString *style = @"Wave";
UIColor *firstColor = [UIColor blueColor];
UIColor *secondColor = [UIColor redColor];

UIColor *breathingColor = [UIColor blueColor];
UIColor *staticColor = [UIColor blueColor];


void refreshPrefs() {
    NSString *fade1FallbackHex = @"#F62459";
    NSString *fade2FallbackHex = @"#BF55EC";
    NSString *breathingFallbackHex = @"#2ABB9B";
    NSString *staticFallbackHex = @"#F62459";

    settings = nil;
    settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[chromahomebarxPrefs stringByExpandingTildeInPath]];
    if([settings objectForKey:@"enabled"])enabled = [[settings objectForKey:@"enabled"] boolValue];
    if([settings objectForKey:@"style"])style = [[settings objectForKey:@"style"] stringValue];
    if([settings objectForKey:@"fadeColor1"]){
        firstColor = LCPParseColorString([[settings objectForKey:@"fadeColor1"] stringValue], fade1FallbackHex);
    } else
    {
        firstColor = LCPParseColorString(fade1FallbackHex, fade1FallbackHex);
    }

    if([settings objectForKey:@"fadeColor2"]){
        secondColor = LCPParseColorString([[settings objectForKey:@"fadeColor2"] stringValue], fade2FallbackHex);
    } else
    {
        secondColor = LCPParseColorString(fade2FallbackHex, fade2FallbackHex);
    }

    if([settings objectForKey:@"breathingColor"]){breathingColor = LCPParseColorString([[settings objectForKey:@"breathingColor"] stringValue], breathingFallbackHex);

    } else
    {
        breathingColor = LCPParseColorString(breathingFallbackHex, breathingFallbackHex);
    }

    if([settings objectForKey:@"staticColor"]){staticColor = LCPParseColorString([[settings objectForKey:@"staticColor"] stringValue], staticFallbackHex);
    } else
    {
        staticColor = LCPParseColorString(staticFallbackHex, staticFallbackHex);
    }
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    refreshPrefs();
}


/////////////////////////////

@interface MTLumaDodgePillView : UIView
@end

@interface MTStaticColorPillView : UIView {
    UIColor * _pillColor;
}

@property (nonatomic, retain) UIColor *pillColor;

@end

/////////////////////////////

@interface ColorPillView : UIView <CAAnimationDelegate>

@property (nonatomic, assign) NSUInteger colorNum;
@property (nonatomic, assign) NSUInteger currentHueNum;
@property (nonatomic, strong) NSMutableArray *colors;

- (void)animateView;
- (void)specturmView;
- (void)waveView;
- (void)staticView;
- (void)fadeView;
- (void)breathingView;

@end

@implementation ColorPillView

- (instancetype)initWithFrame:(CGRect)frame {
    self  = [super initWithFrame:frame];
    if (self) {
        _colorNum = 0;
        _currentHueNum = 0;
        self.layer.backgroundColor = staticColor.CGColor;

        if ([style isEqual:@"Wave"]) {
            self.layer.backgroundColor = [[UIColor alloc] initWithHue:_currentHueNum/360.0f saturation:1 brightness:1 alpha:1].CGColor;
        } else if ([style isEqual:@"Spectrum"]) {
            self.layer.backgroundColor = [[UIColor alloc] initWithHue:_currentHueNum/360.0f saturation:1 brightness:1 alpha:1].CGColor;
        } else if ([style isEqual:@"Fade"]) {
            self.layer.backgroundColor = firstColor.CGColor;
        } else if ([style isEqual:@"Breathing"]) {
            self.layer.backgroundColor = breathingColor.CGColor;
        } else if ([style isEqual:@"Static"]) {
            self.layer.backgroundColor = staticColor.CGColor;
        }

        CAGradientLayer *layer = (id)[self layer];
        [layer setStartPoint:CGPointMake(0.0, 0.5)];
        [layer setEndPoint:CGPointMake(1.0, 0.5)];

        // Create colors using hues in +5 increments
        self.colors = [NSMutableArray array];
        for (CGFloat hue = 0; hue <= 360; hue += 1) {

            UIColor *color;
            color = [UIColor colorWithHue:1.0 * hue / 360.0
                               saturation:1.0
                               brightness:1.0
                                    alpha:1.0];
            [self.colors addObject:(id)[color CGColor]];
        }
    }

    return self;
}

- (void)animateView {
    self.colorNum++;
    self.colorNum = self.colorNum % totalColors;
    UIColor *newColor = firstColor;
    if (self.colorNum == 1) {
        newColor = secondColor;
    }

    __weak ColorPillView *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:1.0
                         animations:^{
                             weakSelf.layer.backgroundColor = newColor.CGColor;
                         }
                         completion:^(BOOL finished) {
                             [weakSelf animateView];
                         }];
    });
}

- (void)staticView {
    self.layer.backgroundColor = staticColor.CGColor;
}

- (void)specturmView {
    __weak ColorPillView *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.1
                         animations:^{
                             weakSelf.layer.backgroundColor = [[UIColor alloc] initWithHue:weakSelf.currentHueNum/360.0f saturation:1 brightness:1 alpha:1].CGColor;
                         }
                         completion:^(BOOL finished) {
                             weakSelf.currentHueNum++;
                             if (weakSelf.currentHueNum > 360)
                             {
                                 weakSelf.currentHueNum = 0;
                             }
                             [weakSelf specturmView];
                         }];
    });
}

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (void)waveView {
    // Move the last color in the array to the front
    // shifting all the other colors.
    CAGradientLayer *layer = (id)[self layer];
    NSMutableArray *mutableArray = self.colors;
    id lastColor = [mutableArray lastObject];
    [mutableArray removeLastObject];
    [mutableArray insertObject:lastColor atIndex:0];
    NSArray *shiftedColors = [NSArray arrayWithArray:mutableArray];

    NSArray *itemsForView = [shiftedColors subarrayWithRange: NSMakeRange( 0, shiftedColors.count / 6 )];

    // Update the colors on the model layer
    [layer setColors:itemsForView];

    // Create an animation to slowly move the gradient left to right.
    CABasicAnimation *animation;
    animation = [CABasicAnimation animationWithKeyPath:@"colors"];
    [animation setToValue:itemsForView];
    [animation setDuration:0.01];
    [animation setRemovedOnCompletion:YES];
    [animation setFillMode:kCAFillModeForwards];
    [animation setDelegate:self];
    [layer addAnimation:animation forKey:@"animateGradient"];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    [self waveView];
}

- (void)breathingView {
    self.colorNum++;
    self.colorNum = self.colorNum % totalColors;
    UIColor *newColor = breathingColor;
    if (self.colorNum == 1) {
        newColor = [breathingColor colorWithAlphaComponent:0];
    }

    __weak ColorPillView *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:10.0
                         animations:^{
                             weakSelf.layer.backgroundColor = newColor.CGColor;
                         }
                         completion:^(BOOL finished) {
                             [weakSelf breathingView];
                         }];
    });
}

- (void)fadeView {
    self.colorNum++;
    self.colorNum = self.colorNum % totalColors;
    UIColor *newColor = firstColor;
    if (self.colorNum == 1) {
        newColor = secondColor;
    }

    __weak ColorPillView *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:10.0
                         animations:^{
                             weakSelf.layer.backgroundColor = newColor.CGColor;
                         }
                         completion:^(BOOL finished) {
                             [weakSelf fadeView];
                         }];
    });
}


@end

////////////////////////////

/*%hook SpringBoard
 -(void) applicationDidFinishLaunching:(id)arg {
 %orig(arg);
 UIAlertView *lookWhatWorks = [[UIAlertView alloc] initWithTitle:@"HomeBar Color Tweak"
 message:[@"Loaded!!\nFucking Awesome: " stringByAppendingString:style]
 delegate:self
 cancelButtonTitle:@"OK"
 otherButtonTitles:nil];
 [lookWhatWorks show];
 }
 %end*/


%hook MTLumaDodgePillView
-(void)initWithFrame:(CGRect)arg1{
    %orig(arg1);
    //self.alpha = 1;
}

-(void)layoutSubviews{
    %orig;

    if (enabled) {

        int tag = 115;

        UIView *colorView = [self viewWithTag:tag];
        if (!colorView) {
            refreshPrefs();
            ColorPillView *colorView = [[ColorPillView alloc] initWithFrame:self.bounds];
            colorView.tag = 115;
            colorView.layer.cornerRadius = self.bounds.size.height / 2;
            //colorView.backgroundColor = [UIColor redColor];
            colorView.colorNum = 0;
            [self addSubview:colorView];

            if ([style isEqual:@"Wave"]) {
                [colorView waveView];
            } else if ([style isEqual:@"Spectrum"]) {
                [colorView specturmView];
            } else if ([style isEqual:@"Fade"]) {
                [colorView fadeView];
            } else if ([style isEqual:@"Breathing"]) {
                [colorView breathingView];
            } else if ([style isEqual:@"Static"]) {
                [colorView staticView];
            }

        }

        CGRect frame = colorView.frame;
        frame.size.height = self.frame.size.height;
        frame.size.width = self.frame.size.width;
        colorView.frame = frame;
    }

}

%new
-(void)animateView{
    int tag = 115;

    ColorPillView *colorView = [self viewWithTag:tag];

    UIColor *newColor = [UIColor blueColor];
    if (colorView.colorNum == 1) {
        newColor = [UIColor redColor];
        colorView.colorNum = 0;
    } else {
        newColor = [UIColor blueColor];
        colorView.colorNum = 1;
    }

    __weak UIView *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:10.0
                         animations:^{
                             colorView.backgroundColor = newColor;
                         }
                         completion:^(BOOL finished) {
                             colorView.backgroundColor = newColor;
                             [weakSelf performSelector:@selector(animateView)];
                         }];
    });
}

%end


%hook MTStaticColorPillView
-(void)initWithFrame:(CGRect)arg1{
    %orig(arg1);
    //self.alpha = 1;
}

-(void)layoutSubviews{
    %orig;

    if (enabled) {

        int tag = 115;

        UIView *colorView = [self viewWithTag:tag];
        if (!colorView) {
            refreshPrefs();
            ColorPillView *colorView = [[ColorPillView alloc] initWithFrame:self.bounds];
            colorView.tag = 115;
            colorView.layer.cornerRadius = self.bounds.size.height / 2;
            colorView.backgroundColor = [UIColor redColor];
            colorView.colorNum = 0;
            [self addSubview:colorView];

            if ([style isEqual:@"Wave"]) {
                [colorView waveView];
            } else if ([style isEqual:@"Spectrum"]) {
                [colorView specturmView];
            } else if ([style isEqual:@"Fade"]) {
                [colorView fadeView];
            } else if ([style isEqual:@"Breathing"]) {
                [colorView breathingView];
            } else if ([style isEqual:@"Static"]) {
                [colorView staticView];
            }
        }
    }
}

%end


%ctor {
    @autoreleasepool {
        settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[chromahomebarxPrefs stringByExpandingTildeInPath]];
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, CFSTR("com.afnanahmad.chromahomebarx.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        refreshPrefs();
    }
}
