//
//  ViewController.m
//  Hello
//
//  Created by Emil Sågfors on 1/7/14.
//  Copyright (c) 2014 Emil Sågfors. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize dogeView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)swipeAction:(id)sender {
    dogeView.transform = CGAffineTransformRotate(dogeView.transform, M_PI_2);
}
@end
