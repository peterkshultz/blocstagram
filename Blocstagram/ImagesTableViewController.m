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
#import "MediaTableViewCell.h"
#import "MediaFullScreenViewController.h"
#import "MediaFullScreenAnimator.h"

@interface ImagesTableViewController () <MediaTableViewCellDelegate, UIViewControllerTransitioningDelegate>

@property (assign) int i ;
@property (nonatomic, weak) UIImageView* lastTappedImageView;
@end

@implementation ImagesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[DataSource sharedInstance] addObserver:self forKeyPath:@"mediaItems" options:0 context:nil];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlDidFire:) forControlEvents:UIControlEventValueChanged];
    
    
    [self.tableView registerClass:[MediaTableViewCell class] forCellReuseIdentifier:@"mediaCell"];
    //    UIBarButtonItem *newButton = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonSystemItemEdit target:self action:@selector(editPressed:)];
    //    self.navigationItem.rightBarButtonItem = newButton;
    self.i=0;
}

- (void) infiniteScrollIfNecessary
{
    NSIndexPath* bottomIndexPath = [[self.tableView indexPathsForVisibleRows] lastObject];
    
    if (bottomIndexPath && bottomIndexPath.row == [DataSource sharedInstance].mediaItems.count - 1)
    {
        //The very last cell is on screen
        [[DataSource sharedInstance] requestOldItemsWithCompletionHandler:nil];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"%i", self.i++);
    [self infiniteScrollIfNecessary];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"%i", self.i++);
    //[self infiniteScrollIfNecessary];
}

- (void) refreshControlDidFire:(UIRefreshControl*)sender
{
    [[DataSource sharedInstance] requestNewItemsWithCompletionHandler:^(NSError *error)
     {
         [sender endRefreshing];
     }];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == [DataSource sharedInstance] && [keyPath isEqualToString:@"mediaItems"])
    {
        //Media item has changed
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting)
        {
            //New images array
            [self.tableView reloadData];
        }
        
        else if ((kindOfChange == NSKeyValueChangeInsertion) ||
                (kindOfChange == NSKeyValueChangeRemoval) ||
                (kindOfChange == NSKeyValueChangeReplacement))
        {
            //Insertion, deletion, replacement
            
            //Get a list of what has changed
            NSIndexSet* indexSetOfChanges = change[NSKeyValueChangeIndexesKey];
            
            //Convert this index set to an array of index paths (the table view animation requires this)
            NSMutableArray* indexPathsThatChanged = [NSMutableArray array];
            [indexSetOfChanges enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL* stop)
             {
                 NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow: idx inSection: 0];
                 [indexPathsThatChanged addObject:newIndexPath];
             }];
            
            //Call beginUpdates to tell the table view we're about to make changes
            [self.tableView beginUpdates];
            
            //Let the table view know the changes
            if (kindOfChange == NSKeyValueChangeInsertion)
            {
                [self.tableView insertRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else if (kindOfChange == NSKeyValueChangeRemoval)
            {
                [self.tableView deleteRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else if (kindOfChange == NSKeyValueChangeReplacement)
            {
                [self.tableView reloadRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            //Done with changes; complete the animation
            [self.tableView endUpdates];
        }
    }
}

- (void) dealloc
{
    [[DataSource sharedInstance] removeObserver:self forKeyPath:@"mediaItems"];
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

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Media *mediaItem = [DataSource sharedInstance].mediaItems[indexPath.row];
    if (mediaItem.downloadState == MediaDownloadStateNeedsImage)
    {
        [[DataSource sharedInstance] downloadImageForMediaItem:mediaItem];
    }
}


- (CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Media* item = [self items][indexPath.row];

    return [MediaTableViewCell heightForMediaItem:item width:CGRectGetWidth(self.view.frame)];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.

    return [self items].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MediaTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"mediaCell" forIndexPath:indexPath];
    
    cell.delegate = self;
    
    cell.mediaItem = [DataSource sharedInstance].mediaItems[indexPath.row];
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //Delete the row from the data source
        Media* item = [DataSource sharedInstance].mediaItems[indexPath.row];
        [[DataSource sharedInstance] deleteMediaItem:item];
    }
}

- (IBAction)editPressed:(id)sender
{
    NSLog(@"They are interested in sharing!");
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Media* item = [DataSource sharedInstance].mediaItems[indexPath.row];
    
    if (item.image)
    {
        return 350;
    }
    
    else
    {
        return 150;
    }
}

- (void)setEditing:(BOOL)flag animated:(BOOL)animated
{
    [super setEditing:flag animated:animated];
}

#pragma mark - BLCMediaTableViewCellDelegate

- (void) cell:(MediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView
{
    
    [ImagesTableViewController mediaItem:cell.mediaItem withVC: self];
}

+ (void) mediaItem:(Media *)mediaItem withVC: (UIViewController*) vc
{
    NSMutableArray *itemsToShare = [NSMutableArray array];
    
    if (mediaItem.caption.length > 0)
    {
        [itemsToShare addObject:mediaItem.caption];
    }
    
    if (mediaItem.image)
    {
        [itemsToShare addObject:mediaItem.image];
    }
    
    if (itemsToShare.count > 0)
    {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        
        [vc presentViewController:activityVC animated:YES completion:nil];
    }
}


- (void) cell:(MediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView {
    MediaFullScreenViewController *fullScreenVC = [[MediaFullScreenViewController alloc] initWithMedia:cell.mediaItem];
    
    [self presentViewController:fullScreenVC animated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    
    MediaFullScreenAnimator *animator = [MediaFullScreenAnimator new];
    animator.presenting = YES;
    animator.cellImageView = self.lastTappedImageView;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    MediaFullScreenAnimator *animator = [MediaFullScreenAnimator new];
    animator.cellImageView = self.lastTappedImageView;
    return animator;
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
