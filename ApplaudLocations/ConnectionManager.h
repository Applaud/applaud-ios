//
//  ConnectionManager.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/19/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionManager : NSObject

// requestType : either GET or POST
// params : arguments to pass to the server
// url : where to make the request to, relative to SERVER_URL
// callback : a block to call when data is received asynchronously
// returns : the server's response to the request
+ (NSData *)serverRequest:(NSString *)requestType withParams:(NSDictionary *)params url:(NSString *)url callback:(void(^)(NSData *))callback;

+ (NSData *)serverRequest:(NSString *)requestType withParams:(NSDictionary *)params url:(NSString *)url;



// dict : dictionary of parameters to use in a GET string
// returns : the GET string encoded with the parameters, starting with '?'
+ (NSString *)GETStringFromDict:(NSDictionary *)dict;

// urlString : Where to get CSRF from
// returns : the CSRF token encoded in a UTF8String
+ (NSString *)getCSRFTokenFromURL:(NSString *)urlString;

@end
