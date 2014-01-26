//
//  CornerView.m
//  Hello
//
//  Created by Emil Sågfors on 1/26/14.
//  Copyright (c) 2014 Emil Sågfors. All rights reserved.
//

#import "CornerView.h"

@implementation CornerView

@synthesize color, direction, startPosition;

- (void)awakeFromNib {
	// Initialization code
	self.backgroundColor = color;
}

@end
