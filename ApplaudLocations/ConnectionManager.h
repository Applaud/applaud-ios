//
//  ConnectionManager.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/19/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define EXAMPLE_URL @"/mobile/example3/"
#define WHEREAMI_URL @"/mobile/whereami/"
#define EMPLOYEES_URL @"/mobile/employees/"
#define EVALUATE_URL @"/mobile/evaluate/"
#define FEEDBACK_URL @"/mobile/general_feedback/"
#define CHECKIN_URL @"/mobile/checkin/"
#define POLLS_URL @"/mobile/get_polls/"
#define NEWSFEED_URL @"/mobile/newsfeed/"
#define SURVEY_URL @"/mobile/get_survey/"
#define RESPONSE_URL @"/mobile/survey_respond/"
#define LOGIN_URL @"/accounts/mobilelogin/"
#define PHOTO_URL @"/mobile/post_photo/"
#define GET_PHOTO_URL @"/mobile/get_photos/"

@interface ConnectionManager : NSObject

// requestType : either GET or POST
// params : arguments to pass to the server
// url : where to make the request to, relative to SERVER_URL
// callback : a block to call when data is received asynchronously
// returns : the server's response to the request
+ (void)serverRequest:(NSString *)requestType withParams:(NSDictionary *)params url:(NSString *)url callback:(void(^)(NSHTTPURLResponse *, NSData *))callback;

+ (void)serverRequest:(NSString *)requestType withParams:(NSDictionary *)params url:(NSString *)url;

// Same as above method, but takes general data
+ (void)serverRequest:(NSString *)requestType withData:(NSData *)data url:(NSString *)url callback:(void(^)(NSHTTPURLResponse*, NSData *))callback;
+ (void)serverRequest:(NSString *)requestType withData:(NSData *)data url:(NSString *)url;

// dict : dictionary of parameters to use in a GET string
// returns : the GET string encoded with the parameters, starting with '?'
+ (NSString *)GETStringFromDict:(NSDictionary *)dict;

// urlString : Where to get CSRF from
// returns : the CSRF token encoded in a UTF8String
+ (void)getCSRFTokenFromURL:(NSString *)urlString withCallback:(void(^)(NSHTTPURLResponse *, NSString *, NSError *))callback;

// Container for class variables.
+ (ConnectionManager *)staticInstance;

// Manage logins and logouts
+ (void)authenticateWithUsername:(NSString *)username password:(NSString *)password;

/*** CLASS MEMBERS ***/
@property (nonatomic, copy) NSString *sessionCookie;

// For error handling
extern int error_code;

@end
