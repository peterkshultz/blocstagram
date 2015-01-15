//
//  UIImage+ImageUtilities.h
//  Blocstagram
//
//  Created by Peter Shultz on 1/14/15.
//  Copyright (c) 2015 Peter Shultz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageUtilities)

- (UIImage *) imageByScalingToSize:(CGSize)size andCroppingWithRect:(CGRect)rect;
- (UIImage*) imageWithFixedOrientation;
- (UIImage*) imageResizedToMatchAspectRatioOfSize:(CGSize)size;
- (UIImage*) imageCroppedToRect:(CGRect)cropRect;

@end
