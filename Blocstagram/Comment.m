//
//  Comment.m
//  Blocstagram
//
//  Created by Peter Shultz on 12/1/14.
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//

#import "User.h"
#import "Comment.h"

@implementation Comment

- (instancetype) initWithDictionary:(NSDictionary *)commentDictionary
{
    self = [super init];
    
    if (self)
    {
        self.idNumber = commentDictionary[@"id"];
        self.text = commentDictionary[@"text"];
        self.from = [[User alloc] initWithDictionary:commentDictionary[@"from"]];
    }
    
    return self;
}

@end
