//
//  UpdateNotifier.m
//  E-Iphone
//
//  Created by Ivan Chernov on 03.03.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import "UpdateNotifier.h"


@implementation UpdateNotifier
extern NSString* serverAddress;
@synthesize criticalMessage, updateMessage;

-(id)init
{
	self = [super init];
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	criticalMessage = [[NSString alloc] initWithString: ([defs valueForKey:@"criticalMessage"] ? [defs valueForKey:@"criticalMessage"] : @"noupdates")];
	updateMessage = [[NSString alloc] initWithString: ([defs stringForKey:@"updateMessage"] ? [defs stringForKey:@"updateMessage"] : @"")];
	[defs release];
	return self;
}
-(void)receiveCriticalAndUpgradeMeassages
{
	NSData* returnData = [self receiveUpdateDataFromServer];
    NSString *response = @"noupdates";
	response = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];
	//first parameter: noupdates, ordinal, critical
	//response = @"ordinal\nПришло время обновить Эльбу!";
	//second parameter: text or empty string
	long delimiterPosition = [response rangeOfString: @"\n"].location;
    if((![response isEqualToString:@""])&&(![response isEqual:[NSNull null]]))
    {
        criticalMessage = [[response substringToIndex: delimiterPosition] retain]; 
        updateMessage = [[response substringFromIndex: delimiterPosition + 1] retain];
	
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        [defs setValue:criticalMessage forKey:@"criticalMessage"];
        [defs setValue:updateMessage forKey:@"updateMessage"];
        [defs release];
    }
    else
    {
        criticalMessage = @"noupdates";
        updateMessage = @"";
    }
}

-(void)resetUpdateStatus
{
	criticalMessage = @"noupdates";
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	[defs setValue:criticalMessage forKey:@"criticalMessage"];
	[defs release];
}

-(NSData *)receiveUpdateDataFromServer
{
	NSString * urlString = [NSString stringWithFormat:@"%@/PublicInterface/IPhone/GetNews.ashx?version=%@", serverAddress, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];

	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod: @"GET"];
	NSError *requestError = nil;
	NSURLResponse *response = nil;
	NSData *responseBody = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&requestError];
    if((responseBody == nil) || (requestError != nil))
		if (responseBody) 
			[NSException raise:@"Network related error" format:@"Ошибка соединения %@" arguments:[requestError localizedDescription]];
		else 
			[NSException raise:@"Network related error" format:@"ошибка сетевого соединения"];
	[request release];
	return responseBody;	
}

-(void) dealloc
{
	[criticalMessage release];
	[updateMessage release];
	[super dealloc];
}
@end
