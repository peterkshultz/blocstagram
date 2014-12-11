//
//  Datasource.m
//  Blocstagram
//
//  Created by Peter Shultz on 12/1/14.
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//

#import "DataSource.h"
#import "User.h"
#import "Media.h"
#import "Comment.h"
#import "LoginViewController.h"
#import <UICKeyChainStore.h>

@interface DataSource ()
{
    NSMutableArray* _mediaItems;
}

@property (nonatomic, strong) NSMutableArray *mediaItems;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingOlderItems;
@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages;
@property (nonatomic, strong) NSString* accessToken;


@end


@implementation DataSource

+ (NSString*) instagramClientID {
    return @"e3226ebee00b416db3bec13d2eae33c3";
}

+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSString*) pathForFilename:(NSString*) filename
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths firstObject];
    NSString* dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    return dataPath;
}

- (instancetype) init
{
    self = [super init];

    if (self)
    {
        self.accessToken = [UICKeyChainStore stringForKey:@"access token"];
        
        if (!self.accessToken)
        {
            [self registerForAccessTokenNotification];
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
                NSArray *storedMediaItems = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (storedMediaItems.count > 0)
                    {
                        NSMutableArray *mutableMediaItems = [storedMediaItems mutableCopy];
                        
                        [self willChangeValueForKey:@"mediaItems"];
                        self.mediaItems = mutableMediaItems;
                        [self didChangeValueForKey:@"mediaItems"];
                    }
                    
                    else
                    {
                        [self populateDataWithParamters:nil completionHandler:nil];
                    }
                });
            });
        }
    }
    
    return self;
}

- (void) registerForAccessTokenNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification* note){
        self.accessToken = note.object;
        
        //Got a token, populate the initial data
        [self populateDataWithParamters:nil completionHandler:nil];
        
        //Save the token
        [UICKeyChainStore setString:self.accessToken forKey:@"access token"];
    }];
}

- (void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler
{
    if (self.isLoadingOlderItems == NO && self.thereAreNoMoreOlderMessages == NO)
    {
        self.isLoadingOlderItems == YES;
        
        NSString* maxID = [[self.mediaItems lastObject] idNumber];
        NSDictionary* parameters = @{@"max_id": maxID};
        
        [self populateDataWithParamters:parameters completionHandler:^(NSError *error) {
            self.isLoadingOlderItems = NO;
            
            if (completionHandler)
            {
                completionHandler(error);
            }
        }];
    }
}

- (void) populateDataWithParamters:(NSDictionary*)parameters completionHandler:(NewItemCompletionBlock)completionHandler
{
    if (self.accessToken)
    {
        //Only try and get the data if there's an access token
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
           
            //By doing the network request in the background, the UI does not lock up
            
            NSMutableString* urlString = [NSMutableString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@", self.accessToken];
            
            for (NSString* parameterName in parameters)
            {
                //If dictionary contains {count: #}, append '&count=#' to the URL
                
                [urlString appendFormat:@"&%@=%@", parameterName, parameters[parameterName]];
            }
            
            NSURL* url = [NSURL URLWithString:urlString];
            
            if (url)
            {
                NSURLRequest* request = [NSURLRequest requestWithURL:url];
                
                NSURLResponse* response;
                NSError* webError;
                NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&webError];
                
                if (responseData)
                {
                    NSError* jsonError;
                    NSDictionary* feedDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
                    
                    if (feedDictionary)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //Done networking, go back on the main thread
                            [self parseDataFromFeedDictionary:feedDictionary fromRequestWithParameters:parameters];
                            
                            if (completionHandler)
                            {
                                completionHandler(nil);
                            }
                        });
                    }
                    else if (completionHandler)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionHandler(jsonError);
                        });
                    }
                }
                
                else if (completionHandler)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(webError);
                    });
                }
            }
            
        });
    }
}

