/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "NSURLConnection+SNB.h"
#import "SynUserMock.h"
#import "SynUserMock_private.h"
#import <objc/runtime.h>
#import <JRSwizzle/JRSwizzle.h>

const void *_kSNBResponse = "kSNBResponse";
const void *_kSNBResponseData = "kSNBResponseData";
const void *_kSNBRequestBeginDate = "kSNBRequestBeginDate";
const void *_kSNBResponseBeginDate = "kSNBResponseBeginDate";

NSString *kSNBRequest = @"kSNBRequest";
NSString *kSNBResponse = @"kSNBResponse";
NSString *kSNBResponseData = @"kSNBResponseData";

NSString *kSNBRequestBeginDate = @"kSNBRequestBeginDate";
NSString *kSNBRequestEndDate = @"kSNBRequestEndDate";

NSString *kSNBResponseBeginDate = @"kSNBResponseBeginDate";
NSString *kSNBResponseEndDate = @"kSNBResponseEndDate";


@implementation NSURLConnection (SNB)

static NSUInteger kSNBMaxResponseSize = 1000000; // max response size is 1 mb

+ (void) installIntercept
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        [[self class] jr_swizzleMethod:@selector(initWithRequest:delegate:startImmediately:) withMethod:@selector(intercept_initWithRequest:delegate:startImmediately:) error:&error];
        [[self class] jr_swizzleClassMethod:@selector(sendAsynchronousRequest:queue:completionHandler:) withClassMethod:@selector(intercept_sendAsynchronousRequest:queue:completionHandler:) error:&error];
        [[self class] jr_swizzleClassMethod:@selector(sendSynchronousRequest:returningResponse:error:) withClassMethod:@selector(intercept_sendSynchronousRequest:returningResponse:error:) error:&error];
    });
}

#pragma mark - Method Swizzling

+ (NSData *)intercept_sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error
{
    NSDate *requestBeginDate = [NSDate date];
    NSDate *responseBeginDate = [NSDate date];
    
    NSData *data = [self intercept_sendSynchronousRequest:request returningResponse:response error:error];
    
    if (response != NULL && [*response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)*response;
        
        NSDictionary *allHeaders = [httpResponse allHeaderFields];
        if(allHeaders) {
            NSString *contentType = [allHeaders objectForKey:@"Content-Type"];
            if(contentType && [contentType rangeOfString:@"json"].location != NSNotFound) {
                data = [NSURLConnection copyResponse:data];
                if(request && response && data && requestBeginDate && responseBeginDate) {
                    if(![[SynUserMock sharedInstance].delegate respondsToSelector:@selector(synUserMockWillLogNetworkRequest:)] ||
                       [[SynUserMock sharedInstance].delegate synUserMockWillLogNetworkRequest:request]) {
                        [[SynUserMock sharedInstance] saveXMLTransactionWithRequest:request response:*response data:data userInfo:@{kSNBRequestBeginDate : requestBeginDate,
                                                                                                                                   kSNBRequestEndDate : responseBeginDate,
                                                                                                                                   kSNBResponseBeginDate : responseBeginDate,
                                                                                                                                   kSNBResponseEndDate : [NSDate date] }];
                    }
                }
            }
        }
    }
    
    return data;
}

