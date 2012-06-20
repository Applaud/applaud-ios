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
@property (nonatomic) int business_id;
@property (nonatomic, strong) NSMutableArray *fields;
@property (nonatomic, strong) NSMutableArray *answers;
-(id)initWithTitle:(NSString *)title summary:(NSString *)summary business_id:(int)business_id fields:(NSMutableArray *)fields;
@end
