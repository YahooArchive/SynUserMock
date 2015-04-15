/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBStateTransactionItem.h"

extern NSString *kSNBRequest;
extern NSString *kSNBResponse;
extern NSString *kSNBResponseData;
extern NSString *kSNBRequestBeginDate;
extern NSString *kSNBRequestEndDate;
extern NSString *kSNBResponseBeginDate;
extern NSString *kSNBResponseEndDate;
extern NSString *SNBURLEncodeString(NSString *stringToEncode);
static NSDateFormatter *dateFormatter = nil;

@interface SNBStateTransactionItem()

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSDate *requestBeginDate;
@property (nonatomic, strong) NSDate *requestEndDate;
@property (nonatomic, strong) NSDate *responseBeginDate;
@property (nonatomic, strong) NSDate *responseEndDate;
@end

@implementation SNBStateTransactionItem



+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'hh:mm:ss.SSSxxxxx";
    });
}

- (instancetype)initWithRequest:(NSURLRequest *)request response:(NSURLResponse *)response data:(NSData *)data userInfo:(NSDictionary *)userInfo
{
    self = [super init];
    if(self) {
        self.request = request;
        self.response = response;
        self.data = data;
        
        self.requestBeginDate = userInfo[kSNBRequestBeginDate] ? userInfo[kSNBRequestBeginDate] : [NSDate date];
        self.requestEndDate = userInfo[kSNBRequestEndDate] ? userInfo[kSNBRequestEndDate] : [NSDate date];
        self.responseBeginDate = userInfo[kSNBResponseBeginDate] ? userInfo[kSNBResponseBeginDate] : [NSDate date];
        self.responseEndDate = userInfo[kSNBResponseEndDate] ? userInfo[kSNBResponseEndDate] : [NSDate date];
    }
    
    return self;
}

- (NSData *)transactionData
{
    NSData *data = nil;
    
    return data;
}


- (NSString *)replaceTag:(NSString *)tag withValue:(NSString *)value forContent:(NSString *)content
{
    return [content stringByReplacingOccurrencesOfString:tag withString:value];
}

