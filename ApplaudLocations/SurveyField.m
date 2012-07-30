//
//  SurveyField.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/15/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "SurveyField.h"

@implementation SurveyField

-(id)initWithLabel:(NSString *)label id:(int)id type:(QuestionType)type options:(NSMutableArray *)options {
  if(self = [super init]) {
	_label = label;
	_id = id;
	_type = type;
	_options = options;
  }
  return self;
}

-(NSString *) description {
    return self.label;
}
@end
