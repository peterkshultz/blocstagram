//
//  Comment.h
//  Blocstagram
//
//  Created by Peter Shultz on 12/1/14.
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class User;

@interface Comment : NSObject

@property (nonatomic, strong) NSString* idNumber;
@property (nonatomic, strong) User* from;
@property (nonatomic, strong) NSString* text;

@end
