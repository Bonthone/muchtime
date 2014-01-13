//
//  ViewController.h
//  Hello
//
//  Created by Emil Sågfors on 1/7/14.
//  Copyright (c) 2014 Emil Sågfors. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (void)handlePanFrom:(UIPanGestureRecognizer*)recognizer;

@property (strong, nonatomic) IBOutlet UIView *bgView;
@property (strong, nonatomic) IBOutlet UIImageView *dogeView;
@property (strong, nonatomic) IBOutlet UIView *cornerView;


@end
