//
//  SDDAppDelegate.m
//  TCPMacServer
//
//  Created by Divyendu Singh on 24/01/14.
//  Copyright (c) 2014 Divyendu Deepak Singh. All rights reserved.
//

#import "SDDAppDelegate.h"
#import "TCPServer.h"

@interface SDDAppDelegate () <TCPServerDelegate>

@property (nonatomic, strong) TCPServer *tcpServer;

@property (nonatomic, strong) IBOutlet NSTextField *portTextField;

@property (nonatomic, strong) IBOutlet NSTextView *serverLogger;

-(IBAction)startServerPressed:(NSButton*)startButton;

-(IBAction)stopServerPressed:(NSButton*)stopButton;

@end

@implementation SDDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void) serverDidStart:(TCPServer*)server
{
    [self log:@"Server started"];
    [self log:@"%@", [server description]];
}

- (void) serverDidEnableBonjour:(TCPServer*)server withName:(NSString*)name;
{
    [self log:@"Server did enable bonjour: %@", name];
}

- (void) server:(TCPServer*)server didNotEnableBonjour:(NSDictionary *)errorDict
{
    [self log:@"Server did not enable bonjour: %@", errorDict];
}

- (BOOL) server:(TCPServer*)server shouldAcceptConnectionFromAddress:(const struct sockaddr*)address
{
    [self log:@"Will accept connection from address: %s %ui", address->sa_data, address->sa_family];
    return YES;
}

- (void) server:(TCPServer*)server didOpenConnection:(TCPServerConnection*)connection
{
    [self log:@"Did open connection: %@", connection];
}

- (void) server:(TCPServer*)server didCloseConnection:(TCPServerConnection*)connection
{
    [self log:@"Did close connection: %@", connection];
}

- (void) serverWillDisableBonjour:(TCPServer*)server
{
    [self log:@"Server will disable bonjour"];
}

- (void) serverWillStop:(TCPServer*)server
{
    [self log:@"Server at port %hu will STOP!!!", server.localPort];
}

#pragma mark - Logging
-(NSString*)commonString
{
    // date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    return [NSString stringWithFormat:@"[%@ %@] ", dateString, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
}

-(void)log:(NSString*)format, ... NS_FORMAT_FUNCTION(1, 2)
{
    // convert to NSString
    va_list args;
    va_start(args, format);
    NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    // set to textview
    [self.serverLogger setString:[NSString stringWithFormat:@"%@%@ %@\n", self.serverLogger.string, [self commonString], string]];
}

#pragma mark -
-(void)startServerPressed:(NSButton*)startButton
{
    if(![self.tcpServer isRunning])
    {
        UInt16 port = self.portTextField.stringValue.length?[self.portTextField.stringValue integerValue]:8000;
        self.tcpServer = [[TCPServer alloc] initWithPort:port];
        self.tcpServer.delegate = self;
        [self.tcpServer startUsingRunLoop:[NSRunLoop currentRunLoop]];
    }
}

-(void)stopServerPressed:(NSButton*)stopButton
{
    if([self.tcpServer isRunning])
    {
        [self.tcpServer stop];
        self.tcpServer = nil;
    }
}

@end
