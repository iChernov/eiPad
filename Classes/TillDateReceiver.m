//
//  TillDateReceiver.m
//  E-Iphone
//
//  Created by Ivan Chernov on 27.05.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import "TillDateReceiver.h"
extern serverAddress;

@implementation TillDateReceiver
@synthesize delegate;
- (id)init
{
    [super init];
    return self;
}
- (NSString *)getTillDate
{
    NSString *tillDate = [self loadTillDate];
    if (tillDate) {
        if([self isDate:tillDate])
        {
            tillDateString = [NSString stringWithFormat:@"Веб-сервис Эльба оплачен до: %@", tillDate];
        }
        else if([tillDate isEqualToString:@"Bad Request"])
        {
            tillDateString = [NSString stringWithFormat:@"", tillDate];
        }
        else if([tillDate isEqualToString:@"FreeMode"])
        {
            tillDateString = [NSString stringWithFormat:@"Веб-сервис Эльба не оплачен", tillDate];
        }
    }
    return tillDateString;
    //[delegate showTillDateLabel:tillDateString];
}

-(NSString *)loadTillDate
{
    NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/PublicInterface/IPhone/%@?login=%@&password=%@&version=%@", serverAddress, @"GetTillDate.ashx", [userDefs valueForKey:@"login"], [userDefs valueForKey:@"pass"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] ]];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url 
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                          timeoutInterval:60];
	
	[theRequest setHTTPMethod:@"POST"];		
   	
	NSHTTPURLResponse* urlResponse = nil;
	NSError *error = [[[NSError alloc] init] autorelease];  
	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:theRequest
												 returningResponse:&urlResponse 
															 error:&error];  
    
	NSString *responseString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
    
	return responseString;
}

- (BOOL)isDate:(NSString *)dateStr
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yyyy"];
    NSDate *date = [dateFormat dateFromString:dateStr];
    NSString *backConvertedDate = [dateFormat stringFromDate:date];
    [dateFormat release];
    return [dateStr isEqualToString:backConvertedDate];
}

@end
