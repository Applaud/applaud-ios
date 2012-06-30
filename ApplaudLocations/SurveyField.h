//
//  SurveyField.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/15/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TEXTFIELD,
    TEXTAREA,
    RADIO,
    CHECKBOX
} QuestionType;

@interface SurveyField : NSObject
@property (nonatomic, copy) NSString *label;
@property (nonatomic) BOOL required;
@property (nonatomic) int id;
@property (nonatomic) QuestionType type;
@property (nonatomic, strong) NSMutableArray *options;
-(id)initWithLabel:(NSString *)label required:(BOOL)required id:(int)id type:(QuestionType)type options:(NSMutableArray *)options;
@end