- (NSString *)transactionElement
{
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"transaction" ofType:@"xml"];
    NSString *content = [NSString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:NULL];
    NSURL *url = [self.request URL];
    
    NSString *requestBeginDate = [dateFormatter stringFromDate:self.requestBeginDate];
    NSString *requestBeginTime = [NSString stringWithFormat:@"%0.0f", [self.requestBeginDate timeIntervalSince1970] * 1000];
    NSString *responseBeginDate = [dateFormatter stringFromDate:self.responseBeginDate];
    NSString *responseBeginTime = [NSString stringWithFormat:@"%0.0f", [self.responseBeginDate timeIntervalSince1970] * 1000];
    NSString *responseEndDate = [dateFormatter stringFromDate:self.responseEndDate];
    NSString *responseEndTime = [NSString stringWithFormat:@"%0.0f", [self.responseEndDate timeIntervalSince1970] * 1000];
    NSString *duration = [NSString stringWithFormat:@"%0.0f", [self.responseEndDate timeIntervalSince1970] - [self.requestBeginDate timeIntervalSince1970]];
    
    // #STATUS#
    NSString *status = @"Complete";
    content = [self replaceTag:@"#STATUS#" withValue:status forContent:content];
    
    // #GET#
    NSString *method = [self.request HTTPMethod] ? [self.request HTTPMethod] : @"Undefined";
    content = [self replaceTag:@"#GET#" withValue:method forContent:content];
    
    // #PROTOCOL_VERSION#
    NSString *protocolVersion = @"HTTP/1.1";
    content = [self replaceTag:@"#PROTOCOL_VERSION#" withValue:protocolVersion forContent:content];
    
    // #PROTCOL#
    NSString *protocol = @"http";
    content = [self replaceTag:@"#PROTCOL#" withValue:protocol forContent:content];
    
    // #HOST#
    NSString *host = @"undefined";
    if(url) {
        host = [url host] ? [url host] : @"undefined";
    }
    content = [self replaceTag:@"#HOST#" withValue:host forContent:content];
    
    // #PORT#
    NSString *port = @"0";
    if(url) {
        NSNumber *portVal = [url port];
        if(portVal) {
            port = [NSString stringWithFormat:@"%ld", (long)[portVal integerValue]];
        }
    }
    content = [self replaceTag:@"#PORT#" withValue:port forContent:content];
    
    // #PATH#
    NSString *path = @"undefined";
    if(url) {
        path = [url relativePath] ? [url relativePath] : @"undefined";
    }
    content = [self replaceTag:@"#PATH#" withValue:path forContent:content];
    
    // #QUERY#
    NSString *query = @"undefined";
    if(url) {
        query = [url query] ? ampEncode([url query]) : @"undefined";
    }
    content = [self replaceTag:@"#QUERY#" withValue:query forContent:content];
    
    // #REMOTE_ADDRESS#
    NSString *remoteAddress = @"undefined";
    if(url) {
        remoteAddress = [url host] ? [url host] : @"undefined";
    }
    content = [self replaceTag:@"#REMOTE_ADDRESS#" withValue:remoteAddress forContent:content];
    
    // #CLIENT_ADDRESS#
    NSString *clientAddress = @"/127.0.0.1";
    content = [self replaceTag:@"#CLIENT_ADDRESS#" withValue:clientAddress forContent:content];
    
    // #START_TIME#
    content = [self replaceTag:@"#START_TIME#" withValue:requestBeginDate forContent:content];
    
    // #START_TIME_MILLIS#
    content = [self replaceTag:@"#START_TIME_MILLIS#" withValue:requestBeginTime forContent:content];
    
    // #DNS_DURATION#
    NSString *dnsDuration = @"0";
    content = [self replaceTag:@"#DNS_DURATION#" withValue:dnsDuration forContent:content];
    
    // #CONNECT_DURATION#
    content = [self replaceTag:@"#CONNECT_DURATION#" withValue:duration forContent:content];
    
    // #REQUEST_BEGIN_TIME#
    content = [self replaceTag:@"#REQUEST_BEGIN_TIME#" withValue:requestBeginTime forContent:content];
    
    // #REQUEST_BEGIN_TIME_MILLIS#
    content = [self replaceTag:@"#REQUEST_BEGIN_TIME_MILLIS#" withValue:requestBeginTime forContent:content];
    
    // #REQUEST_TIME#
    content = [self replaceTag:@"#REQUEST_TIME#" withValue:requestBeginDate forContent:content];
    
    // #REQUEST_TIME_MILLIS#
    content = [self replaceTag:@"#REQUEST_TIME_MILLIS#" withValue:responseBeginTime forContent:content];
    
    // #RESPONSE_TIME#
    content = [self replaceTag:@"#RESPONSE_TIME#" withValue:responseBeginDate forContent:content];
    
    // #RESPONSE_TIME_MILLIS#
    content = [self replaceTag:@"#RESPONSE_TIME_MILLIS#" withValue:responseBeginTime forContent:content];
    
    // #END_TIME#
    content = [self replaceTag:@"#END_TIME#" withValue:responseEndDate forContent:content];
    
    // #END_TIME_MILLIS#
    content = [self replaceTag:@"#END_TIME_MILLIS#" withValue:responseEndTime forContent:content];
    
    return content;
    
}


