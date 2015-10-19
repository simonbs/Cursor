//
//  GestureLibraryTableViewController.h
//  3DollerRecognizer
//
//  Created by Ivo Brodien on 22.01.10.
//  Copyright 2010 Steuernummer 46 773 108 525. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GestureDB.h"

@interface GestureLibraryTableViewController : UITableViewController <UITableViewDelegate,UITableViewDataSource>{

	//UITableViewController *tableViewController;
	GestureDB * gestureDB;
	
	
}

-(void) reloadData:(NSObject*) obj;

//@property (nonatomic, retain) IBOutlet UITableViewController *tableViewController;

@end
