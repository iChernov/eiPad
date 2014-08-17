//
//  billWebView.m
//  E-Iphone
//
//  Created by Ivan Chernov on 10.12.10.
//  Copyright 2010 SKB-Kontur. All rights reserved.
//

#import "billWebView.h"
#import "MGTemplateEngine.h"
#import "ICUTemplateMatcher.h"
#import "funcs.h"

@implementation billWebView
@synthesize htmlPage, billView;


- (id)initWithBill:(NSDictionary *)billInfo
{
	MGTemplateEngine *engine = [MGTemplateEngine templateEngine];
	[engine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:engine]];
    NSString *templatePath = @"";
	NSString *dtype = [billInfo objectForKey: @"DocumentType"];
    if(dtype == @"DeliveryNote")
    {
        templatePath = [[NSBundle mainBundle] pathForResource:@"Act" ofType:@"html"];
    }
    else if(dtype == @"Act")
    {
        templatePath = [[NSBundle mainBundle] pathForResource:@"DeliveryNote" ofType:@"html"];
    }
    else
    {
        templatePath = [[NSBundle mainBundle] pathForResource:@"bill" ofType:@"html"];
    }
    
	
	NSMutableDictionary *variables = [[NSMutableDictionary alloc] init];
	
	NSArray *arr = [billInfo objectForKey:@"Items"];
	int numberOfItems = [arr count];
	CGFloat height = 720+30*numberOfItems;
	CGRect webFrame = CGRectMake(0.0, 0.0, 750.0, height);
	
	double allSummary = 0;
	NSMutableArray *showingItems = [[NSMutableArray alloc] init];
	
	[variables setObject:[billInfo valueForKey:@"BillNumb"] forKey:@"docNumbLabel"];
	[variables setObject:[billInfo valueForKey:@"BillDate"] forKey:@"docDateLabel"];
	[variables setObject:[(NSArray *)[billInfo valueForKey:@"Client"] objectAtIndex:2] forKey:@"clNameLabel"];
	
	for (int i=0; i<numberOfItems; i++) {
		NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:[arr objectAtIndex:i]];
		[item setObject:[[NSString alloc] initWithFormat:@"%d", i+1] forKey:@"number"];
		allSummary += [[item valueForKey:@"Summary"] doubleValue];
		[showingItems addObject:item];
	}
	//допеределать с массива на словарь
	
	NSString *noi = [[NSString alloc] initWithFormat:@"%d",numberOfItems];
	NSString *summary = [[NSString alloc] initWithFormat:@"%.2f",allSummary];
	NSString *summaryWord = [[NSString alloc] initWithCString:(numberToString(allSummary)) encoding:NSUTF8StringEncoding];
	[variables setObject:showingItems forKey:@"items"];
	[variables setObject:noi forKey:@"numberOfItems"];
	
	[variables setObject:summary forKey:@"summary"];
	[variables setObject:summaryWord forKey:@"summaryWord"];
	
	NSString *selfInfoStr = [NSString stringWithFormat:@"%@/selfInfo.plist", [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]];
	NSString *nameStr = [[NSString alloc] initWithString:selfInfoStr];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *savingDictFileName = [documentsDirectory stringByAppendingPathComponent:nameStr];
	NSDictionary *selfInfoArr = [[NSDictionary alloc] initWithContentsOfFile:savingDictFileName];
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"isIP"])
	{
		[variables setObject:@"ИП" forKey:@"IPorOOO"];
		[variables setObject:@"Индивидуальный предприниматель" forKey:@"IPorPROFESSION"];
		NSMutableString *tempstr = [NSMutableString new];
		[tempstr appendFormat:@"%@", [self nullableToString: [selfInfoArr objectForKey:@"Surname"]]];
		[tempstr appendFormat:@" "];
		[tempstr appendFormat:@"%@", [self nullableToString: [selfInfoArr objectForKey:@"Name"]]];
		[tempstr appendFormat:@" "];
		[tempstr appendFormat:@"%@", [self nullableToString: [selfInfoArr objectForKey:@"Patronymic"]]];
		[variables setObject:tempstr forKey:@"selfName"];
	}
	else {
		[variables setObject:@"ООО" forKey:@"IPorOOO"];
		[variables setObject:[selfInfoArr objectForKey:@"OrganizationShortName"] forKey:@"IPorPROFESSION"];
		NSMutableString *tempstr = [NSMutableString new];
		[tempstr appendFormat:@"%@", [self nullableToString: [selfInfoArr objectForKey:@"BossSurname"]]];
		[tempstr appendFormat:@" "];
		[tempstr appendFormat:@"%@", [self nullableToString: [selfInfoArr objectForKey:@"BossName"] ]];
		[tempstr appendFormat:@" "];
		[tempstr appendFormat:@"%@", [self nullableToString: [selfInfoArr objectForKey:@"BossPatronymic"] ]];
		[variables setObject:tempstr forKey:@"selfName"];
	}
	[variables setObject:[self nullableToString: [selfInfoArr objectForKey:@"Address"]] forKey:@"address"];
	[variables setObject:[self nullableToString: [selfInfoArr objectForKey:@"Phone"]] forKey:@"phoneNumber"];
	[variables setObject:[self nullableToString: [selfInfoArr objectForKey:@"INN"]] forKey:@"INN"];
	[variables setObject:[self nullableToString: [selfInfoArr objectForKey:@"KPP"]] forKey:@"KPP"];
	[variables setObject:[self nullableToString: [selfInfoArr objectForKey:@"BankName"]] forKey:@"bankName"];
	[variables setObject:[self nullableToString: [selfInfoArr objectForKey:@"BankBik"]] forKey:@"bankBIK"];
	[variables setObject:[self nullableToString: [selfInfoArr objectForKey:@"AccountNumber"]] forKey:@"rs"];
	[variables setObject:[self nullableToString: [selfInfoArr objectForKey:@"BankCorrAccount"]] forKey:@"ks"];
	[self insertValuesIn:variables from:selfInfoArr];
	
	htmlPage = [engine processTemplateInFileAtPath:templatePath withVariables:variables];
	wV = [[UIWebView alloc] initWithFrame:webFrame];
	[wV loadHTMLString:htmlPage baseURL:nil];
	[variables release];
	return self;	
}

- (NSString *)returnHtml
{
	return [[NSString alloc] initWithString:htmlPage];
}

- (void)insertValuesIn:(NSMutableDictionary *)variables from:(NSDictionary *)selfInfoDct
{
	for (NSString *key in [selfInfoDct allKeys]) {
		[variables setObject:([self nullableToString: [selfInfoDct objectForKey:key] ]) forKey:key];
	}
}

-(NSString *)nullableToString:(id) object {
	if (object == nil) {
		return @"";
	}
	else {
		return (NSString *) object;
	}
	
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	[wV release];
    [super dealloc];
}


@end
