//
//  LikeButton.h
//  Blocstagram
//
<<<<<<< HEAD
//  Created by Peter Shultz on 12/30/14.
=======
//  Created by Peter Shultz on 12/27/14.
>>>>>>> like-button
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LikeState)
{
    LikeStateNotLiked             = 0,
    LikeStateLiking               = 1,
    LikeStateLiked                = 2,
    LikeStateUnliking             = 3
};

@interface LikeButton : UIButton

/**
<<<<<<< HEAD
 The current state of the like button. Setting to BLCLikeButtonNotLiked or BLCLikeButtonLiked will display an empty heart or a heart, respectively. Setting to BLCLikeButtonLiking or BLCLikeButtonUnliking will display an activity indicator and disable button taps until the button is set to BLCLikeButtonNotLiked or BLCLikeButtonLiked.
=======
 The current state of the like button. Setting to LikeButtonNotLiked or LikeButtonLiked will display an empty heart or a heart, respectively. Setting to LikeButtonLiking or LikeButtonUnliking will display an activity indicator and disable button taps until the button is set to LikeButtonNotLiked or LikeButtonLiked.
>>>>>>> like-button
 */
@property (nonatomic, assign) LikeState likeButtonState;

@end
<<<<<<< HEAD

=======
>>>>>>> like-button
