//
//  MarqueeLabel.h
//  Marquee
//
//  Created by Pavel Gnatyuk on 7/6/12.
//  Copyright (c) 2012 Software Developer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MarqueeLabel : UIView

@property (copy)    NSString *text;
@property (assign)  CGFloat  animationRate;      // pixels per second

@end
