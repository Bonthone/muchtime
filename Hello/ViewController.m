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
    UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [_cornerView addGestureRecognizer:panGestureRecognizer];
    //[panGestureRecognizer release];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rotateDoge:(CGFloat)radians {
    dogeView.transform = CGAffineTransformRotate(dogeView.transform, radians);
}


- (void)handlePanFrom:(UIPanGestureRecognizer*)recognizer {

    CGPoint translation = [recognizer translationInView:recognizer.view];
    CGPoint velocity = [recognizer velocityInView:recognizer.view];

    if (recognizer.state == UIGestureRecognizerStateBegan) {
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self rotateDoge:M_PI_4];

    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:2.0 delay:0
            options:UIViewAnimationOptionCurveEaseOut
            animations:^ {
                _cornerView.transform = CGAffineTransformTranslate(_cornerView.transform, translation.x, translation.y);
            }
            completion:NULL];
    }
}
@end
