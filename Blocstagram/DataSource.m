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

- (instancetype) init
{
    self = [super init];

    if (self)
    {
        [self registerForAccessTokenNotification];
    }
    
    return self;
}

- (void) registerForAccessTokenNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification* note){
        self.accessToken = note.object;
        
        //Got a token, populate the initial data
        [self populateDataWithParamters:nil completionHandler:nil];
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
        else{
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
