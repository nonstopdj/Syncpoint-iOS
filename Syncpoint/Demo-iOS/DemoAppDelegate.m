//
//  DemoAppDelegate.m
//  iOS Demo
//
//  Created by Jens Alfke on 12/9/11.
//  Copyright (c) 2011 Couchbase, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.

#import "DemoAppDelegate.h"
#import "RootViewController.h"
#import <Syncpoint/Syncpoint.h>


#define kServerURLString @"http://localhost:5984/"

#define kSyncpointAppId @"demo-app"


@implementation DemoAppDelegate


@synthesize window, navigationController, database, syncpoint;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Add the navigation controller's view to the window and display.
    NSAssert(navigationController, @"navigationController outlet not wired up");
	[window addSubview:navigationController.view];
	[window makeKeyAndVisible];
    
    //gRESTLogLevel = kRESTLogRequestHeaders;
    //gCouchLogLevel = 1;
    
    NSLog(@"Creating database...");
    CouchTouchDBServer* server = [CouchTouchDBServer sharedInstance];
    NSAssert(!server.error, @"Error initializing TouchDB: %@", server.error);
    
    // Create the database on the first run of the app.
    self.database = [server databaseNamed: @"grocery-sync"];
    NSError* error;
    if (![self.database ensureCreated: &error]) {
        [self showAlert: @"Couldn't create local database." error: error fatal: YES];
        return YES;
    }
    database.tracksChanges = YES;
    NSLog(@"...Created CouchDatabase at <%@>", self.database.URL);
    
    // Tell the RootViewController:
    RootViewController* root = (RootViewController*)navigationController.topViewController;
    [root useDatabase: database];

    // Start up Syncpoint client:
    NSURL* remote = [NSURL URLWithString: kServerURLString];

    self.syncpoint = [[SyncpointClient alloc] initWithLocalServer: server
                                               remoteServer: remote
                                                      appId: kSyncpointAppId
                                                      error: &error];
    if (!syncpoint) {
        NSLog(@"Syncpoint failed to start: %@", error);
        exit(1);
    }
    
    if (![syncpoint.session installChannelNamed: @"grocery-sync"
                                     toDatabase: self.database
                                          error: &error]
            && error != nil) {
        [self showAlert: @"Couldn't subscribe to channel" error: error fatal: NO];
    }

//    if (syncpoint.state == kSyncpointUnauthenticated) {
////        we aren't authed yet, try to auth (maybe our sesison was activated since we last quit)
//        
//    }

    return YES;
}


// Display an error alert, without blocking.
// If 'fatal' is true, the app will quit when it's pressed.
- (void)showAlert: (NSString*)message error: (NSError*)error fatal: (BOOL)fatal {
    if (error) {
        message = [NSString stringWithFormat: @"%@\n\n%@", message, error.localizedDescription];
    }
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: (fatal ? @"Fatal Error" : @"Error")
                                                    message: message
                                                   delegate: (fatal ? self : nil)
                                          cancelButtonTitle: (fatal ? @"Quit" : @"Sorry")
                                          otherButtonTitles: nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    exit(0);
}


@end
