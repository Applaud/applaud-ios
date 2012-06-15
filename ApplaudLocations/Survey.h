//
//  Survey.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/15/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SurveyField.h"

@interface Survey : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, strong) NSMutableArray *fields;
-(id)initWithTitle:(NSString *)title summary:(NSString *)summary fields:(NSMutableArray *)fields;
@end
