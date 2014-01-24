#import <SystemConfiguration/SCNetworkReachability.h>
#import <netinet/in.h>

#import "NetReachability.h"
#import "Networking_Internal.h"

#define IS_REACHABLE(__FLAGS__) (((__FLAGS__) & kSCNetworkReachabilityFlagsReachable) && !((__FLAGS__) & kSCNetworkReachabilityFlagsConnectionRequired))

@implementation NetReachability

static void _ReachabilityCallBack(SCNetworkReachabilityRef target, SCNetworkConnectionFlags flags, void* info)
{
    @autoreleasepool {
        NetReachability*		self = (__bridge NetReachability*)info;
        [self->_delegate reachabilityDidUpdate:self reachable:(IS_REACHABLE(flags) ? YES : NO)];
    }
}

- (id) _initWithNetworkReachability:(SCNetworkReachabilityRef)reachability
{
	if(reachability == NULL)
    {
		return nil;
	}
	
	if((self = [super init]))
    {
		_runLoop = [NSRunLoop currentRunLoop];
		_netReachability = (void*)reachability;
	}
	
	return self;
}

- (id) initWithDefaultRoute:(BOOL)ignoresAdHocWiFi
{
	return [self initWithIPv4Address:(htonl(ignoresAdHocWiFi ? INADDR_ANY : IN_LINKLOCALNETNUM))]; //NOTE: INADDR_ANY and IN_LINKLOCALNETNUM are defined as a host-endian constants, so they should be byte swapped
}

- (id) initWithAddress:(const struct sockaddr*)address
{
	return [self _initWithNetworkReachability:(address ? SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, address) : NULL)];
}

- (id) initWithIPv4Address:(UInt32)address
{
	struct sockaddr_in				ipAddress;
	
	bzero(&ipAddress, sizeof(ipAddress));
	ipAddress.sin_len = sizeof(ipAddress);
	ipAddress.sin_family = AF_INET;
	ipAddress.sin_addr.s_addr = address;
	
	return [self initWithAddress:(struct sockaddr*)&ipAddress];
}

- (id) initWithHostName:(NSString*)name
{
	return [self _initWithNetworkReachability:([name length] ? SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [name UTF8String]) : NULL)];
}

- (void) dealloc
{
    _delegate = nil;
    _runLoop = nil;
	if(_netReachability)
	CFRelease(_netReachability);
}

- (BOOL) isReachable
{
	SCNetworkConnectionFlags		flags;
	
	return (SCNetworkReachabilityGetFlags(_netReachability, &flags) && IS_REACHABLE(flags) ? YES : NO);
}

- (void) setDelegate:(id<NetReachabilityDelegate>)delegate
{
	SCNetworkReachabilityContext	context = {0, (__bridge void *)(self), NULL, NULL, NULL};
	
	if(delegate && !_delegate) {
		if(SCNetworkReachabilitySetCallback(_netReachability, _ReachabilityCallBack, &context)) {
			if(!SCNetworkReachabilityScheduleWithRunLoop(_netReachability, [_runLoop getCFRunLoop], kCFRunLoopCommonModes)) {
				SCNetworkReachabilitySetCallback(_netReachability, NULL, NULL);
				delegate = nil;
			}
		}
		else
		delegate = nil;
		if(delegate == nil)
		REPORT_ERROR(@"Failed installing SCNetworkReachability callback on runloop %p", _runLoop);
	}
	else if(!delegate && _delegate) {
		SCNetworkReachabilityUnscheduleFromRunLoop(_netReachability, [_runLoop getCFRunLoop], kCFRunLoopCommonModes);
		SCNetworkReachabilitySetCallback(_netReachability, NULL, NULL);
	}
	
	_delegate = delegate;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = 0x%08lX | reachable = %i>", [self class], (long)self, [self isReachable]];
}

@end
