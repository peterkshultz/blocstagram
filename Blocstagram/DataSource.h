//
//  Datasource.h
//  Blocstagram
//
//  Created by Peter Shultz on 12/1/14.
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Media;

typedef void (^NewItemCompletionBlock)(NSError* error);

@interface DataSource : NSObject

extern NSString* const ImageFinishedNotification;

+(instancetype) sharedInstance;
+(NSString*) instagramClientID;

@property (nonatomic, strong, readonly) NSMutableArray *mediaItems;
@property (nonatomic, strong, readonly) NSString* accessToken;

- (void) deleteMediaItem:(Media*)item;

- (void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;
- (void) requestOldItemsWithCompletionHandler: (NewItemCompletionBlock)completionHandler;
- (void) downloadImageForMediaItem:(Media*)mediaItem;
- (void) toggleLikeOnMediaItem:(Media *)mediaItem;
- (void) downloadImageForMediaItem:(Media*)mediaItem;
- (void) commentOnMediaItem:(Media *)mediaItem withCommentText:(NSString *)commentText;


@end
