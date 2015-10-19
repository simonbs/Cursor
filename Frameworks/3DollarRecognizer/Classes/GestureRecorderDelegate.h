//
//  GestureRecorderDelegate.h
//  3DollerRecognizer
//
//  Created by Ivo Brodien on 26.01.10.
//  Copyright 2010 Steuernummer 46 773 108 525. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol GestureRecorderDelegate <NSObject>

@required
- (void)recorderForcedStop: (id) sender;

@end
