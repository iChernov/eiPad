//
//  ElbaSyncProxy.h
//  E-Iphone
//
//  Created by Ivan Chernov on 30.11.10.
//  Copyright 2010 SKB-Kontur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ElbaSyncProxyProtocol.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"

@interface ElbaSyncProxy : NSObject <ElbaSyncProxyProtocol> {
	NSString *url;
	CJSONSerializer *serializer;
	CJSONDeserializer *deserializer;
	NSString *login;
	NSString *password;
	NSUserDefaults *userDefs;
}
-(NSData *)execute:(NSString*)methodName as:(NSString*)sendType withBody:(NSData*)body andArgs:(id)first, ... NS_REQUIRES_NIL_TERMINATION; 
@end
