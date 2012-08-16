//
//  ConnectionManager.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/19/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "ConnectionManager.h"
#import "ErrorViewController.h"
#import <CoreData/CoreData.h>

@implementation ConnectionManager

// Keeps track of outbound connections
static int outbound_connections;

+ (void)makeRequest:(NSURLRequest*)request callback:(void(^)(NSHTTPURLResponse *, NSData *))callback {
    // Display network activity indicator if we are going from 0 --> >0 connections
    if ( outbound_connections == 0 ) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    outbound_connections++;
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *err) {
                               NSHTTPURLResponse *r = (NSHTTPURLResponse *)response;

                               // Decrement # of connections
                               outbound_connections--;
                               // No more connections --> stop showing network activity indicator
                               if ( outbound_connections == 0 ) {
                                   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                   
                                   if (! err) {
                                       // Let interested bodies know that all network comm. is finished.
                                       [[NSNotificationCenter defaultCenter] postNotificationName:@"DOWNLOAD_FINISHED" object:nil];
                                   }
                               }
                               
                               if(err) {
                                   error_code = ERROR_NO_CONNECTION;
                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"FATAL_ERROR" object:nil];
                                   
                                   NSLog(@"%@", err);
                               }
                               else {
                                   if ( r.statusCode == 500 ) {
                                       NSLog(@"========== SERVER ERROR ===========\n --> %@ <--",
                                             [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                       error_code = ERROR_SERVER_ERROR;
                                   }
                                   
                                   if ( callback ) {
                                       callback(r, data);
                                   }
                               }
                           }];

}

/**
 * requestType : either GET or POST
 * params : arguments to pass to the server
 * returns : the server's response to the request
 */
+ (void)serverRequest:(NSString *)requestType withData:(NSData *)data url:(NSString *)url callback:(void(^)(NSHTTPURLResponse *, NSData *))callback {
    
    // Keeps track of how many connections we have
    outbound_connections = 0;
    
    NSString *urlPostfix = url;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    // Set timeout to 10 seconds
    request.timeoutInterval = 10.0;
    
    __block NSString *cookieString = [[ConnectionManager staticInstance] sessionCookie];
    
    if ( [requestType isEqualToString:@"GET"] ) {
        request.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, urlPostfix]];
        NSLog(@"Requesting from URL (GET): %@",[NSString stringWithFormat:@"%@%@",SERVER_URL,urlPostfix]);
        [request setHTTPBody:data];
        [request addValue:cookieString forHTTPHeaderField:@"Cookie"];
        [ConnectionManager makeRequest:request callback:callback];
    }
    else if ( [requestType isEqualToString:@"POST"] ) {
        [ConnectionManager getCSRFTokenFromURL:url
                                  withCallback:^(NSHTTPURLResponse *r, NSString *csrf, NSError *e) {
                                      // Put the CSRF token into the HTTP request. Kinda important.
                                      NSLog(@"Here, the data is....%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding ]);
                                      [request setHTTPBody:data];
                                      NSLog(@"The url is....%@", url);
                                      request.HTTPMethod = requestType;
                                      request.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, url]];
                                      cookieString = [NSString stringWithFormat:@"csrftoken=%@; %@", csrf, cookieString];
                                      [request addValue:cookieString forHTTPHeaderField:@"Cookie"];
                                      [request addValue:csrf forHTTPHeaderField:@"X-CSRFToken"];
                                      [request addValue:SERVER_URL forHTTPHeaderField:@"Referer"];
                                      NSLog(@"Requesting from URL (POST): %@",request.URL.absoluteString);
                                      [ConnectionManager makeRequest:request callback:callback];
                                  }];
    }
}

+ (void)serverRequest:(NSString *)requestType withData:(NSData *)data url:(NSString *)url {
    return [ConnectionManager serverRequest:requestType withData:data url:url callback:nil];
}

/**
 * requestType : either GET or POST
 * params : arguments to pass to the server
 * returns : the server's response to the request
 */
+ (void)serverRequest:(NSString *)requestType withParams:(NSDictionary *)params url:(NSString *)url callback:(void(^)(NSHTTPURLResponse *, NSData *))callback {
    NSData *data = nil;
    if ( [requestType isEqualToString:@"POST"] ) {
        data = [NSJSONSerialization dataWithJSONObject:params
                                               options:0
                                                 error:nil];
    }
    else if ( [requestType isEqualToString:@"GET"] ) {
        NSString *dictAsString = [self GETStringFromDict:params];
        url = [[NSString alloc] initWithFormat:@"%@%@", url,dictAsString];
    }
    [ConnectionManager serverRequest:requestType withData:data url:url callback:callback];
}

