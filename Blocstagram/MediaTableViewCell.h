//
//  MediaTableViewCell.h
//  Blocstagram
//
//  Created by Peter Shultz on 12/1/14.
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media, MediaTableViewCell;

@protocol MediaTableViewCellDelegate <NSObject>

- (void) cell:(MediaTableViewCell*)cell didTapImageView:(UIImageView*)imageView;
- (void) cell:(MediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView;

@end

@interface MediaTableViewCell : UITableViewCell

@property (nonatomic, strong) Media* mediaItem;
@property (nonatomic, weak) id <MediaTableViewCellDelegate> delegate;


+ (CGFloat) heightForMediaItem:(Media*)mediaItem width:(CGFloat)width;

@end
