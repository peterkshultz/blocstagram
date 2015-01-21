//
//  CropBox.m
//  Blocstagram
//
//  Created by Peter Shultz on 1/14/15.
//  Copyright (c) 2015 Peter Shultz. All rights reserved.
//

#import "CropBox.h"

@interface CropBox ()

@property (nonatomic, strong) NSArray *horizontalLines;
@property (nonatomic, strong) NSArray *verticalLines;

@property (nonatomic, strong) UIToolbar* topView;
@property (nonatomic, strong) UIToolbar* bottomView;

@end

@implementation CropBox


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.userInteractionEnabled = NO;
        
        // Initialization code
        
        self.topView = [UIToolbar new];
        self.bottomView = [UIToolbar new];
        
        UIColor* whiteBG = [UIColor colorWithWhite:1.0 alpha:.15];
        
        self.topView.barTintColor = whiteBG;
        self.bottomView.barTintColor = whiteBG;
        self.topView.alpha = 0.5;
        self.bottomView.alpha = 0.5;
        
        NSArray *lines = [self.horizontalLines arrayByAddingObjectsFromArray:self.verticalLines];
        NSMutableArray *subviews = [NSMutableArray arrayWithArray:lines];
        [subviews addObject:self.topView];
        [subviews addObject:self.bottomView];

        
        
        for (UIView *view in subviews)
        {
            [self addSubview:view];
        }
        
        
    }
    return self;
}

- (NSArray *) horizontalLines
{
    if (!_horizontalLines)
    {
        _horizontalLines = [self newArrayOfFourWhiteViews];
    }
    
    return _horizontalLines;
}

- (NSArray *) verticalLines
{
    if (!_verticalLines)
    {
        _verticalLines = [self newArrayOfFourWhiteViews];
    }
    
    return _verticalLines;
}

- (NSArray *) newArrayOfFourWhiteViews
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < 4; i++)
    {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        [array addObject:view];
    }
    
    return array;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
//    CGFloat width = CGRectGetWidth(self.view.bounds);
//    self.topView.frame = CGRectMake(0, self.topLayoutGuide.length, width, 44);
//    
//    CGFloat yOriginOfBottomView = CGRectGetMaxY(self.topView.frame) + width;
//    CGFloat heightOfBottomView = CGRectGetHeight(self.view.frame) - yOriginOfBottomView;
//    self.bottomView.frame = CGRectMake(0, yOriginOfBottomView, width, heightOfBottomView);
//    
//    self.cropBox.frame = CGRectMake(0, CGRectGetMaxY(self.topView.frame), width, width);

    CGFloat width = CGRectGetWidth(self.frame);

    CGFloat topViewHeight = 44;
    
    self.topView.frame = CGRectMake(0, 0, width, topViewHeight);
    
    CGFloat thirdOfWidth = width / 3;
    
    for (int i = 0; i < 4; i++)
    {
        UIView *horizontalLine = self.horizontalLines[i];
        UIView *verticalLine = self.verticalLines[i];
        
        horizontalLine.frame = CGRectMake(0, (i * thirdOfWidth) + topViewHeight, width, 0.5);
        
        CGRect verticalFrame = CGRectMake(i * thirdOfWidth, topViewHeight, 0.5, width);
        
        if (i == 3)
        {
            verticalFrame.origin.x -= 0.5;
        }
        
        verticalLine.frame = verticalFrame;
    }
    
    self.bottomView.frame = CGRectMake(0, topViewHeight + width, width, self.frame.size.height - topViewHeight - width);
}

@end
