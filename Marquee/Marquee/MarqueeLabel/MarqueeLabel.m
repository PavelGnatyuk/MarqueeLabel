//
//  MarqueeLabel.m
//  Marquee
//
//  Created by Pavel Gnatyuk on 7/6/12.
//  Copyright (c) 2012 Software Developer. All rights reserved.
//

#import "MarqueeLabel.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const _fadingLength = 10.0f;

@interface MarqueeLabel ()

@property (retain) UILabel          *labelChild;
@property (assign) CGRect           labelFrame;
@property (assign) CGRect           extraLabelFrame;
@property (assign) NSTimeInterval   animationDuration;
@property (assign) NSTimeInterval   animationBorderDelay;
@property (assign) BOOL             paused;
@property (assign, readonly) BOOL   labelShouldScroll;
@property (assign) CGPoint          endPoint;
@property (assign) CGFloat          fadingLength;

@property (retain) UITapGestureRecognizer *tapRecognizer;

@end

@implementation MarqueeLabel

@synthesize text = _text, font = _font;
@synthesize labelChild, labelFrame, extraLabelFrame, animationDuration, animationBorderDelay, animationRate;
@synthesize fadingLength, paused;
@synthesize endPoint;
@synthesize tapRecognizer = _tapRecognizer;
@dynamic labelShouldScroll;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        [self setup];
    }
    return self;
}    

- (void)dealloc
{
    [self removeGestureRecognizer:[self tapRecognizer]];
    
    [labelChild release];
    [_text release];
    [_font release];
    [_tapRecognizer release];
    [super dealloc];
}

- (void)setup
{
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    // Create child label
    UILabel *child = [[UILabel alloc] initWithFrame:[self bounds]];
    [self setLabelChild:child];
    [child setBackgroundColor:[UIColor clearColor]];
    [self addSubview:child];
    [child release];
    
    [self addFadingOf:_fadingLength];
    
    [self setAnimationRate:24.0];
    [self setAnimationBorderDelay:0.6];
    [self setPaused:NO];
    
    UITapGestureRecognizer *newTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wasTapped:)];
    [self addGestureRecognizer:newTapRecognizer];
    [self setTapRecognizer:newTapRecognizer];
    [newTapRecognizer release];    
}

- (BOOL)labelShouldScroll 
{
    return ( ( [self text] != nil) && ( !CGRectContainsRect( [self bounds], [self labelFrame] ) ) );
}

- (void)scroll:(NSTimeInterval)interval 
{
    if ( [self labelShouldScroll] ) {
        
        CABasicAnimation* moving = [CABasicAnimation animationWithKeyPath:@"position"];
        moving.fromValue = [NSValue valueWithCGPoint:[[[self labelChild] layer] position]];
        moving.toValue = [NSValue valueWithCGPoint:[self endPoint]];
        moving.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        moving.beginTime = 0;
        moving.duration = interval;
        moving.autoreverses = YES;
        moving.repeatCount = INT_MAX;
        [[[self labelChild] layer] addAnimation:moving forKey:@"position"];
        
    }
    return;
}

- (void)calculate
{
    CGSize maximumLabelSize = CGSizeMake(9999, self.frame.size.height);
    CGSize expectedLabelSize = [_text sizeWithFont:[[self labelChild] font]
                                 constrainedToSize:maximumLabelSize
                                     lineBreakMode:[[self labelChild] lineBreakMode]];
    
    [self setLabelFrame:CGRectMake( [self fadingLength], 0, expectedLabelSize.width + [self fadingLength], [self bounds].size.height )];
    [self setExtraLabelFrame:CGRectOffset( [self labelFrame], -expectedLabelSize.width + self.bounds.size.width - 2 * [self fadingLength], 0.0)];
    
    [self setEndPoint:CGPointMake( [self bounds].size.width - 2 * [self fadingLength] - expectedLabelSize.width / 2, [self bounds].size.height / 2 ) ];
    [self setAnimationDuration:( (NSTimeInterval) fabs([self extraLabelFrame].origin.x) / [self animationRate] )];
}

- (void)setText:(NSString *)newText 
{
    if ( newText == nil ) {
        [_text release];
        _text = nil;
    }
    
    if ( ![newText isEqualToString:_text] ) {
        [_text release];
        _text = [newText copy];
        [[[self labelChild] layer] removeAllAnimations];
        [self calculate];
        [[self labelChild] setFrame:[self labelFrame]];
        [[self labelChild] setText:_text];
        [self scroll:[self animationDuration]];
    }
}

- (NSString *)text {
    return _text;
}

- (void)setFont:(UIFont *)newFont
{
    if ( [self labelChild] ) {
        [_font release];
        _font = [newFont retain];
        [[[self labelChild] layer] removeAllAnimations];
        [[self labelChild] setFont:newFont];
        [self calculate];
        [self scroll:[self animationDuration]];
    }
}

- (void)addFadingOf:(CGFloat)pixels 
{
    if ( pixels >  0.0f ) {
        CAGradientLayer* gradientMask = [CAGradientLayer layer];
        gradientMask.bounds = [[self layer] bounds];
        gradientMask.position = CGPointMake([self bounds].size.width / 2, [self bounds].size.height / 2);
        gradientMask.startPoint = CGPointMake(0.0, CGRectGetMidY( [self frame] ));
        gradientMask.endPoint = CGPointMake(1.0, CGRectGetMidY( [self frame] ));
        CGFloat fadePoint = pixels / [self frame].size.width;
        [gradientMask setColors: [NSArray arrayWithObjects: (id)[[UIColor clearColor] CGColor], 
                                  (id)[[UIColor blackColor] CGColor], 
                                  (id)[[UIColor blackColor] CGColor], 
                                  (id)[[UIColor clearColor] CGColor], 
                                  nil]];
        [gradientMask setLocations: [NSArray arrayWithObjects:
                                     [NSNumber numberWithFloat: 0.0],
                                     [NSNumber numberWithFloat: fadePoint],
                                     [NSNumber numberWithFloat: 1 - fadePoint],
                                     [NSNumber numberWithFloat: 1.0],
                                     nil]];
        [[self layer] setMask:gradientMask];
        [self setFadingLength:pixels];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [UILabel instanceMethodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation 
{
    if ([[self labelChild] respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:[self labelChild]];
    } else {
        NSLog(@"MarqueeLabel does not recognize the selector");
        [super forwardInvocation:anInvocation];
    }
}

- (id)valueForUndefinedKey:(NSString *)key 
{
    return [[self labelChild] valueForKey:key];
}

- (void) setValue:(id)value forUndefinedKey:(NSString *)key 
{
    [[self labelChild] setValue:value forKey:key];
}

- (void)wasTapped:(UITapGestureRecognizer *)recognizer 
{
    if ( [self labelShouldScroll] ) {
        [self setPaused:![self paused]];
        if ( [self paused] ) {
            [[[self labelChild] layer] removeAnimationForKey:@"position"];
        }
        else {
            [self scroll:[self animationDuration]];
        }
    }
}

@end
