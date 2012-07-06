//
//  MarqueeLabel.m
//  Marquee
//
//  Created by Pavel Gnatyuk on 7/6/12.
//  Copyright (c) 2012 Software Developer. All rights reserved.
//

#import "MarqueeLabel.h"

@interface MarqueeLabel ()

@property (retain) UILabel          *labelChild;
@property (assign) CGRect           labelFrame;
@property (assign) CGRect           extraLabelFrame;
@property (assign) NSTimeInterval   animationDuration;
@property (assign) NSTimeInterval   animationBorderDelay;
@property (assign) BOOL             labelMoved;

@property (assign, readonly) BOOL   labelShouldScroll;

@end

@implementation MarqueeLabel

@synthesize text = _text;
@synthesize labelChild, labelFrame, extraLabelFrame, animationDuration, animationBorderDelay, animationRate, labelMoved;
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
    [labelChild release];
    [_text release];
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
    
    [self setAnimationRate:24.0];
    [self setAnimationBorderDelay:0.6];
    [self setLabelMoved:NO];
}

- (BOOL)labelShouldScroll 
{
    return ( ( [self text] != nil) && ( !CGRectContainsRect( [self bounds], [self labelFrame] ) ) );
}

- (void)returnLabelToOriginImmediately 
{
    if ( !CGRectEqualToRect( [self labelChild].frame, [self labelFrame] ) ) {
        [UIView animateWithDuration:0
                              delay:0
                            options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState) 
                         animations:^{
                             [[self labelChild] setFrame:[self labelFrame]];
                             
                         }
                         completion:^(BOOL finished){
                             if ( finished ) {
                                 [self setLabelMoved:NO];
                             }
                             
                         }];
    }
}

- (void)scrollLeftWithInterval:(NSTimeInterval)interval 
{
    [self setLabelMoved:YES];
    [UIView animateWithDuration:interval
                          delay:[self animationBorderDelay] 
                        options:( UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction )
                     animations:^{
                         [[self labelChild] setFrame:[self extraLabelFrame]];
                         
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self scrollRightWithInterval:interval];
                         }
                     }];
}

- (void)scrollRightWithInterval:(NSTimeInterval)interval 
{
    [UIView animateWithDuration:interval
                          delay:[self animationBorderDelay]
                        options:( UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction )
                     animations:^{
                         [[self labelChild] setFrame:[self labelFrame]];
                         
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             [self setLabelMoved:NO];
                             [self scrollLeftWithInterval:interval];
                         }
                     }];
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
        
        CGSize maximumLabelSize = CGSizeMake(9999, self.frame.size.height);
        CGSize expectedLabelSize = [_text sizeWithFont:[[self labelChild] font]
                                              constrainedToSize:maximumLabelSize
                                                  lineBreakMode:[[self labelChild] lineBreakMode]];
        
        [self setLabelFrame:CGRectMake( 0, 0, expectedLabelSize.width, [self bounds].size.height )];
        [self setExtraLabelFrame:CGRectOffset( [self labelFrame], -expectedLabelSize.width + self.bounds.size.width, 0.0)];

        [self setAnimationDuration:( (NSTimeInterval) fabs([self extraLabelFrame].origin.x) / [self animationRate] )];
        
        [UIView animateWithDuration:0.1
                              delay:0.0 
                            options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             [[self labelChild] setAlpha:0.0];
                             
                         }
                         completion:^(BOOL finished){
                             [self returnLabelToOriginImmediately];
                             [[self labelChild] setFrame:[self labelFrame]];
                             [[self labelChild] setText:_text];
                             
                             [UIView animateWithDuration:0.1
                                                   delay:0.0
                                                 options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState)
                                              animations:^{
                                                  [[self labelChild] setAlpha:1.0];
                                                  
                                              }
                                              completion:^(BOOL finished) {
                                                  if ( [self labelShouldScroll] ) {
                                                      [self scrollLeftWithInterval:[self animationDuration]];
                                                  }
                                              }];
                         }];
    }
}

- (NSString *)text {
    return _text;
}

@end
