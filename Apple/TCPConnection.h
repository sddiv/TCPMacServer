#import <Foundation/Foundation.h>
#import <sys/socket.h>

@class TCPConnection;

@protocol TCPConnectionDelegate <NSObject>
@optional
- (void) connectionDidFailOpening:(TCPConnection*)connection;
- (void) connectionDidOpen:(TCPConnection*)connection;
- (void) connectionDidClose:(TCPConnection*)connection;

- (void) connection:(TCPConnection*)connection didReceiveData:(NSData*)data;
@end

@interface TCPConnection : NSObject
{
@private
	CFReadStreamRef				_inputStream;
	CFWriteStreamRef			_outputStream;
	NSRunLoop*					_runLoop;
	NSUInteger					_delegateMethods;
	NSUInteger					_opened;
	struct sockaddr*			_localAddress;
	struct sockaddr*			_remoteAddress;
	BOOL						_invalidating;
}
- (id) initWithSocketHandle:(int)socket; //Acquires ownership of the socket
- (id) initWithRemoteAddress:(const struct sockaddr*)address;

@property(nonatomic, assign) id<TCPConnectionDelegate> delegate;

@property(nonatomic, readonly, getter=isValid) BOOL valid;
- (void) invalidate; //Close the connection

@property(readonly) UInt16 localPort;
@property(readonly) UInt32 localIPv4Address;
@property(readonly) UInt16 remotePort;
@property(readonly) UInt32 remoteIPv4Address;

@property(readonly) const struct sockaddr* remoteSocketAddress;

- (BOOL) sendData:(NSData*)data; //Blocking - Must be called from same thread the connection was created on
- (BOOL) hasDataAvailable; //Non-blocking - Must be called from same thread the connection was created on
- (NSData*) receiveData; //Blocking - Must be called from same thread the connection was created on

+ (NSString*) bonjourTypeFromIdentifier:(NSString*)identifier;
@end
