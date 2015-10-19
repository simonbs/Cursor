//
//  Matrix.m
//  3DollerRecognizer
//
//  Created by Ivo Brodien on 25.01.10.
//  Copyright 2010 Steuernummer 46 773 108 525. All rights reserved.
//

#import "Matrix.h"

static int MATRIX_COUNT = 0;
@implementation Matrix

@synthesize rows;
@synthesize cols;
@synthesize data;


- (void) printVector: (float*) vec withSize: (uint) size{
	NSMutableString *out = [[NSMutableString alloc] initWithString: @""];
	for (int i = 0; i < size; i++) {
		[out appendFormat: @"\t %f",vec[i]];
	}
	NSLog(@"%@",out);
}
- (void) printMatrix {
	
	for (int i = 0; i < self.rows; i++) {
		[self printVector:self.data[i] withSize: self.cols];
	}
}
- (void) emptyMatrix{
	
	for (int j = 0; j < self.rows; j++)
	{ 
		bzero(self.data[j],sizeof(float[self.cols]));
	}
}

- (id) initMatrixWithRows:(uint) _rows andCols:(uint) _cols
{
	self = [super init];
	if (self != nil) {
		MATRIX_COUNT++;
		if (MATRIX_COUNT % 10000 == 0) {
			NSLog(@"MATRIX created COUNT: %d",MATRIX_COUNT);
		}		self.rows = _rows;
		self.cols = _cols;
		self.data = (float **) malloc(sizeof(float*)*self.rows);
		for (int i=0; i<self.rows; i++)
			self.data[i] = (float *) malloc(sizeof(float)*self.cols);
		[self emptyMatrix];
	}
	return self;
}
+ (id) zeroVec3
{
	Matrix *zero  = [[Matrix alloc]initMatrixWithRows:(uint) 1 andCols:(uint) 3]; 
	return zero;
}

- (void) copy: (float*) source Into: (float*) target andSize:(uint) size{
	
	for (int i = 0; i < size; i++) {
		target[i] = source[i];
	}
}

- (void) dealloc
{
	for (int i=0; i<self.rows; i++)
		free(self.data[i]);
	free(self.data);
	[super dealloc];
	
	MATRIX_COUNT--;
	if (MATRIX_COUNT % 10000 == 0) {
		NSLog(@"MATRIX deleted COUNT: %d",MATRIX_COUNT);
	}
	
	
}


@end
