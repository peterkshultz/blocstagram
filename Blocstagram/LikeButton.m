//
//  LikeButton.m
//  Blocstagram
//
<<<<<<< HEAD
//  Created by Peter Shultz on 12/30/14.
=======
//  Created by Peter Shultz on 12/27/14.
>>>>>>> like-button
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//

#import "LikeButton.h"
#import "CircleSpinnerView.h"

#define kLikedStateImage @"heart-full"
#define kUnlikedStateImage @"heart-empty"

@interface LikeButton ()

@property (nonatomic, strong) CircleSpinnerView *spinnerView;

@end

<<<<<<< HEAD

@implementation LikeButton

=======
@implementation LikeButton

- (void) layoutSubviews
{
    [super layoutSubviews];
    self.spinnerView.frame = self.imageView.frame;
}

- (instancetype) init
{
    self = [super init];
    
    if (self)
    {
        self.spinnerView = [[CircleSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [self addSubview:self.spinnerView];
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        
        self.likeButtonState = LikeStateNotLiked;
    }
    
    return self;
}

>>>>>>> like-button
- (void) setLikeButtonState:(LikeState)likeState
{
    _likeButtonState = likeState;
    
<<<<<<< HEAD
=======
    
>>>>>>> like-button
    NSString *imageName;
    
    switch (_likeButtonState)
    {
        case LikeStateLiked:
        case LikeStateUnliking:
            imageName = kLikedStateImage;
            break;
            
        case LikeStateNotLiked:
        case LikeStateLiking:
            imageName = kUnlikedStateImage;
    }
    
    switch (_likeButtonState)
    {
        case LikeStateLiking:
        case LikeStateUnliking:
            self.spinnerView.hidden = NO;
            self.userInteractionEnabled = NO;
            break;
            
        case LikeStateLiked:
        case LikeStateNotLiked:
            self.spinnerView.hidden = YES;
            self.userInteractionEnabled = YES;
    }
    
    
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

<<<<<<< HEAD
- (void) layoutSubviews
{
    [super layoutSubviews];
    self.spinnerView.frame = self.imageView.frame;
}

- (instancetype) init
{
    self = [super init];
    
    if (self)
    {
        self.spinnerView = [[CircleSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [self addSubview:self.spinnerView];
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        
        self.likeButtonState = LikeStateNotLiked;
    }
    
    return self;
}

=======
>>>>>>> like-button

@end
