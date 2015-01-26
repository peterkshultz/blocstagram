//
//  FilterCollectionViewCell.m
//  Blocstagram
//
//  Created by Peter Shultz on 1/22/15.
//  Copyright (c) 2015 Peter Shultz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetsLibrary/AssetsLibrary.h"
#import "FilterCollectionViewCell.h"

@interface FilterCollectionViewCell ()

@property (nonatomic, strong) UIImage* thumbnail;
@property (nonatomic, strong) UIImageView* thumbnailImageView;
@property (nonatomic, strong) UILabel* title;

@end

/*

Notes:
 
 I figure we need to populate the data cell, so I took the code that I thought was necessary from PostToInstagramViewController.m
 to achieve this (code regarding layout). I don't think we need the filters--we can just refer to that from PostToInstagramViewController.m
 
 We also need a way to connect FilterCollectionViewCell to PostInstagramViewController.m, that way FilterCollectionViewCell achieves
 the purpose it is supposed to.
 
 All the errors that I have here come from the fact that the properties are not declared. Should we work with the properties I already declared?
 
 Note: I haven't deleted anything here
 
*/
@implementation FilterCollectionViewCell


//-(instancetype) initwithFlow

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        static NSInteger imageViewTag = 1000;
        static NSInteger labelTag = 1001;
        
        UIImageView *thumbnail = (UIImageView *)[self.contentView viewWithTag:imageViewTag];
        UILabel *label = (UILabel *)[self.contentView viewWithTag:labelTag];
        
        CGFloat thumbnailEdgeSize = self.frame.size.width;
        
        if (!thumbnail)
        {
            thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbnailEdgeSize, thumbnailEdgeSize)];
            thumbnail.contentMode = UIViewContentModeScaleAspectFill;
            thumbnail.tag = imageViewTag;
            thumbnail.clipsToBounds = YES;
            
            [self.contentView addSubview:thumbnail];
        }
        
        if (!label)
        {
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, thumbnailEdgeSize, thumbnailEdgeSize, 20)];
            label.tag = labelTag;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
            [self.contentView addSubview:label];
        }
        
    }
    
    return self;
}



@end