- (void) parseDataFromFeedDictionary:(NSDictionary *) feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {

    NSArray* mediaArray = feedDictionary[@"data"];
    NSMutableArray* tmpMediaItems = [NSMutableArray array];
    
    for (NSDictionary* mediaDictionary in mediaArray)
    {
        Media* mediaItem = [[Media alloc] initWithDictionary:mediaDictionary];
        
        if (mediaItem)
        {
            [tmpMediaItems addObject:mediaItem];
            [self downloadImageForMediaItem:mediaItem];
        }
    }
    
    NSMutableArray* mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    
    if (parameters[@"min_id"])
    {
        //Pull-to-refresh request
        
        NSRange rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count);
        NSIndexSet* indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
        
        [mutableArrayWithKVO insertObjects:tmpMediaItems atIndexes:indexSetOfNewObjects];
    }
    
    else if (parameters[@"max_id"])
    {
        //Infinite scroll request
        
        if (tmpMediaItems.count == 0)
        {
            self.thereAreNoMoreOlderMessages = YES;
        }
        
        [mutableArrayWithKVO addObjectsFromArray:tmpMediaItems];
    }
    
    else
    {
        [self willChangeValueForKey:@"mediaItems"];
        self.mediaItems = tmpMediaItems;
        [self didChangeValueForKey:@"mediaItems"];
    }
    

        if (tmpMediaItems.count > 0) {
            // Write the changes to disk
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSUInteger numberOfItemsToSave = MIN(self.mediaItems.count, 50);
                NSArray *mediaItemsToSave = [self.mediaItems subarrayWithRange:NSMakeRange(0, numberOfItemsToSave)];
                
                NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
                NSData *mediaItemData = [NSKeyedArchiver archivedDataWithRootObject:mediaItemsToSave];
                
                NSError *dataError;
                BOOL wroteSuccessfully = [mediaItemData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
                
                if (!wroteSuccessfully) {
                    NSLog(@"Couldn't write file: %@", dataError);
                }
            });
            
        }
    
}



- (void) downloadImageForMediaItem:(Media*)mediaItem
{
    if (mediaItem.mediaURL && !mediaItem.image)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSURLRequest* request = [NSURLRequest requestWithURL:mediaItem.mediaURL];
            
            NSURLResponse* response;
            NSError* error;
            NSData* imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if (imageData)
            {
                UIImage* image = [UIImage imageWithData:imageData];
                
                if (image)
                {
                    mediaItem.image = image;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableArray* mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                        NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                        [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                    });
                }
                
                else
                {
                    NSLog(@"Error downloading image: %@", error);
                }
            }
        });
    }
}

- (void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler
{
    self.thereAreNoMoreOlderMessages = NO;
    
    if (self.isRefreshing == NO)
    {
        self.isRefreshing == YES;
        
        NSString* minID = [[self.mediaItems firstObject] idNumber];
        
        
        NSDictionary* parameters;
        
        if (minID == nil)
        {
            parameters = nil;
        }
        else
        {
            parameters = @{@"min_id": minID};
        }
        
        
        [self populateDataWithParamters:parameters completionHandler:^(NSError* error)
         {
             self.isRefreshing = NO;
             
             if (completionHandler)
             {
                 completionHandler(error);
             }
         }];
    }
}

- (void) deleteMediaItem:(Media *)item
{
    NSMutableArray* mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    [mutableArrayWithKVO removeObject:item];
}


#pragma mark - Key/Value Observing

- (NSUInteger) countOfMediaItems
{
    return self.mediaItems.count;
}

- (id) objectInMediaItemsAtIndex:(NSUInteger)index
{
    return [self.mediaItems objectAtIndex:index];
}

- (NSArray*) mediaItemsAtIndexes:(NSIndexSet *)indexes
{
    return [self.mediaItems objectAtIndex:indexes];
}

- (void) insertObject:(Media *)object inMediaItemsAtIndex:(NSUInteger)index
{
    [_mediaItems insertObject:object atIndex:index];
}

- (void) removeObjectFromMediaItemsAtIndex:(NSUInteger)index
{
    [_mediaItems removeObjectAtIndex:index];
}

- (void) replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object
{
    [_mediaItems replaceObjectAtIndex:index withObject:object];
}

@end
