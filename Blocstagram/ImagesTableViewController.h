//
//  ImagesTableViewController.h
//  Blocstagram
//
//  Created by Peter Shultz on 11/30/14.
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Media.h"

@interface ImagesTableViewController : UITableViewController
@property (nonatomic, strong) NSMutableArray* images;

+ (void) mediaItem:(Media *)mediaItem withVC: (UIViewController*) vc;

@end
