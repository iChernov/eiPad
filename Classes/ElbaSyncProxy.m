//
//  ElbaSyncProxy.m
//  E-Iphone
//
//  Created by Ivan Chernov on 15.11.10.
//  Copyright 2010 SKB-Kontur. All rights reserved.
//

#import "ElbaSyncProxy.h"
#import "BillRepository.h"
@implementation ElbaSyncProxy
extern NSString* serverAddress;
- (id)init
{
	self = [super init];
	userDefs = [NSUserDefaults standardUserDefaults];
	url = [NSString stringWithFormat:@"%@/PublicInterface/IPhone/", serverAddress];
	serializer = [[CJSONSerializer serializer] retain];
	deserializer = [[CJSONDeserializer deserializer] retain];
	login = [[userDefs valueForKey:@"login"] retain];
	password = [[userDefs valueForKey:@"pass"] retain];
	return self;
}
- (NSArray *)getChangedIds:(long long)timestamp
{
	NSData* responseBody = [self execute: @"GetChangedIds" as:@"GET" withBody:nil andArgs: @"timestamp", [NSString stringWithFormat:@"%qi", timestamp], nil];
	return [deserializer deserializeAsArray:responseBody error:nil];
}

- (Bill *)downloadBill:(NSString *)billId
{
	NSData *responseBody = [self execute: @"DownloadBill" as:@"GET" withBody:nil andArgs: @"id", billId, nil];
	return [[[Bill alloc] initWithDictionary:[deserializer deserializeAsDictionary:responseBody error:nil]] autorelease];
}

- (NSString *)uploadBill:(Bill *)bill
{	
   //NSLog(@"uploading bill %@", [bill getDictionary]);
	NSData *requestBody = [[serializer serializeDictionary:[bill getDictionary]] dataUsingEncoding:NSUTF8StringEncoding];
	NSData *returnData = [self execute:@"UploadBill" as:@"POST" withBody:requestBody andArgs: nil];
	return [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];
}

-(NSData *)execute:(NSString*)methodName as:(NSString*)sendType withBody:(NSData*)body andArgs:(id)first, ...
{
    NSString * urlString =[NSString stringWithFormat:@"%@%@.ashx?login=%@&password=%@&version=%@", url, methodName, [userDefs valueForKey:@"login"], [userDefs valueForKey:@"pass"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
	id name;
	id value;
    va_list alist;
    if(first) {
        va_start(alist, first);
		value = va_arg(alist, id);
        urlString = [urlString stringByAppendingFormat:@"&%@=%@", first, value];
		
        while (name = va_arg(alist, id)) {
			value = va_arg(alist, id);
			urlString = [urlString stringByAppendingFormat:@"&%@=%@",name, value];
		}
        va_end(alist);
    }
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod: sendType];
	if (body) {
		[request setHTTPBody:body];
	}
	NSError *requestError = nil;
	NSURLResponse *response = nil;
	NSData *responseBody = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&requestError];
	
	
	if((responseBody == nil) || (requestError != nil))
		if (responseBody) 
        {
			[NSException raise:@"Network related error" format:@"ошибка соединения %@" arguments:[requestError localizedDescription]];
        }
		else 
        {
			[NSException raise:@"Network related error" format:@"отсутствует сетевое соединение"];
        }
	[request release];
	
	return responseBody;
}

-(void) dealloc{

	[serializer release];
	[deserializer release];
	[login release];
	[password release];
	[super dealloc];
}
@end
