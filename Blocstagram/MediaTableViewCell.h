//
//  MediaTableViewCell.h
//  Blocstagram
//
//  Created by Peter Shultz on 12/1/14.
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;

@interface MediaTableViewCell : UITableViewCell

@property (nonatomic, strong) Media* mediaItem;

+ (CGFloat) heightForMediaItem:(Media*)mediaItem width:(CGFloat)width;

@end
