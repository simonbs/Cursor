//
//  Score.m
//  3DollerRecognizer
//
//  Created by Ivo Brodien on 04.02.10.
//  Copyright 2010 Steuernummer 46 773 108 525. All rights reserved.
//

#import "Score.h"


@implementation Score
@synthesize gid;
@synthesize idnr;
@synthesize distance;
@synthesize score;


- (id) init
{
	self = [super init];
	if (self != nil) {
		self.gid = nil;
		self.idnr = 0;
		self.distance = MAXFLOAT;
		self.score = 0.0f;
	}
	return self;
}

- (NSComparisonResult) compare: (Score*) otherScore{
	if (self.score > otherScore.score)
		return NSOrderedAscending;
	else if (self.score < otherScore.score)
		return NSOrderedDescending;
	else 
		return NSOrderedSame;
	
}


@end
