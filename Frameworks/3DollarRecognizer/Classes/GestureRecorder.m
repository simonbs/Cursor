//
//  GestureRecorder.m
//  3DollerRecognizer
//
//  Created by Ivo Brodien on 25.01.10.
//  Copyright 2010 Steuernummer 46 773 108 525. All rights reserved.
//

#import "GestureRecorder.h"
//#import "AccelerometerSimulation.h"
#import <AudioToolbox/AudioToolbox.h>

#define ACCELEROMETER_FREQUENCY 100 //Hz
#define GESTURE_MAX_SECONDS 4 // Seconds
#define FILTER_ENABLED FALSE
#define FILTERING_FACTOR 0.95

@implementation GestureRecorder
@synthesize isRecording;
@synthesize gesture;
@synthesize delegate;

- (id) initWithNameForGesture:(NSString*) gestureName andDelegate: (id) aDelegate
{
	self = [super init];
	if (self != nil) {
		self.delegate = aDelegate;
		NSLog(@"init GestureRecorder");
		accelX = 0;
		accelY = 0;
		accelZ = 0;
		samples = 0;
		maxSamples = ACCELEROMETER_FREQUENCY * GESTURE_MAX_SECONDS;
		gesture = [[Gesture alloc] init];
		desiredName = gestureName;
		[self configureAccelerometer];
	}
	return self;
}


-(void)configureAccelerometer 
{ 
	
	theAccelerometer = [UIAccelerometer sharedAccelerometer]; 
	theAccelerometer.updateInterval = 0.01f;// 1 / ACCELEROMETER_FREQUENCY;
	
	NSLog(@"Accelerometer initialized by %@ with %U Hz",[self class],ACCELEROMETER_FREQUENCY);
	
}

-(void) startRecording{
	
	accelX = 0;
	accelY = 0;
	accelZ = 0;
	samples = 0;
	maxSamples = ACCELEROMETER_FREQUENCY * GESTURE_MAX_SECONDS;
	gesture = [[Gesture alloc] initWithName: desiredName andCapacity:maxSamples];
	
	NSLog(@"startRecording %d",maxSamples);
	
	self.isRecording = YES;
	// starts immediatelly
	theAccelerometer.delegate = self;
	NSLog(@"Acc turned ON");
}
-(void) stopRecording{
	
	
	
	// stop immediatelly
	theAccelerometer.delegate = nil;
	self.isRecording = NO;
	gesture.gestureTrace.rows = samples;
	[gesture printGestureWithTrace:NO];
	
	NSLog(@"Acc turned OFF");
	
}

- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
	
	if(FILTER_ENABLED) {
		accelX = (acceleration.x * FILTERING_FACTOR) + (accelX * (1.0 - FILTERING_FACTOR));
		accelY = (acceleration.y * FILTERING_FACTOR) + (accelY * (1.0 - FILTERING_FACTOR));
		accelZ = (acceleration.z * FILTERING_FACTOR) + (accelZ * (1.0 - FILTERING_FACTOR));
	}
	else
	{
		accelX = acceleration.x;
		accelY = acceleration.y;
		accelZ = acceleration.z;
	}
	
	
	gesture.gestureTrace.data[samples][0] = accelX;
	gesture.gestureTrace.data[samples][1] = accelY;
	gesture.gestureTrace.data[samples][2] = accelZ;
	
	
	
	samples++;
	
	//NSLog(@"SAMPLE: %d",samples);
	
	if (samples == maxSamples) {
		self.isRecording = NO;
		theAccelerometer.delegate = nil;
		[delegate recorderForcedStop:self];
	}
}

@end
