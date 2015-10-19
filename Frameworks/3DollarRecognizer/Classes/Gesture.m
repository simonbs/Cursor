//
//  Gesture.m
//  3DollerRecognizer
//
//  Created by Ivo Brodien on 25.01.10.
//

#import "Gesture.h"


@implementation Gesture
@synthesize gestureAdded;
@synthesize gestureTrace;
@synthesize gestureID;
@synthesize databaseID;
- (id) initWithName: (NSString*) aName andCapacity: (uint) maxSamples
{
	self = [super init];
	if (self != nil) {
		
		gestureTrace = [[Matrix alloc] initMatrixWithRows:maxSamples andCols:3];
		[gestureTrace retain];

		self,gestureAdded = [NSDate date];
		self.gestureID = aName;
		self.databaseID = -1;
		NSLog(@"Gesture '%@' initialized", self.gestureID);
		NSLog(@"gestureTrace rows: %d,cols: %d", self.gestureTrace.rows,self.gestureTrace.cols);
	}	
	return self;
}
- (id) initWithName: (NSString*) aName databaseID: (uint) aDatabaseID creationDate: (NSDate*) date  andTrace:(Matrix *) trace;
{
	self = [super init];
	if (self != nil) {
		// read blob here
		gestureTrace = trace;
		[gestureTrace retain];
		
		self,gestureAdded = date;
		self.gestureID = aName;
		self.databaseID = -1;

	}	
	return self;
}

- (void) printGestureWithTrace:(bool) withTrace {
	NSLog(@"Name: %@\t databaseID:%d",self.gestureID,self.databaseID);
	if(withTrace)
		[self.gestureTrace printMatrix];
	NSLog(@"-----------------------");
}
- (void) dealloc
{
	//[gestureTrace release];
	[gestureAdded release];
	[super dealloc];
}




@end
