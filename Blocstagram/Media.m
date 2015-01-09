//
//  Media.m
//  Blocstagram
//
//  Created by Peter Shultz on 12/1/14.
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//


#import "User.h"
#import "Media.h"
#import "Comment.h"


@implementation Media

- (instancetype) initWithDictionary:(NSDictionary *)mediaDictionary
{
    self = [super init];
    
    if (self)
    {
        self.idNumber = mediaDictionary[@"id"];
        self.user = [[User alloc] initWithDictionary:mediaDictionary[@"user"]];
        
        //Number of likes
        
        self.numberOfLikes = [mediaDictionary[@"likes"][@"count"] integerValue];
        
//        self.numberOfLikes = [[NSNumber alloc] initWithInteger:tempNumLikes];
        
        NSLog(@"%i", self.numberOfLikes);

        
        NSString* standardResolutionImageURLString = mediaDictionary[@"images"][@"standard_resolution"][@"url"];
        NSURL* standardResolutionImageURL = [NSURL URLWithString:standardResolutionImageURLString];
        
        if (standardResolutionImageURL)
        {
            self.mediaURL = standardResolutionImageURL;
            self.downloadState = MediaDownloadStateNeedsImage;
        }
        
        else
        {
            self.downloadState = MediaDownloadStateNonRecoverableError;
        }
        
        NSDictionary* captionDictionary = mediaDictionary[@"caption"];
        
        //If there's no caption, caption will be null
        if ([captionDictionary isKindOfClass:[NSDictionary class]])
        {
            self.caption = captionDictionary[@"text"];
        }
        else
        {
            self.caption = @"";
        }
        
        NSMutableArray* commentsArray = [NSMutableArray array];
        
        for (NSDictionary* commentDictionary in mediaDictionary[@"comments"][@"data"])
        {
            Comment* comment = [[Comment alloc] initWithDictionary:commentDictionary];
        }
        
        self.comments = commentsArray;
        
        BOOL userHasLiked = [mediaDictionary[@"user_has_liked"] boolValue];
        
        self.likeState = userHasLiked ? LikeStateLiked : LikeStateNotLiked;
    }
    
    return self;
}

#pragma mark - NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self)
    {
        self.idNumber = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(idNumber))];
        self.user = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(user))];
        self.mediaURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(mediaURL))];
        self.image = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(image))];
        
        if (self.image)
        {
            self.downloadState = MediaDownloadStateHasImage;
        }
        
        else if (self.mediaURL)
        {
            self.downloadState = MediaDownloadStateNeedsImage;
        }
        
        else
        {
            self.downloadState = MediaDownloadStateNonRecoverableError;
        }

        
        self.caption = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(caption))];
        self.comments = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(comments))];
        self.likeState = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(likeState))];
        self.numberOfLikes = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(numberOfLikes))];
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.idNumber forKey:NSStringFromSelector(@selector(idNumber))];
    [aCoder encodeObject:self.user forKey:NSStringFromSelector(@selector(user))];
    [aCoder encodeObject:self.mediaURL forKey:NSStringFromSelector(@selector(mediaURL))];
    [aCoder encodeObject:self.image forKey:NSStringFromSelector(@selector(image))];
    [aCoder encodeObject:self.caption forKey:NSStringFromSelector(@selector(caption))];
    [aCoder encodeObject:self.comments forKey:NSStringFromSelector(@selector(comments))];
    [aCoder encodeInteger:self.likeState forKey:NSStringFromSelector(@selector(likeState))];
    [aCoder encodeInteger:self.numberOfLikes forKey:NSStringFromSelector(@selector(numberOfLikes))];

}

@end
