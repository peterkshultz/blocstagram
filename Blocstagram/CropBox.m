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

    //Changes made thus far: self.bottomView.frame now has a y-value of (2 * topViewHeight) + width
    //Now fairly certain that isn't going to work--just realized what frame was.
    
    //Changes that need to be made: Double topViewHeight from 44 to 88 while making sure the cropBox doesn't change its position
    
    CGFloat width = CGRectGetWidth(self.frame);
    
    CGFloat topOfLineY = CGRectGetHeight(self.frame)/2-width/2;
    

    CGFloat thirdOfWidth = width / 3;
    
    for (int i = 0; i < 4; i++)
    {
        UIView *horizontalLine = self.horizontalLines[i];
        UIView *verticalLine = self.verticalLines[i];
        
        horizontalLine.frame = CGRectMake(0, (i * thirdOfWidth) + topOfLineY, width, 0.5);
        
        CGRect verticalFrame = CGRectMake(i * thirdOfWidth, topOfLineY, 0.5, width);
        
        if (i == 3)
        {
            verticalFrame.origin.x -= 0.5;
        }
        
        verticalLine.frame = verticalFrame;
    }
    
//    CGFloat topViewHeight = 44;
    
    self.topView.frame = CGRectMake(0, 0, width, topOfLineY);
    
    
    
//    CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
    
    self.bottomView.frame = CGRectMake(0, topOfLineY + width, width, self.frame.size.height - topOfLineY - width);
}

@end
