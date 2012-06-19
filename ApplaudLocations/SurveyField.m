//
//  SurveyField.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/15/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "SurveyField.h"

@implementation SurveyField
@synthesize label = _label;
@synthesize required = _required;
@synthesize id = _id;
@synthesize type = _type;
@synthesize options = _options;

-(id)initWithLabel:(NSString *)label required:(BOOL)required id:(int)id type:(QuestionType)type options:(NSMutableArray *)options {
  if(self = [super init]) {
	_label = label;
	_required = required;
	_id = id;
	_type = type;
	_options = options;
  }
  return self;
}
@end