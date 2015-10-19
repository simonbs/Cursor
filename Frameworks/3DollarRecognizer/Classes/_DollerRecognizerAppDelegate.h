//
//  _DollerRecognizerAppDelegate.h
//  3DollerRecognizer
//
//  Created by Ivo Brodien on 22.01.10.
//  Copyright Steuernummer 46 773 108 525 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GestureDB.h"
#import "GestureRecognizerDelegate.h"

@interface _DollerRecognizerAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	GestureDB * gestureDB;
	UITableView * librayTableView;
	NSObject<GestureRecognizerDelegate> * recognizer;
}

@property (nonatomic, retain) IBOutlet UITableView * librayTableView;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) GestureDB * gestureDB;
@property (nonatomic, retain) NSObject<GestureRecognizerDelegate> * recognizer;

@end
