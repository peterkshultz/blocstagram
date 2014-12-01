//
//  ImagesTableViewController.m
//  Blocstagram
//
//  Created by Peter Shultz on 11/30/14.
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//

#import "ImagesTableViewController.h"
#import "DataSource.h"
#import "Media.h"
#import "User.h"
#import "Comment.h"

@interface ImagesTableViewController ()

@end

@implementation ImagesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"imageCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    return self;
}

- (NSMutableArray*)items
{
    return [DataSource sharedInstance].mediaItems;
    
}

#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Media* item = [self items][indexPath.row];
    UIImage* image = item.image;
    
    return (CGRectGetWidth(self.view.frame) / image.size.width) * image.size.height;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.

    return [self items].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];
    
    // Configure the cell...
    static NSInteger imageViewTag = 1234;
    
    UIImageView* imageView = (UIImageView*)[cell.contentView viewWithTag:imageViewTag];
    
    if (!imageView)
    {
        //This is a new cell without an image
        imageView = [[UIImageView alloc] init];
        
        imageView.contentMode = UIViewContentModeScaleToFill;
        
        imageView.frame = cell.contentView.bounds;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        imageView.tag = imageViewTag;
        [cell.contentView addSubview:imageView];
        
    }
    
    Media* item = [self items][indexPath.row];
    imageView.image = item.image;
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        
        
        // Delete the row from the data source
        [[self items] removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
