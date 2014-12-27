//
//  CircleSpinnerView.h
//  Blocstagram
//
//  Created by Peter Shultz on 12/26/14.
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleSpinnerView : UIView

@property (nonatomic, assign) CGFloat strokeThickness;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, strong) UIColor *strokeColor;

@end
