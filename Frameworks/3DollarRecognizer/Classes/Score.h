//
//  Score.h
//  3DollerRecognizer
//
//  Created by Ivo Brodien on 04.02.10.
//  Copyright 2010 Steuernummer 46 773 108 525. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Score : NSObject {
	NSString * gid;
	int idnr;
	float distance;
	float score;
}


@property (nonatomic, retain) NSString * gid;
@property (nonatomic, assign) int idnr;
@property (nonatomic, assign) float distance;
@property (nonatomic, assign) float score;

- (NSComparisonResult) compare: (Score*) otherScore;
@end
