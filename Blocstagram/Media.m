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
        NSString* standardResolutionImageURLString = mediaDictionary[@"images"][@"standard_resolution"][@"url"];
        NSURL* standardResolutionImageURL = [NSURL URLWithString:standardResolutionImageURLString];
        
        if (standardResolutionImageURL)
        {
            self.mediaURL = standardResolutionImageURL;
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
    }
    
    return self;
}

@end
