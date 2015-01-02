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
#import <AFNetworking/AFNetworking.h>

@interface DataSource ()
{
    NSMutableArray* _mediaItems;
}

@property (nonatomic, strong) NSMutableArray *mediaItems;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingOlderItems;
@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages;
@property (nonatomic, strong) NSString* accessToken;

@property (nonatomic, strong) AFHTTPRequestOperationManager *instagramOperationManager;

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

#pragma mark - Liking Media Items

- (void) toggleLikeOnMediaItem:(Media *)mediaItem
{
    NSString *urlString = [NSString stringWithFormat:@"media/%@/likes", mediaItem.idNumber];
    NSDictionary *parameters = @{@"access_token": self.accessToken};
    
    if (mediaItem.likeState == LikeStateNotLiked)
    {
        
        mediaItem.likeState = LikeStateLiking;
        
        [self.instagramOperationManager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            mediaItem.likeState = LikeStateLiked;
            [self reloadMediaItem:mediaItem];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            mediaItem.likeState = LikeStateNotLiked;
            [self reloadMediaItem:mediaItem];
        }];
        
    }
    
    else if (mediaItem.likeState == LikeStateLiked)
    {
        
        mediaItem.likeState = LikeStateUnliking;
        
        [self.instagramOperationManager DELETE:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            mediaItem.likeState = LikeStateNotLiked;
            [self reloadMediaItem:mediaItem];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            mediaItem.likeState = LikeStateLiked;
            [self reloadMediaItem:mediaItem];
        }];
        
    }
    
    [self reloadMediaItem:mediaItem];
}

- (void) reloadMediaItem:(Media *)mediaItem
{
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
    [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
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
        NSURL *baseURL = [NSURL URLWithString:@"https://api.instagram.com/v1/"];
        self.instagramOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        
        AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
        
        AFImageResponseSerializer *imageSerializer = [AFImageResponseSerializer serializer];
        imageSerializer.imageScale = 1.0;
        
        AFCompoundResponseSerializer *serializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonSerializer, imageSerializer]];
        self.instagramOperationManager.responseSerializer = serializer;
        
        
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
                        
                        [self requestNewItemsWithCompletionHandler:^(NSError *error) {
                            
                        }];
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
  
        NSMutableDictionary *mutableParameters = [@{@"access_token": self.accessToken} mutableCopy];
        
        [mutableParameters addEntriesFromDictionary:parameters];
        
        [self.instagramOperationManager GET:@"users/self/feed"
                                 parameters:mutableParameters
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([responseObject isKindOfClass:[NSDictionary class]])
                                        {
                                            [self parseDataFromFeedDictionary:responseObject fromRequestWithParameters:parameters];
                                            
                                            if (completionHandler)
                                            {
                                                completionHandler(nil);
                                            }
                                        }
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        if (completionHandler)
                                        {
                                            completionHandler(error);
                                        }
                                    }];
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
//            [self downloadImageForMediaItem:mediaItem];
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
            
            [self saveToDisk];
        }
    
}

- (void) saveToDisk{
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



- (void) downloadImageForMediaItem:(Media*)mediaItem
{
    if (mediaItem.mediaURL && !mediaItem.image)
    {
        mediaItem.downloadState = MediaDownloadStateDownloadInProgress;
        
        [self.instagramOperationManager GET:mediaItem.mediaURL.absoluteString
                                 parameters:nil
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([responseObject isKindOfClass:[UIImage class]])
                                        {
                                            mediaItem.image = responseObject;
                                            
                                            mediaItem.downloadState = MediaDownloadStateHasImage;
                                            
                                            NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                                            
                                            NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                                            
                                            [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                                        }
                                        
                                        else
                                        {
                                            mediaItem.downloadState = MediaDownloadStateNonRecoverableError;
                                        }
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"Error downloading image: %@", error);
                                        
                                        mediaItem.downloadState = MediaDownloadStateNonRecoverableError;
                                        
                                        if ([error.domain isEqualToString:NSURLErrorDomain])
                                        {
                                            // A networking problem
                                            if (error.code == NSURLErrorTimedOut ||
                                                error.code == NSURLErrorCancelled ||
                                                error.code == NSURLErrorCannotConnectToHost ||
                                                error.code == NSURLErrorNetworkConnectionLost ||
                                                error.code == NSURLErrorNotConnectedToInternet ||
                                                error.code == kCFURLErrorInternationalRoamingOff ||
                                                error.code == kCFURLErrorCallIsActive ||
                                                error.code == kCFURLErrorDataNotAllowed ||
                                                error.code == kCFURLErrorRequestBodyStreamExhausted)
                                            {
                                                
                                                // It might work if we try again
                                                mediaItem.downloadState = MediaDownloadStateNeedsImage;
                                            }
                                        }
                                    }];
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
    
    
    [self saveToDisk];
}

#pragma mark - Liking Media Items

- (void) toggleLikeOnMediaItem:(Media *)mediaItem
{
    NSString *urlString = [NSString stringWithFormat:@"media/%@/likes", mediaItem.idNumber];
    NSDictionary *parameters = @{@"access_token": self.accessToken};
    
    if (mediaItem.likeState == LikeStateNotLiked)
    {
        
        mediaItem.likeState = LikeStateLiking;
        
        [self.instagramOperationManager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary * dict = (NSDictionary*)responseObject;
            NSLog(@"%@", dict.description);
            mediaItem.likeState = LikeStateLiked;
            mediaItem.numberOfLikes++;
            [self reloadMediaItem:mediaItem];
            [self saveToDisk];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
            mediaItem.likeState = LikeStateNotLiked;
            [self reloadMediaItem:mediaItem];
        }];
        
    }
    
    else if (mediaItem.likeState == LikeStateLiked)
    {
        
        mediaItem.likeState = LikeStateUnliking;
        
        [self.instagramOperationManager DELETE:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            mediaItem.likeState = LikeStateNotLiked;
            mediaItem.numberOfLikes--;
            [self reloadMediaItem:mediaItem];
            [self saveToDisk];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            mediaItem.likeState = LikeStateLiked;
            [self reloadMediaItem:mediaItem];
        }];
        
    }
    
    [self reloadMediaItem:mediaItem];
}

- (void) reloadMediaItem:(Media *)mediaItem
{
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
    [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
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
