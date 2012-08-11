//
//  ApatapaDateFormatter.m
//  ApplaudIOS
//
//  Provides an easy way to get human-readable time strings like "Yesterday", "3 hours ago", etc.
//  from NSDates.
//
//  Created by Luke Lovett on 8/10/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "ApatapaDateFormatter.h"

@implementation ApatapaDateFormatter

+ (NSString*)stringFromDate:(NSDate*)date {
    // We assume that date is currently in UTC
    
    int seconds = -(int)([[NSTimeZone systemTimeZone] secondsFromGMT] + [date timeIntervalSinceNow]);
    
    int minutes, hours, days, weeks, months, years;
    NSString *unit = nil;
    int result;
    years = seconds / 31557600;
    months = seconds / 2620633;
    weeks = seconds / 604800;
    days = seconds / 86400;
    hours = seconds / 3600;
    minutes = seconds / 60;
    
    if ( years ) {
        result = years;
        unit = @"year";
    } else if ( months ) {
        result = months;
        unit = @"month";
    } else if ( weeks ) {
        result = weeks;
        unit = @"week";
    } else if ( days ) {
        result = days;
        unit = @"day";
    } else if ( hours ) {
        result = hours;
        unit = @"hour";
    } else if ( minutes ) {
        result = minutes;
        unit = @"minute";
    } else {
        result = seconds;
        unit = @"second";
    }
    
    NSString *suffix = (result == 1? @"" : @"s");
    return [NSString stringWithFormat:@"%d %@%@ ago", result, unit, suffix];
}

@end