+ (void)intercept_sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))handler
{
    NSDate *requestBeginDate = [NSDate date];
    NSDate *responseBeginDate = [NSDate date];
    
    void (^intercept_completion)(NSURLResponse*, NSData*, NSError*) =  ^(NSURLResponse *response, NSData *data, NSError *networkError) {
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            
            NSDictionary *allHeaders = [httpResponse allHeaderFields];
            if(allHeaders) {
                NSString *contentType = [allHeaders objectForKey:@"Content-Type"];
                if(contentType && [contentType rangeOfString:@"json"].location != NSNotFound) {
                    data = [NSURLConnection copyResponse:data];
                    if(request && response && data && requestBeginDate && responseBeginDate) {
                        if(![[SynUserMock sharedInstance].delegate respondsToSelector:@selector(synUserMockWillLogNetworkRequest:)] ||
                           [[SynUserMock sharedInstance].delegate synUserMockWillLogNetworkRequest:request]) {
                            [[SynUserMock sharedInstance] saveXMLTransactionWithRequest:request response:response data:data userInfo:@{kSNBRequestBeginDate : requestBeginDate,
                                                                                                                                      kSNBRequestEndDate : responseBeginDate,
                                                                                                                                      kSNBResponseBeginDate : responseBeginDate,
                                                                                                                                      kSNBResponseEndDate : [NSDate date] }];
                        }
                    }
                } 
            }
        }
        
        if(handler) {
            handler(response, data, networkError);
        }
    };
    
    [self intercept_sendAsynchronousRequest:request queue:queue completionHandler:intercept_completion];
}

- (id)intercept_initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately
{
    objc_setAssociatedObject(delegate, _kSNBRequestBeginDate, [NSDate date], OBJC_ASSOCIATION_RETAIN);
    if(![delegate respondsToSelector:@selector(setupIntercept)])
    {
        BOOL addResult = [self addMethodWithSelector:@selector(setupIntercept) forOriginatingSelectorClass:[self class] toClass:[delegate class]];
        if(addResult) {
            
            [self addMethodWithSelector:@selector(setupIntercept) forOriginatingSelectorClass:[self class] toClass:[delegate class]];
            
            if(![delegate respondsToSelector:@selector(connectionDidFinishLoading:)]) {
               [self addMethodWithSelector:@selector(connectionDidFinishLoading:) forOriginatingSelectorClass:[self class] toClass:[delegate class]];
            }
            if(![delegate respondsToSelector:@selector(connection:didReceiveResponse:)]) {
                [self addMethodWithSelector:@selector(connection:didReceiveResponse:) forOriginatingSelectorClass:[self class] toClass:[delegate class]];
            }
            if(![delegate respondsToSelector:@selector(connection:didReceiveData:)]) {
                [self addMethodWithSelector:@selector(connection:didReceiveData:) forOriginatingSelectorClass:[self class] toClass:[delegate class]];
            }
            if(![delegate respondsToSelector:@selector(connection:didFailWithError:)]) {
                [self addMethodWithSelector:@selector(connection:didFailWithError:) forOriginatingSelectorClass:[self class] toClass:[delegate class]];
            }
            
            [self addMethodWithSelector:@selector(intercept_connectionDidFinishLoading:) forOriginatingSelectorClass:[self class] toClass:[delegate class]];
            [self addMethodWithSelector:@selector(intercept_connection:didReceiveResponse:) forOriginatingSelectorClass:[self class] toClass:[delegate class]];
            [self addMethodWithSelector:@selector(intercept_connection:didReceiveData:) forOriginatingSelectorClass:[self class] toClass:[delegate class]];
            [self addMethodWithSelector:@selector(intercept_connection:didFailWithError:) forOriginatingSelectorClass:[self class] toClass:[delegate class]];

            [delegate performSelector:@selector(setupIntercept) withObject:nil];
        }        
    }
    
    return [self intercept_initWithRequest:request delegate:delegate startImmediately:startImmediately];
}

- (void)setupIntercept
{
    static dispatch_once_t onceToken;
    [SNBIntercept replaceOriginalMethod:@selector(connectionDidFinishLoading:) withMethod:@selector(intercept_connectionDidFinishLoading:) forClass:[self class] withToken:onceToken];
    
    static dispatch_once_t twiceToken;
    [SNBIntercept replaceOriginalMethod:@selector(connection:didReceiveResponse:) withMethod:@selector(intercept_connection:didReceiveResponse:) forClass:[self class] withToken:twiceToken];
    
    static dispatch_once_t threeToken;
    [SNBIntercept replaceOriginalMethod:@selector(connection:didReceiveData:) withMethod:@selector(intercept_connection:didReceiveData:) forClass:[self class] withToken:threeToken];
}

