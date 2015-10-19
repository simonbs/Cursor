//
//  GestureDB.h
//  3DollerRecognizer
//
//  Created by Ivo Brodien on 26.01.10.
//  Copyright 2010 Steuernummer 46 773 108 525. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Gesture.h"
#import "Matrix.h"
#import <sqlite3.h>

@interface GestureDB : NSObject {
	NSString * filename;
	NSMutableArray * gestures;
	NSMutableDictionary * gestureDict;
	NSString *path;
}

@property (readonly) NSString * filename;
@property (retain) NSMutableArray * gestures;
@property (retain) NSMutableDictionary * gestureDict;

-(void) saveToFile;
-(bool) addGesture: (Gesture*) aGesture;
-(bool) addGesturetoDB:(Gesture*) gesture;
-(bool) addGestureToArray: (Gesture*) aGesture;
-(void) printAllGestures;
-(void) checkAndCreateDatabase;
-(void) readGesturesFromDatabase;
+(id)sharedInstance;
- (Matrix*) getMatrixFromData: (NSData*) data;
- (NSData*) getDataFromMatrix: (Matrix*) matrix;
- (void) deleteGesture:(int) databaseID;
- (void) deleteGesturesWithNames:(NSString*) _name;
+ (void) finalizeStatements;
@end
