//
//  ViewController.m
//  Marquee
//
//  Created by Pavel Gnatyuk on 7/6/12.
//  Copyright (c) 2012 Software Developer. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (retain, nonatomic) IBOutlet UITextField *textFieldUpdate;

- (IBAction)clickUpdate:(id)sender;
- (IBAction)clickChangeFont:(id)sender;
- (IBAction)clickChangeColor:(id)sender;

@end

@implementation ViewController
@synthesize textFieldUpdate;
@synthesize labelText;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self labelText] setText:@"Hello, World! This is a test of a long text scrolling left and right"];
}

- (void)viewDidUnload
{
    [self setTextFieldUpdate:nil];
    [super viewDidUnload];
    [self setLabelText:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc {
    [labelText release];
    [textFieldUpdate release];
    [super dealloc];
}

- (IBAction)clickUpdate:(id)sender {
    [[self labelText] setText:[[self textFieldUpdate] text]];
}

- (IBAction)clickChangeFont:(id)sender {
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0];
    [[self labelText] setFont:font];
}

- (IBAction)clickChangeColor:(id)sender {
    [(UILabel *)[self labelText] setTextColor:[UIColor redColor]];
}

@end
