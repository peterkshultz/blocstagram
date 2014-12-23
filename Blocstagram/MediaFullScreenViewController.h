//
//  MediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Peter Shultz on 12/23/14.
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;

@interface MediaFullScreenViewController : UIViewController

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

- (instancetype) initWithMedia:(Media *)media;

- (void) centerScrollView;

//+ (void) mediaItem:(Media *)mediaItem withVC: (UIViewController*) vc;

@end
