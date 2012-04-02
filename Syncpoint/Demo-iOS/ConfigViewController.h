//
//  ConfigViewController.h
//  CouchDemo
//
//  Created by Jens Alfke on 8/8/11.
//  Copyright 2011 Couchbase, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CouchServer;

@interface ConfigViewController : UIViewController

@property (weak, nonatomic, readonly) IBOutlet UILabel* sessionInfo;
@property (weak, nonatomic, readonly) IBOutlet UILabel* sessionLabel;
- (IBAction)done:(id)sender;

@end