- (NSString *)requestHeaders
{
    NSURL *url = [self.request URL];
    NSMutableString *requestHeaders = [[NSMutableString alloc] init];
    
    NSString *requestBody = nil;
    NSInteger bodyLength = 0;
    if([self.request HTTPBody]) {
        requestBody = [[NSString alloc] initWithData:[self.request HTTPBody] encoding:NSUTF8StringEncoding];
        bodyLength = [requestBody length];
    }
    
    NSString *mimeType = nil;
    NSString *contentType = nil;
    if([[self.request HTTPMethod] isEqualToString:@"POST"]) {
        mimeType = @"application/x-www-form-urlencoded";
        contentType = @"application/x-www-form-urlencoded";
    } else {
        mimeType = @"application/json";
    }
    
    NSString *head = [NSString stringWithFormat:@"<request headers=\"1224\" body=\"%ld\" mime-type=\"%@\">\n", (long)bodyLength, mimeType];
    [requestHeaders appendString:head];
    [requestHeaders appendString:@"<headers>\n"];
    
    if(url) {
        [requestHeaders appendFormat:@"<first-line><![CDATA[%@ %@?%@]]></first-line>", [self.request HTTPMethod], [url relativePath], [url query]];
        [requestHeaders appendString: [self headerForName:@"Host" value:[url host]]];
        
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSMutableString *cookies = [[NSMutableString alloc] init];
        [cookieStorage.cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {
            NSString *value = [cookie.value stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
            [cookies appendFormat:@"%@=%@; ", [self stringByDoubleEncodingHTMLEntities:cookie.name], [self stringByDoubleEncodingHTMLEntities:value]];
        }];
        [requestHeaders appendString:[self headerForName:@"Cookie" value:cookies]];
    }
    
    if(contentType) {
        [requestHeaders appendString:[self headerForName:@"Content-Type" value:contentType]];
    }

    [requestHeaders appendString:@"</headers>\n"];
    
    if(requestBody) {
        [requestHeaders appendFormat:@"<body><![CDATA[%@]]></body>\n", requestBody];
    }
    
    [requestHeaders appendString:@"</request>\n"];
    
    return requestHeaders;
}

- (NSString *)responseHeaders
{
    //NSURL *url = [self.request URL];
    NSHTTPURLResponse *httpResponse = nil;
    if ([self.response isKindOfClass:[NSHTTPURLResponse class]]) {
        httpResponse = (NSHTTPURLResponse *)self.response;
    }

    NSMutableString *responseHeaders = [[NSMutableString alloc] init];
    [responseHeaders appendFormat:@"<response status=\"%ld\" headers=\"323\" body=\"211149\" mime-type=\"%@\">\n", (long)[httpResponse statusCode], [self.response MIMEType]];
    [responseHeaders appendFormat:@"<headers>\n\t<first-line><![CDATA[HTTP/1.1 %ld %@]]></first-line>\n", (long)[httpResponse statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]]];
    
    
    NSDictionary *allHeaders = [httpResponse allHeaderFields];
    [allHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [responseHeaders appendString:[self headerForName:key value:value]];
    }];
    
    [responseHeaders appendString:@"</headers>\n"];
    
    return responseHeaders;
}

- (NSString *)body
{
    NSMutableString *body = [[NSMutableString alloc] init];
    [body appendString:@"\n<body><![CDATA["];
    
    NSString *bodyString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    if(!bodyString) {
        bodyString = @"Unable to save body data.";
    }
    
    [body appendString:bodyString];
    [body appendString:@"]]></body>\n</response>\n</transaction>\n\n"];
    
    return body;
}

- (NSString *)toString
{
    NSMutableString *returnString = [[NSMutableString alloc] init];
    [returnString appendString:[self transactionElement]];
    [returnString appendString:[self requestHeaders]];
    [returnString appendString:[self responseHeaders]];
    [returnString appendString:[self body]];
    
    return returnString;
}

- (NSData *)toBytes
{
    NSString *stringVal = [self toString];
    return [stringVal dataUsingEncoding: NSUTF8StringEncoding];
}

- (NSString *)headerForName:(NSString *)name value:(NSString *)value
{
    return [NSString stringWithFormat:@"<header>\n\t<name>%@</name><value>%@</value>\n</header>\n", name, value];
}


NSString *ampEncode(NSString *stringToEncode)
{
    return [stringToEncode stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
}

- (NSString *)stringByDoubleEncodingHTMLEntities:(NSString *)aString
{
    NSString *s = [aString stringByReplacingOccurrencesOfString:@"\'" withString:@"&amp;#39;"];
    s = [s stringByReplacingOccurrencesOfString:@"\"" withString:@"&amp;quot;"];
    s = [s stringByReplacingOccurrencesOfString:@"<" withString:@"&amp;lt;"];
    s = [s stringByReplacingOccurrencesOfString:@">" withString:@"&amp;gt;"];
    s = [s stringByReplacingOccurrencesOfString:@"\\" withString:@"&amp;#92;"];
    return s;
}

@end

