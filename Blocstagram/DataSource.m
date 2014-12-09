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
        [self populateDataWithParamters:nil];
    }];
}

- (void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler
{
    if (self.isLoadingOlderItems == NO)
    {
        self.isLoadingOlderItems == YES;
        
        self.isLoadingOlderItems = NO;
        
        if (completionHandler)
        {
            completionHandler(nil);
        }
    }
}

- (void) populateDataWithParamters:(NSDictionary*) parameters
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
                
                NSError* jsonError;
                NSDictionary* feedDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
                
                if (feedDictionary) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // done networking, go back on the main thread
                        [self parseDataFromFeedDictionary:feedDictionary fromRequestWithParameters:parameters];
                    });
                }
            }
            
        });
    }
}

- (void) parseDataFromFeedDictionary:(NSDictionary *) feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    NSLog(@"%@", feedDictionary);
}

- (void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler
{
    if (self.isRefreshing == NO)
    {
        self.isRefreshing == YES;
        
        
        if (completionHandler)
        {
            completionHandler(nil);
        }
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
