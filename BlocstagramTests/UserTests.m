//
//  UserTests.m
//  Blocstagram
//
//  Created by Peter Shultz on 1/22/15.
//  Copyright (c) 2015 Peter Shultz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "User.h"
#include "Comment.h"
#include "ComposeCommentView.h"
#include "Media.h"

@interface UserTests : XCTestCase

@end

@implementation UserTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testThatMediaWorks
{
    //Id, user, caption, likes
    
    NSDictionary *testDictionary = @{
                                @"id" : [NSNumber numberWithInt:13],
                                @"user" : @"peterkshultz",
                                @"caption" : @"Objective-C is hard",
                                @"likes" : @{@"count" :  [NSNumber numberWithInt:40]},
                                };
    
    Media* testMediaItem = [[Media alloc] initWithDictionary:testDictionary];
    
    XCTAssertEqualObjects(testMediaItem, testDictionary);
}

- (void) testThatIsWritingCommentWorks
{
    //ComposeCommentView.m
    
    //Do something with commentAttributedString so that you can make a comment and then test it!
    
    ComposeCommentView* testComposeCommentView = [[ComposeCommentView alloc] init];
    
    [testComposeCommentView commentAttributedString];
    
}

- (void) testThatHeightForMediaItemWorks
{
    
}

- (void) testThatInitializationWorks
{
    NSDictionary* sourceDictionary = @{@"id": @"8675309",
                                       @"text": @"Sample Comment"};
    
    Comment* testComment = [[Comment alloc] initWithDictionary:sourceDictionary];
    
    XCTAssertEqualObjects(testComment.idNumber, sourceDictionary[@"id"], @"The ID number should be equal");
    XCTAssertEqualObjects(testComment.text, sourceDictionary[@"text"], @"The text should be equal");

}

- (void) testThatInitializerWorks
{
    NSDictionary *sourceDictionary = @{@"id": @"8675309",
                                       @"username" : @"d'oh",
                                       @"full_name" : @"Homer Simpson",
                                       @"profile_picture" : @"http://www.example.com/example.jpg"};
    
    User *testUser = [[User alloc] initWithDictionary:sourceDictionary];
    
    XCTAssertEqualObjects(testUser.idNumber, sourceDictionary[@"id"], @"The ID number should be equal");
    XCTAssertEqualObjects(testUser.userName, sourceDictionary[@"username"], @"The username should be equal");
    XCTAssertEqualObjects(testUser.fullName, sourceDictionary[@"full_name"], @"The full name should be equal");
    XCTAssertEqualObjects(testUser.profilePictureURL, [NSURL URLWithString:sourceDictionary[@"profile_picture"]], @"The profile picture should be equal");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
