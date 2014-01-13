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

@synthesize bgView;
@synthesize dogeView;
@synthesize cornerView;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [cornerView addGestureRecognizer:panGestureRecognizer];
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

        [UIView animateWithDuration:0 delay:0
            options:UIViewAnimationOptionCurveLinear
            animations:^ {
                cornerView.transform = CGAffineTransformTranslate(cornerView.transform, translation.x, translation.y);
            }
            completion:NULL];

        [recognizer setTranslation:CGPointZero inView:recognizer.view];

    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.5 delay:0
            options:UIViewAnimationOptionCurveEaseOut
            animations:^ {
                cornerView.alpha = 0.5;
                // bgView.backgroundColor = cornerView.backgroundColor;
            }
            completion:NULL];
    }
}
@end
