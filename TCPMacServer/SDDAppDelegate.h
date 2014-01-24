//
//  SDDAppDelegate.h
//  TCPMacServer
//
//  Created by Divyendu Singh on 24/01/14.
//  Copyright (c) 2014 Divyendu Deepak Singh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern void SDDLog(NSString *format, ...);

@interface SDDAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@end
