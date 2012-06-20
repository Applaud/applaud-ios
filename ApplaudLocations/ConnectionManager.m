//
//  ConnectionManager.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/19/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "ConnectionManager.h"

@implementation ConnectionManager

@synthesize sessionCookie = _sessionCookie;

/**
 * requestType : either GET or POST
 * params : arguments to pass to the server
 * returns : the server's response to the request
 */
+ (NSData *)serverRequest:(NSString *)requestType withData:(NSData *)data url:(NSString *)url callback:(void(^)(NSData *))callback {
    
    __block NSData *ret;
    NSString *urlPostfix = url;
    NSMutableURLRequest *request = nil;
    
    if ( [requestType isEqualToString:@"GET"] ) {
        request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, urlPostfix]]];
        [request setHTTPBody:data];
    }
    else if ( [requestType isEqualToString:@"POST"] ) {
        request = [[NSMutableURLRequest alloc] init];
        NSString *token = [ConnectionManager getCSRFTokenFromURL:[NSString stringWithFormat:@"%@%@",SERVER_URL,url]];
        
        // Put the CSRF token into the HTTP request. Kinda important.
        [request addValue:token forHTTPHeaderField:@"X-CSRFToken"];

        [request setHTTPBody:data];
        request.HTTPMethod = requestType;
        request.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, url]];
    }
    
    // Include our session cookie
    [request addValue:[self.staticInstance sessionCookie] forHTTPHeaderField:@"Cookie"];
    
    NSLog(@"Requesting from %@", [request.URL description]);
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *d, NSError *err) {
                               if(err) {
                                   [[[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                               message:[err description]
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil] show];
                                   NSLog(@"%@", err);
                               }
                               else {
                                   //                                   ret = d;
                                   //                                   NSLog(@"Just received: %@", [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding]);
                                   ret = d;
                                   if ( callback ) {
                                       callback(d);
                                   }
                                   
                               }
                           }];
    return ret;
}

+ (NSData *)serverRequest:(NSString *)requestType withData:(NSData *)data url:(NSString *)url {
    return [ConnectionManager serverRequest:requestType withData:data url:url callback:nil];
}

/**
 * requestType : either GET or POST
 * params : arguments to pass to the server
 * returns : the server's response to the request
 */
+ (NSData *)serverRequest:(NSString *)requestType withParams:(NSDictionary *)params url:(NSString *)url callback:(void(^)(NSData *))callback {
    NSData *data = nil;
    
    if ( [requestType isEqualToString:@"POST"] ) {
        data = [NSJSONSerialization dataWithJSONObject:params
                                               options:0
                                                 error:nil];
    }
    
    return [ConnectionManager serverRequest:requestType withData:data url:url callback:callback];
}

+ (NSData *)serverRequest:(NSString *)requestType withParams:(NSDictionary *)params url:(NSString *)url {
    return [ConnectionManager serverRequest:requestType withParams:params url:url callback:nil];
}

/**
 * Turns a dictionary into a GET request url format, starting with the &
 */
+ (NSString *)GETStringFromDict:(NSDictionary *)dict {
    NSMutableString *ret = [[NSMutableString alloc] initWithString:@"?"];
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [ret appendString:[NSString stringWithFormat:@"%@=%@&",key,obj]];
    }];
    return [ret substringToIndex:(ret.length-1)];
}

/*
 * Sends a GET to the server and grabs a CSRF token. I really hope this works.
 */
+ (NSString *)getCSRFTokenFromURL:(NSString *)urlString {
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLResponse *response = nil;
    NSError *err = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return html;
}

/**
 * This is used to encapsulate variables that cannot be made compile-time.
 * Tip taken from maniacdev.com/2009/07/global-variables-in-iphone-objective-c/
 */
+ (ConnectionManager *)staticInstance {
    static ConnectionManager *myInstance = nil;
    
    if ( nil == myInstance ) {
        myInstance = [[ConnectionManager alloc] init];
    }
    
    return myInstance;
}

@end
