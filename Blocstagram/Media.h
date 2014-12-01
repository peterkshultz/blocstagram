//
//  Media.h
//  Blocstagram
//
//  Created by Peter Shultz on 12/1/14.
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class User;

@interface Media : NSObject

@property (nonatomic, strong) NSString* idNumber;
@property (nonatomic, strong) User* user;
@property (nonatomic, strong) NSURL* mediaURL;
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, strong) NSString* caption;
@property (nonatomic, strong) NSArray* comments;

@end
