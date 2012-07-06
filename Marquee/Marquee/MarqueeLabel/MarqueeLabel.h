//
//  MarqueeLabel.h
//  Marquee
//
//  Created by Pavel Gnatyuk on 7/6/12.
//  Copyright (c) 2012 Software Developer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MarqueeLabel : UIView

@property (nonatomic, copy)     NSString    *text;
@property (nonatomic, retain)   UIFont      *font;
@property (nonatomic, assign)   CGFloat     animationRate;      // pixels per second

@end
