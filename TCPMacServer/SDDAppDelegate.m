//
//  SDDAppDelegate.m
//  TCPMacServer
//
//  Created by Divyendu Singh on 24/01/14.
//  Copyright (c) 2014 Divyendu Deepak Singh. All rights reserved.
//

#import "SDDAppDelegate.h"
#import "TCPServer.h"

@interface SDDAppDelegate () <TCPServerDelegate, TCPConnectionDelegate>

@property (nonatomic, strong) TCPServer *tcpServer;

@property (nonatomic, strong) IBOutlet NSTextField *portTextField;

@property (nonatomic, strong) IBOutlet NSTextView *serverLogger;

-(IBAction)startServerPressed:(NSButton*)startButton;

-(IBAction)stopServerPressed:(NSButton*)stopButton;

-(void)log:(NSString*)format, ... NS_FORMAT_FUNCTION(1, 2);

@end

@implementation SDDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    [self stopServerPressed:nil];
    return NSTerminateNow;
}

#pragma mark - TCPServerDelegate
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
    [self log:@"Will ACCEPT NEW connection"];
    return YES;
}

- (void) server:(TCPServer*)server didOpenConnection:(TCPServerConnection*)connection
{
    connection.delegate = self;
    [self log:@"Did open connection: %@", connection];
}

- (void) server:(TCPServer*)server didCloseConnection:(TCPServerConnection*)connection
{
    connection.delegate = nil;
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
    
    return [NSString stringWithFormat:@"%@> ", dateString];
}

-(void)log:(NSString*)format, ... NS_FORMAT_FUNCTION(1, 2)
{
    // convert to NSString
    va_list args;
    va_start(args, format);
    NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    // set to textview
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.serverLogger setString:[NSString stringWithFormat:@"%@%@ %@\n", self.serverLogger.string, [self commonString], string]];
    }];
}

#pragma mark - TCPConnectionDelegate
- (void) connectionDidFailOpening:(TCPConnection*)connection
{
    [self log:@"connection did fail opening: %u:%hu", (unsigned int)connection.localIPv4Address, connection.localPort];
}

- (void) connectionDidOpen:(TCPConnection*)connection
{
    [self log:@"connection did open: %u:%hu", connection.localIPv4Address, connection.localPort];
}

- (void) connectionDidClose:(TCPConnection*)connection
{
    [self log:@"connection did close: %u:%hu", connection.localIPv4Address, connection.localPort];
}

- (void) connection:(TCPConnection*)connection didReceiveData:(NSData*)data
{
    [self log:@"Recieved %hu:%u data = %@", connection.localPort, (unsigned int)connection.localIPv4Address,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
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

void SDDLog(NSString *format, ...)
{
    // convert to NSString
    va_list args;
    va_start(args, format);
    NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    // set to textview
    SDDAppDelegate *appDelegate = (SDDAppDelegate*)[[NSApplication sharedApplication] delegate];
    if([appDelegate isKindOfClass:[SDDAppDelegate class]])
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [appDelegate.serverLogger setString:[NSString stringWithFormat:@"%@%@ %@\n", appDelegate.serverLogger.string, [appDelegate commonString], string]];
        }];
    }
}
