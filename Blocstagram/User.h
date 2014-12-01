//
//  User.h
//  Blocstagram
//
//  Created by Peter Shultz on 12/1/14.
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface User : NSObject

@property (nonatomic, strong) NSString* idNumber;
@property (nonatomic, strong) NSString* userName;
@property (nonatomic, strong) NSString* fullName;
@property (nonatomic, strong) NSURL* profilePictureURL;
@property (nonatomic, strong) UIImage* profilePicture;

@end
