/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBStateSaverConsoleOperation.h"
#import "asl.h"

static NSDateFormatter *dateFormatter;

static NSString *kConsoleTimeKey = @"Time";
static NSString *kConsoleMessageKey = @"Message";

@interface SNBStateSaverConsoleOperation()

@property (nonatomic, assign) BOOL isExecuting;
@property (nonatomic, assign) BOOL isFinished;

@property (nonatomic, strong) NSString *path;

@property (nonatomic, assign) BOOL success;

@end

@implementation SNBStateSaverConsoleOperation

- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    if(self) {
        self.path = path;
        
        if (!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"M/d/yyyy h:mma"];
        }
    }
    return self;
}

- (void)start
{
    NSString *consoleLog = [self fetchConsole];
    BOOL success = [consoleLog writeToFile:[self.path stringByAppendingPathComponent:@"console.log"] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    self.success = success;
}

- (NSString *)fetchConsole
{
    NSMutableString *response = nil;
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    
    if(appName) {
        
        response = [[NSMutableString alloc] init];
        aslmsg q = asl_new(ASL_TYPE_QUERY);
        
        if(q) {
            uint32_t senderQueryOptions = ASL_QUERY_OP_EQUAL | ASL_QUERY_OP_CASEFOLD|ASL_QUERY_OP_SUBSTRING;
            asl_set_query(q, ASL_KEY_SENDER, [appName UTF8String], senderQueryOptions);
            
            aslresponse r = asl_search(NULL, q);
            if(r) {
                
                aslmsg m;
                int i;
                const char *key, *val;
                
                while (NULL != (m = aslresponse_next(r))) {
                    
                    NSMutableDictionary *responseDict = [[NSMutableDictionary alloc] init];
                    for (i = 0; (NULL != (key = asl_key(m, i))); i++)
                    {
                        NSString *keyString = nil;
                        if(key) {
                            keyString = [NSString stringWithUTF8String:(char *) key];
                            val = asl_get(m, key);
                            
                            NSString *string = val ? [NSString stringWithUTF8String:val] : @"";
                            [responseDict setObject:string forKey:keyString];
                        }
                    }
                    
                    if(responseDict[kConsoleTimeKey] && responseDict[kConsoleMessageKey]) {
                        
                        NSTimeInterval interval = [responseDict[kConsoleTimeKey] doubleValue];
                        NSDate *timeStamp = [[NSDate alloc] initWithTimeIntervalSince1970: interval];
                        NSString *dateText = [dateFormatter stringFromDate:timeStamp];
                        
                        NSString *consoleLine = [NSString stringWithFormat:@"%@: %@\n", dateText, responseDict[kConsoleMessageKey]];
                        [response appendString:consoleLine];
                    }
                }
            }
            
            aslresponse_free(r);
        }
    }
    
    return response;
}

@end
