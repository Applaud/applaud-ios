//
//  ApplaudProgramStateModel.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/18/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ApplaudProgramSettingsModel : NSManagedObject

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic) BOOL firstTimeLaunching;

@end