+ (void)serverRequest:(NSString *)requestType withParams:(NSDictionary *)params url:(NSString *)url {
    [ConnectionManager serverRequest:requestType withParams:params url:url callback:nil];
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
+ (void)getCSRFTokenFromURL:(NSString *)urlString withCallback:(void(^)(NSHTTPURLResponse *, NSString *, NSError *))callback {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, urlString]]];
    NSLog(@"CSRF token from url: %@", request.URL.absoluteString);
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
                               NSString *csrf = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
                               NSLog(@"CSRF: %@",csrf);
                               callback((NSHTTPURLResponse*)r,csrf,e);
                           }];
}

/**
 * logins and logouts
 */
+ (void)authenticateWithUsername:(NSString *)username password:(NSString *)password {
    outbound_connections = 0;
    
    NSString *postString = [NSString stringWithFormat:@"username=%@&password=%@", username, password];
    
    __block NSString *cookieString = nil;

    // Display network activity indicator if we are going from 0 --> >0 connections
    if ( outbound_connections == 0 ) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    outbound_connections++;
    
    [ConnectionManager serverRequest:@"POST"
                            withData:[NSData dataWithBytes:[postString UTF8String] length:postString.length]
                                 url:LOGIN_URL
                            callback:^(NSHTTPURLResponse *r, NSData *d) {
                                
                                // We are ok, login was successful
                                if ( r.statusCode == 200 && [r.allHeaderFields objectForKey:@"Set-Cookie"] != nil) {
                                    // If not a location manager error, reset error code
                                    if( error_code != ERROR_NO_LOCATION)
                                        error_code = 0;
                                    
                                    NSArray *userPassword = [NSArray arrayWithObjects:username, password, nil];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGIN_SUCCESS" object:userPassword];
                                    NSLog(@"All headers of the response: %@", r.allHeaderFields);
                                    NSError *regexError = nil;
                                    cookieString = [r.allHeaderFields objectForKey:@"Set-Cookie"];
                                    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"sessionid=[a-f0-9]+;"
                                                                                                           options:0
                                                                                                             error:&regexError];
                                    NSLog(@"This is the status code: %d", r.statusCode);
                                    NSLog(@"This is the cookie string's length: %d and this is the string: %@", cookieString.length, cookieString);
                                    NSRange regexRange = [regex rangeOfFirstMatchInString:cookieString
                                                                                  options:0
                                                                                    range:NSMakeRange(0, cookieString.length)];
                                    // Finds the sessionID in the cookie string
                                    cookieString = [cookieString substringWithRange:regexRange];
                                    [[ConnectionManager staticInstance] setSessionCookie:cookieString];
                                    NSLog(@"%@", cookieString);
                                }
                                // Login did not succeed (could not connect to server, bad username/password combo)
                                else {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGIN_FAILURE" object:nil];
                                }
                                
                                outbound_connections--;
                                // No more connections --> stop showing network activity indicator
                                if ( outbound_connections == 0 ) {
                                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                }
                            }];
}

/*
 * Simplifies posting a photo to the server.
 * photo is a UIImage *.
 * params are a dictionary which will be sent along as form fields. All
 * keys and values should be strings.
 * On the Django side, expect all params in request.POST and the image in
 * request.FILES.
 */
+ (void)postPhoto:(UIImage *)image withParams:(NSDictionary *)params
         callback:(void(^)(NSHTTPURLResponse *, NSData *))callback
            toURL:(NSString *)url{
    NSMutableData *body = [[NSMutableData alloc] init];
    NSData *start = [[NSString stringWithFormat:@"--%@\r\n", FORM_BOUNDARY]
                     dataUsingEncoding:NSUTF8StringEncoding];
    // Add parameters.
    for (NSString *param in params) {
        [body appendData:start];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    // The image.
    [body appendData:start];
    [body appendData:[@"Content-Disposition: file; name=\"image\"; filename=\"image.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:UIImageJPEGRepresentation(image, 1)];
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", FORM_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Make the request.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.timeoutInterval = 30;
    request.HTTPMethod = @"POST";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", FORM_BOUNDARY];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
    request.HTTPBody = body;
    request.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, url]];
    
    // Get the CSRF token.
    [ConnectionManager getCSRFTokenFromURL:url withCallback:^(NSHTTPURLResponse *r, NSString *csrf, NSError *e) {
        [request addValue:csrf forHTTPHeaderField:@"X-CSRFToken"];
        [ConnectionManager makeRequest:request callback:callback];
    }];
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
