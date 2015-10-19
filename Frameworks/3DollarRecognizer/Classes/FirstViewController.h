//
//  FirstViewController.h
//  3DollerRecognizer
//
//  Created by Ivo Brodien on 22.01.10.
//  Copyright Steuernummer 46 773 108 525 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GestureRecognizerDelegate.h"
#import "GestureDB.h"
#import "GestureRecorder.h"
#import "_DollerRecognizerAppDelegate.h"

@interface FirstViewController : UIViewController<GestureRecorderDelegate> {

	GestureDB * gestureDB;
	NSObject<GestureRecognizerDelegate>  * gestureRecognizer;
	GestureRecorder * gestureRecorder;
	
	_DollerRecognizerAppDelegate * appDelegate;
	
	bool isRecordingTraining;
	bool isProcessingGesture;
	
	UIButton * recordButton;
	UIActivityIndicatorView * activityIndicator;
	UILabel * infoLabel;
	bool forcedStop;
	
	NSString * lastRecognizedGesture;

}

@property (nonatomic, retain) NSObject<GestureRecognizerDelegate> * gestureRecognizer;
@property (nonatomic, retain) GestureRecorder * gestureRecorder;
@property (nonatomic, retain) GestureDB * gestureDB;
@property (nonatomic, retain) IBOutlet UIButton * recordButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * activityIndicator;
@property (nonatomic, retain) IBOutlet UILabel * infoLabel;
@property (nonatomic, retain) _DollerRecognizerAppDelegate * appDelegate;
@property (nonatomic, retain)  NSString * lastRecognizedGesture;

- (IBAction)touchUpInside:(id) button;
- (IBAction)touchDown:(id) button;

// @protocol GestureRecorderDelegate
- (void)recorderForcedStop: (id) sender;

@end
