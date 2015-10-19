//
//  Gesture.h
//  3DollerRecognizer
//
//  Created by Ivo Brodien on 25.01.10.
//  Copyright 2010 Steuernummer 46 773 108 525. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Matrix.h"


@interface Gesture : NSObject {
	
	Matrix * gestureTrace;
	
	//UIAcceleration ** gestureTraceUI;
	NSString * gestureID;
	NSDate * gestureAdded;
	int databaseID;

}
@property (nonatomic,retain) Matrix * gestureTrace;


@property (nonatomic,retain) NSDate * gestureAdded;
@property (nonatomic,retain) NSString * gestureID;
@property (nonatomic) int databaseID;

- (id) initWithName: (NSString*) aName andCapacity: (uint) maxSamples;
- (id) initWithName: (NSString*) aName databaseID: (uint) aDatabaseID creationDate: (NSDate*) date andTrace:(Matrix *) trace;
- (void) printGestureWithTrace:(bool) withTrace;

@end
