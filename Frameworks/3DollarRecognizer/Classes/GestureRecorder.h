//
//  GestureRecorder.h
//  3DollerRecognizer
//
//  Created by Ivo Brodien on 25.01.10.
//  Copyright 2010 Steuernummer 46 773 108 525. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Gesture.h"
#import "GestureRecorderDelegate.h"

@interface GestureRecorder : NSObject <UIAccelerometerDelegate>{
	id <GestureRecorderDelegate> __unsafe_unretained delegate;
	bool isRecording;
	Gesture * gesture;
	NSString * desiredName;
	int samples;
	int maxSamples;
	UIAccelerometer * theAccelerometer;
	UIAccelerationValue accelX,accelY,accelZ;
}
@property (nonatomic) bool isRecording;
@property (nonatomic,retain) Gesture * gesture;
@property (assign) id<GestureRecorderDelegate> delegate;

-(id) initWithNameForGesture:(NSString*) gestureName andDelegate: (id) aDelegate;

-(void) startRecording;
-(void) stopRecording;
-(void) configureAccelerometer;

@end