- (BOOL)addMethodWithSelector:(SEL)selector forOriginatingSelectorClass:(Class)originatingClass toClass:(Class)toClass
{
    Method originalMethod = class_getInstanceMethod(originatingClass, selector);
    BOOL didAddMethod = class_addMethod(toClass, selector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    return didAddMethod;
}


#pragma mark - NSURLConnectionDataDelegate

- (void)intercept_connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSURLRequest *request = [connection originalRequest];
    NSURLResponse *response = objc_getAssociatedObject(self, _kSNBResponse);
    NSData *data = objc_getAssociatedObject(self, _kSNBResponseData);
    NSDate *requestBeginDate = objc_getAssociatedObject(self, _kSNBRequestBeginDate);
    NSDate *responseBeginDate = objc_getAssociatedObject(self, _kSNBResponseBeginDate);
    
    data = [NSURLConnection copyResponse:data];
    if(request && response && data && requestBeginDate && responseBeginDate) {
        if(![[SynUserMock sharedInstance].delegate respondsToSelector:@selector(synUserMockWillLogNetworkRequest:)] ||
           [[SynUserMock sharedInstance].delegate synUserMockWillLogNetworkRequest:request]) {
            [[SynUserMock sharedInstance] saveXMLTransactionWithRequest:request response:response data:data userInfo:@{kSNBRequestBeginDate : requestBeginDate,
                                                                                                                      kSNBRequestEndDate : responseBeginDate,
                                                                                                                      kSNBResponseBeginDate : responseBeginDate,
                                                                                                                      kSNBResponseEndDate : [NSDate date] }];
        }
    }
    
    [self intercept_connectionDidFinishLoading:connection];
}

- (void)intercept_connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if(response) {
        objc_setAssociatedObject(self, _kSNBResponse, response, OBJC_ASSOCIATION_COPY);
        objc_setAssociatedObject(self, _kSNBResponseBeginDate, [NSDate date], OBJC_ASSOCIATION_RETAIN);
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            
            NSDictionary *allHeaders = [httpResponse allHeaderFields];
            if(allHeaders) {
                objc_setAssociatedObject(self, @"kSNBRequestHeaders", allHeaders, OBJC_ASSOCIATION_COPY);
            }
        }
    }
    
    [self intercept_connection:connection didReceiveResponse:response];
}


- (void)intercept_connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSDictionary *allHeaders = objc_getAssociatedObject(self, @"kSNBRequestHeaders");
    if(allHeaders) {
        NSString *contentType = [allHeaders objectForKey:@"Content-Type"];
        if(contentType && [contentType rangeOfString:@"json"].location != NSNotFound) {
            
            NSMutableData *storedData = objc_getAssociatedObject(self, _kSNBResponseData);
            if(storedData) {
                [storedData appendData:data];
            } else {
                storedData = [[NSMutableData alloc] initWithData:data];
            }
            
            if(storedData) {
                objc_setAssociatedObject(self, _kSNBResponseData, storedData, OBJC_ASSOCIATION_RETAIN);
            }
        } 
    }
    
    [self intercept_connection:connection didReceiveData:data];
}

- (void)intercept_connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // Log errors in the future
    [self intercept_connection:connection didFailWithError:error];
}

+ (NSData *)copyResponse:(NSData *)data
{
    NSData *copiedData = nil;
    if(data) {
        if(data.length < kSNBMaxResponseSize) {
            copiedData = [[NSString stringWithFormat:@"Response not saved, too large: %ldbytes", (unsigned long)[data length]] dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            copiedData = [data copy];
        }
    }
    
    return copiedData;
}

#pragma mark - Dummy Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response { }
- (void)connectionDidFinishLoading:(NSURLConnection *)connection { }
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data { }
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error { }

@end
