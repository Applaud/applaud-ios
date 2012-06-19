//
//  ConnectionManager.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/19/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "ConnectionManager.h"

@implementation ConnectionManager


/**
 * requestType : either GET or POST
 * params : arguments to pass to the server
 * returns : the server's response to the request
 */
+ (NSData *)serverRequest:(NSString *)requestType withParams:(NSDictionary *)params url:(NSString *)url callback:(void(^)(NSData *))callback {
    
    __block NSData *ret;
    NSData *sendData = [[NSData alloc] init];
    NSString *urlPostfix = url;
    NSMutableURLRequest *request = nil;

    if ( [requestType isEqualToString:@"GET"] ) {
        if ( nil != params && params.count > 0 )
            urlPostfix = [NSString stringWithFormat:@"%@%@",urlPostfix,[ConnectionManager GETStringFromDict:params]];
        request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, urlPostfix]]];
        
    }
    else if ( [requestType isEqualToString:@"POST"] ) {
        request = [[NSMutableURLRequest alloc] init];
        sendData = [NSJSONSerialization dataWithJSONObject:params
                                                   options:0
                                                     error:nil];
        NSString *token = [ConnectionManager getCSRFTokenFromURL:[NSString stringWithFormat:@"%@%@",SERVER_URL,url]];
        
        // Put the CSRF token into the HTTP request. Kinda important.
        [request addValue:token forHTTPHeaderField:@"X-CSRFToken"]; 
        request.HTTPBody = sendData;
        request.HTTPMethod = requestType;
        request.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, url]];
    }


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


@end
