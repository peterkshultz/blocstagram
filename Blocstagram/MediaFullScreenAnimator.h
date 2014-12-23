//
//  MediaFullScreenAnimator.h
//  Blocstagram
//
//  Created by Peter Shultz on 12/23/14.
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaFullScreenAnimator: NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting;
@property (nonatomic, weak) UIImageView *cellImageView;

@end
