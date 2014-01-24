#import <Foundation/Foundation.h>
#import <sys/socket.h>

#ifdef __cplusplus
extern "C"
{
#endif
NSString* SockaddrToString(const struct sockaddr* address); //Returns nil if "address" is invalid

NSString* HostGetName();
#ifdef __cplusplus
}
#endif
