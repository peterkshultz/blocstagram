//
//  CameraViewController.h
//  Blocstagram
//
//  Created by Peter Shultz on 1/13/15.
//  Copyright (c) 2015 Peter Shultz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraViewController;

@protocol CameraViewControllerDelegate <NSObject>

- (void) cameraViewController:(CameraViewController*)cameraViewController didCompleteWithImage:(UIImage*)image;

@end


@interface CameraViewController : UIViewController

@property (nonatomic, weak) NSObject <CameraViewControllerDelegate>* delegate;

@end
