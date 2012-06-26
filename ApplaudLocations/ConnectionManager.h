//
//  ConnectionManager.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/19/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define EXAMPLE_URL @"/mobile/example3"
#define WHEREAMI_URL @"/mobile/whereami"
#define EMPLOYEES_URL @"/mobile/employees"
#define EVALUATE_URL @"/mobile/evaluate"
#define FEEDBACK_URL @"/mobile/general_feedback"
#define CHECKIN_URL @"/mobile/checkin"
#define NEWSFEED_URL @"/mobile/newsfeed"
#define SURVEY_URL @"/business/get_survey"
#define RESPONSE_URL @"/mobile/survey_respond"
#define LOGIN_URL @"/accounts/mobilelogin/"
#define CSRF_URL @"/mobile/csrf/"

@interface ConnectionManager : NSObject

// requestType : either GET or POST
// params : arguments to pass to the server
// url : where to make the request to, relative to SERVER_URL
// callback : a block to call when data is received asynchronously
// returns : the server's response to the request
+ (NSData *)serverRequest:(NSString *)requestType withParams:(NSDictionary *)params url:(NSString *)url callback:(void(^)(NSData *))callback;

+ (NSData *)serverRequest:(NSString *)requestType withParams:(NSDictionary *)params url:(NSString *)url;

// Same as above method, but takes general data
+ (NSData *)serverRequest:(NSString *)requestType withData:(NSData *)data url:(NSString *)url callback:(void(^)(NSData *))callback;
+ (NSData *)serverRequest:(NSString *)requestType withData:(NSData *)data url:(NSString *)url;

// dict : dictionary of parameters to use in a GET string
// returns : the GET string encoded with the parameters, starting with '?'
+ (NSString *)GETStringFromDict:(NSDictionary *)dict;

// urlString : Where to get CSRF from
// returns : the CSRF token encoded in a UTF8String
+ (NSString *)getCSRFTokenFromURL:(NSString *)urlString;

// Container for class variables.
+ (ConnectionManager *)staticInstance;

// Manage logins and logouts
+ (BOOL)authenticateWithUsername:(NSString *)username password:(NSString *)password;

/*** CLASS MEMBERS ***/
@property (nonatomic, copy) NSString *sessionCookie;

@end