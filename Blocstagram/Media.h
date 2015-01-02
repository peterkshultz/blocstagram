//
//  Media.h
//  Blocstagram
//
//  Created by Peter Shultz on 12/1/14.
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LikeButton.h"
<<<<<<< HEAD

=======
>>>>>>> like-button

@class User;

typedef NS_ENUM(NSInteger, MediaDownloadState)
{
    MediaDownloadStateNeedsImage             = 0,
    MediaDownloadStateDownloadInProgress     = 1,
    MediaDownloadStateNonRecoverableError    = 2,
    MediaDownloadStateHasImage               = 3
};

@interface Media : NSObject <NSCoding>

@property (nonatomic, strong) NSString* idNumber;
@property (nonatomic, strong) User* user;
@property (nonatomic, strong) NSURL* mediaURL;
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, strong) NSString* caption;
@property (nonatomic, strong) NSArray* comments;
@property (nonatomic, assign) MediaDownloadState downloadState;
@property (nonatomic, assign) LikeState likeState;
<<<<<<< HEAD
@property (nonatomic, assign) NSInteger numberOfLikes;
=======
>>>>>>> like-button

- (instancetype) initWithDictionary:(NSDictionary*)mediaDictionary;

@end
