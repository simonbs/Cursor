//
//  _DollerRecognizerAppDelegate.m
//  3DollerRecognizer
//
//  Created by Ivo Brodien on 22.01.10.
//  Copyright Steuernummer 46 773 108 525 2010. All rights reserved.
//

#import "_DollerRecognizerAppDelegate.h"
#import "ThreeDollarGestureRecognizer.h"
#define RESAMPLE_AMOUNT 50

@implementation _DollerRecognizerAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize gestureDB;
@synthesize librayTableView;
@synthesize recognizer;
- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    // Add the tab bar controller's current view as a subview of the window
//    [window addSubview:tabBarController.view];
    window.rootViewController = tabBarController;
    [window makeKeyAndVisible];
    
	self.gestureDB = [GestureDB sharedInstance];
	
	self.recognizer = [[ThreeDollarGestureRecognizer alloc] initWithResampleAmount: RESAMPLE_AMOUNT];
	
	UITabBar* tapBar = [tabBarController tabBar];
	UITabBarItem* tapBarItemTraining = [[tapBar items] objectAtIndex:1];
	tapBarItemTraining.title = @"Training";
	tapBarItemTraining.badgeValue = nil;//@"";
}



// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	//NSLog(@"%@",viewController.nibName);
	if([viewController.title isEqualToString:@"Library"])
		[librayTableView reloadData];
	
	
	

}


/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

