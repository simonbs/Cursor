//
//  ThreeDollarGestureRecognizer.h
//  3DollerRecognizer
//
//  Created by Ivo Brodien on 30.01.10.
//  Copyright 2010 Steuernummer 46 773 108 525. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GestureRecognizerDelegate.h"
#import "Score.h"
@interface ThreeDollarGestureRecognizer : NSObject <GestureRecognizerDelegate> {
	int resampleAmount;
	Matrix *  gesture_path;
	Matrix *  resampled_gesture;
	Matrix *  rotated_gesture;
	
}

@property (nonatomic) int resampleAmount;

- (id) initWithResampleAmount:(int) _resampleAmount;
-(Matrix*)prepareMatrixForLibrary: (Matrix*) theTrace;
- (NSString*) recognizeGesture: (Gesture*) candidate fromGestures: (NSDictionary *) library_gestures;
- (NSString*)  recognize_from_scoretable:(NSArray*)scoreTable;
-(void) reset;

// for internal calculations
- (Matrix*)createPathFromMatrix: (Matrix*) gList;
- (float) calculate_path_length: (Matrix*) gList;
- (float *) unit_vector: (float*) v;
- (Matrix *) bounding_box3: (Matrix *) points;
- (float) dot_product3:  (float *) u andV:(float *) v;
- (float) norm: (float *) u;
- (float) norm_dot_product: (float *) u andV:(float *) v;
- (float) angle3: (float *) u andV:(float *) v;
- (float*) orthogonal: (float*) b and: (float*) c;
- (Matrix*)scale_to_cube: (Matrix*) gList;
- (Matrix*)centroidFromTrace: (Matrix*) gList;
- (Matrix*) rotationMatrixWithVector3: (float *) axis andTheta:(float) theta;
- (Matrix*) rotate3: (float *) p withMatrix:(Matrix*) matrix;
- (Matrix*)rotate_to_zero: (Matrix*) gList;
- (Matrix*)resamplePoints: (Matrix*) gList withAmount: (int) numSamples;
-(float) score: (float) distance;

-(Matrix*) search_around_angle_candidateTrace: (Matrix* ) candidate libraryTrace: (Matrix* ) template Angle:(float) angle bestAngle: (float*) best_angles;
-(float) distance_at_angles_candidateTrace: (Matrix* ) candidate libraryTrace: (Matrix* ) template andAngles: (float*) angles;
-(float) path_distance_candidateTrace: (Matrix* ) path1 libraryTrace: (Matrix* ) path2;
-(float) distance_at_best_angle_rangeX:(float) angularRangeX Y: (float) angularRangeY Z:(float)angularRangeZ increment: (float) increment
						candidateTrace: (Matrix* ) candidate_points libraryTrace: (Matrix* ) library_points andCutOffAngle: (float) cutoff_angle;
@end
