//
//  ThreeDollerRecognizer.h
//  3DollerRecognizer
//
//  Created by Ivo Brodien on 30.01.10.
//  Copyright 2010 Steuernummer 46 773 108 525. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Matrix.h"
#import "Gesture.h"

@protocol GestureRecognizerDelegate

@required
- (Matrix*)prepareMatrixForLibrary: (Matrix*) theTrace;
- (NSString*) recognizeGesture: (Gesture*) candidate fromGestures: (NSDictionary *) library_gestures;
@end
