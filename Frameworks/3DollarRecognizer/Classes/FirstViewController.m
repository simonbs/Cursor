//
//  FirstViewController.m
//  3DollerRecognizer
//
//  Created by Ivo Brodien on 22.01.10.
//  Copyright Steuernummer 46 773 108 525 2010. All rights reserved.
//

#import "FirstViewController.h"
#import "_DollerRecognizerAppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation FirstViewController

@synthesize gestureRecognizer;
@synthesize gestureDB;
@synthesize gestureRecorder;
@synthesize recordButton;
@synthesize infoLabel;
@synthesize activityIndicator;
@synthesize appDelegate;
@synthesize lastRecognizedGesture; 
/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	gestureDB = [GestureDB sharedInstance];
	self.appDelegate = (_DollerRecognizerAppDelegate*) [[UIApplication sharedApplication] delegate];
	NSLog(@"viewDidLoad: appDelegate %@",appDelegate);
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	UIAlertView *alert;
	alert = [[[UIAlertView alloc] initWithTitle:@"Memory low!" message:@"App might quit!" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil] autorelease];
		// optional - add more buttons:
		[alert addButtonWithTitle:@"Ok"];
	[alert show];
		
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	
	
}
- (void)inThreadStartDoJob:(id)theJobToDo
{
    NSAutoreleasePool * pool;
	
    pool = [[NSAutoreleasePool alloc] init];
    assert(pool != nil);
	
    //status = [... do long running job specified by theJobToDo ...]
	
	if (gestureDB != nil) {
		
		self.gestureRecognizer = appDelegate.recognizer;
		NSLog(@"inThreadStartDoJob: gestureRecognizer %@",self.gestureRecognizer);
		
		// Next three lines can be turned on for Debugging score should be 1.0
		//Matrix * normalized = [gestureRecognizer prepareMatrixForLibrary:gestureRecorder.gesture.gestureTrace]; 
		//gestureRecorder.gesture.gestureTrace = normalized;
		//[gestureDB addGesture: gestureRecorder.gesture];
		
		
		lastRecognizedGesture = [self.gestureRecognizer recognizeGesture:gestureRecorder.gesture fromGestures:gestureDB.gestureDict]; 
		
		
				
		NSLog(@"gestureRecognizer %@",self.gestureRecognizer);
		NSLog(@"recognizeGesture returned with GUESS %@",lastRecognizedGesture );
		//[gestureDB addGesture: gestureRecorder.gesture];
		//NSLog(@"%@ Recorded Gesture length: %d",[self class],gestureRecorder.gesture.gestureTrace.rows);
		
		//NSLog(@"%@ Gesture count in DB: %d",[self class],[gestureDB.gestures count]);
		
	}
	else {
		NSLog(@"ERROR gestureDB = nil");
	}
	
	[NSThread sleepForTimeInterval:0.01];
    [self performSelectorOnMainThread:
	 @selector(didStopJobWithStatus:)
						   withObject:nil
						waitUntilDone:NO
	 ];
	
    [pool release];
}

- (void) didStopJobWithStatus: (id) status {
	
	
	UIImage *aIconImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@64",lastRecognizedGesture] ofType:@"png"]];
	
	if (aIconImage == nil) {
		aIconImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"unknown64"ofType:@"png"]];
	}
	
	
	isRecordingTraining = NO;
	[activityIndicator stopAnimating];
	recordButton.enabled = YES;
	[recordButton setTitle:@"Press & do Gesture" forState:UIControlStateNormal];
	
	if (forcedStop) {
		forcedStop = NO;
		infoLabel.text = @"Recognition dismissed!";
	}else {
		if (lastRecognizedGesture == nil) {
			infoLabel.text = @"Gesture not recognized!";
		}
		else {
			infoLabel.text = [NSString stringWithFormat:@"IMHO Gesture is: %@",lastRecognizedGesture];
			// was here to show picture of recognized image....
			//UIImageView * imgView = [[UIImageView alloc] initWithImage:aIconImage];
		}

		
	}
	
}
- (IBAction)touchDown:(id) button {
	
	
	NSLog(@"touchDown");
	if (isRecordingTraining) return;
	isRecordingTraining = YES;
	
	
	[recordButton setTitle:@"Recording gesture.." forState:UIControlStateNormal];
	infoLabel.text = @"start making gesture";
	self.gestureRecorder = [[GestureRecorder alloc] initWithNameForGesture:@"TEST" andDelegate: self];
	[gestureRecorder startRecording];
	
	NSLog(@"touchDown-End");
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // do stuff
    }
}

- (IBAction)touchUpInside:(id) button {
	
	if (forcedStop) {
		[self didStopJobWithStatus:nil];
		return;
	}
	
	NSLog(@"touchUpInside");
	[gestureRecorder stopRecording];
	isRecordingTraining = NO;
	infoLabel.text = @"Processing Gesture";
	[activityIndicator startAnimating];
	
	
	recordButton.enabled = NO;
	[recordButton setTitle:@"Please wait..." forState:UIControlStateNormal];
	
	[self performSelectorInBackground:
	 @selector(inThreadStartDoJob:)
						   withObject:nil
	 ];
	
	// save Gesture into DB
	//@TODO
	
	NSLog(@"touchUpInside-End");
	
}

- (void)recorderForcedStop: (id) sender{
	if (forcedStop) {
		return;
	}
	
	
	
	[gestureRecorder stopRecording];
	
	NSString *path = [NSString stringWithFormat:@"%@%@",
					  [[NSBundle mainBundle] resourcePath],
					  @"/ready.wav"];
	
	//declare a system sound id
	SystemSoundID soundID;
	
	//Get a URL for the sound file
	NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
	
	//Use audio sevices to create the sound
	AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
	
	//Use audio services to play the sound
	AudioServicesPlaySystemSound(soundID);
	
	forcedStop = YES;
	NSLog(@"FORCING STOP");
	
	if (sender == self.gestureRecorder) {
		infoLabel.text = @"Timeout - Recognition dismissed!";
	}else {
		infoLabel.text = @"Recognition dismissed!";
	}
	
	self.recordButton.titleLabel.textColor = [UIColor redColor];
	[self.recordButton setTitle:@"press once" forState:UIControlStateNormal];
}


- (void)dealloc {
    [super dealloc];
}

@end
