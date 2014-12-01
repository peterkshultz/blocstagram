//
//  Datasource.h
//  Blocstagram
//
//  Created by Peter Shultz on 12/1/14.
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataSource : NSObject

+(instancetype) sharedInstance;

@property (nonatomic, strong, readonly) NSMutableArray *mediaItems;

@end
