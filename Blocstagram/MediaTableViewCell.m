//
//  MediaTableViewCell.m
//  Blocstagram
//
//  Created by Peter Shultz on 12/1/14.
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//

#import "MediaTableViewCell.h"
#import "Media.h"
#import "Comment.h"
#import "User.h"
#import "DataSource.h"
#import "LikeButton.h"
#import "ComposeCommentView.h"

@interface MediaTableViewCell() <UIGestureRecognizerDelegate, ComposeCommentViewDelegate>

@property (nonatomic, strong) UIImageView* mediaImageView;
@property (nonatomic, strong) UILabel* usernameAndCaptionLabel;
@property (nonatomic, strong) UILabel* commentLabel;
@property (nonatomic, strong) UILabel* numberOfLikesLabel;
@property (nonatomic, strong) NSLayoutConstraint *imageHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *usernameAndCaptionLabelHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *commentLabelHeightConstraint;
@property (nonatomic, strong) UITapGestureRecognizer* tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer* doubleTapForRetry;
@property (nonatomic, strong) LikeButton *likeButton;
@property (nonatomic, strong) ComposeCommentView *commentView;




@end

static UIFont* lightFont;
static UIFont* boldFont;
static UIColor* usernameLabelGray;
static UIColor* commentLabelGray;
static UIColor* linkColor;
static NSParagraphStyle* paragraphStyle;

@implementation MediaTableViewCell

+ (void) load
{
    lightFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:11];
    boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
    usernameLabelGray = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1];
    commentLabelGray = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1];
    linkColor = [UIColor colorWithRed:0.345 green:0.314 blue:0.427 alpha:1];
    
    NSMutableParagraphStyle* mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    mutableParagraphStyle.headIndent = 20.0;
    mutableParagraphStyle.firstLineHeadIndent = 20.0;
    mutableParagraphStyle.tailIndent = -20.0;
    mutableParagraphStyle.paragraphSpacingBefore = 5;
    
    paragraphStyle = mutableParagraphStyle;
}

- (NSAttributedString*) usernameAndCaptionString
{
    CGFloat usernameFontSize = 15;
    
    //Make a string that says "username caption text"
    NSString* baseString = [NSString stringWithFormat:@"%@ %@", self.mediaItem.user.userName, self.mediaItem.caption];
    
    //Make an attributed string, with the "username" bold
    NSMutableAttributedString* mutableUsernameAndCaptionString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : [lightFont fontWithSize:usernameFontSize], NSParagraphStyleAttributeName : paragraphStyle}];
    
    NSRange usernameRange = [baseString rangeOfString:self.mediaItem.user.userName];
    
    [mutableUsernameAndCaptionString addAttribute:NSFontAttributeName value:[boldFont fontWithSize:usernameFontSize] range:usernameRange];
    [mutableUsernameAndCaptionString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
    
    return mutableUsernameAndCaptionString;
}

- (NSMutableAttributedString*) numberOfLikesString
{
    //self.mediaItem.numberOfLikes is null here. When tested in Media.m, it works fine. Why? 
    
    NSLog(@"%i",  self.mediaItem.numberOfLikes);
    
    CGFloat usernameFontSize = 15;
    
    //Make a string that says "username caption text"
    NSString* likeString = [NSString stringWithFormat:@"%i", self.mediaItem.numberOfLikes];
    
    //Make an attributed string, with the "username" bold
    NSMutableAttributedString* likeAttributeString = [[NSMutableAttributedString alloc] initWithString:likeString attributes:@{NSFontAttributeName : [lightFont fontWithSize:usernameFontSize]
//                                                                                                                               , NSParagraphStyleAttributeName : paragraphStyle
                                                                                                                               }];
    
//    NSRange usernameRange = [baseString rangeOfString:self.mediaItem.user.userName];
//    
//    [likeAttributeString addAttribute:NSFontAttributeName value:[boldFont fontWithSize:usernameFontSize] range:usernameRange];
//    [likeAttributeString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
    
    
//    NSString* likeString = [self.mediaItem.numberOfLikes stringValue];
    return likeAttributeString;
}




- (void) layoutSubviews
{
    [super layoutSubviews];
    
    if (self.mediaItem == nil){
        return;
    }
    
    // Before layout, calculate the intrinsic size of the labels (the size they "want" to be), and add 20 to the height for some vertical padding.
    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX);
    CGSize usernameLabelSize = [self.usernameAndCaptionLabel sizeThatFits:maxSize];
    CGSize commentLabelSize = [self.commentLabel sizeThatFits:maxSize];
    
    self.usernameAndCaptionLabelHeightConstraint.constant = usernameLabelSize.height + 20;
    self.commentLabelHeightConstraint.constant = commentLabelSize.height + 20;
    
    if (_mediaItem.image)
    {
        if (isPhone)
        {
            self.imageHeightConstraint.constant = self.mediaItem.image.size.height / self.mediaItem.image.size.width * CGRectGetWidth(self.contentView.bounds);
        }
        
        else
        {
            self.imageHeightConstraint.constant = 320;
        }
    }
    else
    {
        self.imageHeightConstraint.constant = 0;
    }

    //Hide the line between cells
    self.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(self.bounds));
}

+ (CGFloat) heightForMediaItem:(Media*)mediaItem width:(CGFloat)width;
{
    //Make a cell
    MediaTableViewCell* layoutCell = [[MediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"layoutCell"];
    
    //Give it the media item
    layoutCell.mediaItem = mediaItem;
    
    [layoutCell setNeedsLayout];
    [layoutCell layoutIfNeeded];
    
    // Get the actual height required for the cell
    return CGRectGetMaxY(layoutCell.commentView.frame);
    
}

- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:NO animated:animated];
}

- (void) setMediaItem:(Media *)mediaItem
{
    _mediaItem = mediaItem;
    self.mediaImageView.image = _mediaItem.image;
    self.usernameAndCaptionLabel.attributedText = [self usernameAndCaptionString];
    self.commentLabel.attributedText = [self commentString];
    NSLog(@"number of likes within setmedia %@", [self numberOfLikesString]);
    self.numberOfLikesLabel.attributedText = [self numberOfLikesString];
    self.numberOfLikesLabel.textAlignment = NSTextAlignmentCenter;
    self.likeButton.likeButtonState = mediaItem.likeState;
    self.commentView.text = mediaItem.temporaryComment;

}

- (NSAttributedString*) commentString
{
    NSMutableAttributedString* commentString = [[NSMutableAttributedString alloc] init];
    
    for (Comment* comment in self.mediaItem.comments)
    {
        //Make a string that says "username comment text" followed by a line break
        NSString* baseString = [NSString stringWithFormat:@"%@ %@\n", comment.from.userName, comment.text];
        
        //Make an attributed string, with the "username" bold
        NSMutableAttributedString* oneCommentString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : lightFont, NSParagraphStyleAttributeName : paragraphStyle}];
        
        NSRange usernameRange = [baseString rangeOfString:comment.from.userName];
        [oneCommentString addAttribute:NSFontAttributeName value:boldFont range:usernameRange];
        [oneCommentString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
        
        [commentString appendAttributedString:oneCommentString];
    }
    
    return commentString;
}




- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.mediaImageView = [[UIImageView alloc] init];
        
        self.mediaImageView.userInteractionEnabled = YES;
        
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        self.tapGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.tapGestureRecognizer];
        
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        self.longPressGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.longPressGestureRecognizer];
        
        self.usernameAndCaptionLabel = [[UILabel alloc] init];
        self.commentLabel = [[UILabel alloc] init];
        self.numberOfLikesLabel = [[UILabel alloc] init];
        self.commentLabel.numberOfLines = 0;
        
        self.doubleTapForRetry = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerTapForRetryFired:)];
        self.doubleTapForRetry.numberOfTouchesRequired = 2;
        self.doubleTapForRetry.delegate = self;
        [self addGestureRecognizer:self.doubleTapForRetry];

        self.likeButton = [[LikeButton alloc] init];
        [self.likeButton addTarget:self action:@selector(likePressed:) forControlEvents:UIControlEventTouchUpInside];
        self.likeButton.backgroundColor = usernameLabelGray;
        
        self.commentView = [[ComposeCommentView alloc] init];
        self.commentView.delegate = self;
        
        for (UIView *view in @[self.mediaImageView, self.usernameAndCaptionLabel, self.commentLabel, self.likeButton, self.numberOfLikesLabel, self.commentView])
        {
            [self.contentView addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        [self createConstraints];
    }
    return self;
}

- (void) createConstraints
{
    if (isPhone)
    {
        [self createPhoneConstraints];
    }
    
    else
    {
        [self createPadConstraints];
    }
    
    [self createCommonConstraints];
}

- (void) createCommonConstraints {
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_mediaImageView, _usernameAndCaptionLabel, _commentLabel, _likeButton, _commentView);
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_usernameAndCaptionLabel][_likeButton(==38)]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_commentLabel]|" options:kNilOptions metrics:nil views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_commentView]|" options:kNilOptions metrics:nil views:viewDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mediaImageView][_usernameAndCaptionLabel][_commentLabel][_commentView(==100)]"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:viewDictionary]];
    
    self.imageHeightConstraint = [NSLayoutConstraint constraintWithItem:_mediaImageView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:100];
    
    
    self.usernameAndCaptionLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_usernameAndCaptionLabel
                                                                                attribute:NSLayoutAttributeHeight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:nil
                                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                                               multiplier:1
                                                                                 constant:100];
    
    self.commentLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_commentLabel
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1
                                                                      constant:100];
    
    [self.contentView addConstraints:@[self.imageHeightConstraint, self.usernameAndCaptionLabelHeightConstraint, self.commentLabelHeightConstraint]];
}

- (void) createPadConstraints {
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_mediaImageView, _usernameAndCaptionLabel, _commentLabel, _likeButton, _commentView);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_mediaImageView(==320)]" options:kNilOptions metrics:nil views:viewDictionary]];
    [self.contentView addConstraint: [NSLayoutConstraint constraintWithItem:self.contentView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:0
                                                                     toItem:_mediaImageView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1
                                                                   constant:0]];
    
}

- (void) createPhoneConstraints {
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_mediaImageView, _usernameAndCaptionLabel, _commentLabel, _likeButton, _commentView);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mediaImageView]|" options:kNilOptions metrics:nil views:viewDictionary]];

}

- (void) twoFingerTapForRetryFired:(UITapGestureRecognizer *)sender
{
//    DataSource* object;
    
    [[DataSource sharedInstance] downloadImageForMediaItem:self.mediaItem];
    
//    NSCoder* aDecoder;
//    
//    self.mediaItem.image = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(image))];
}

#pragma mark - Liking

- (void) likePressed:(UIButton *)sender
{
    [self.delegate cellDidPressLikeButton:self];
}

#pragma mark - Image View

- (void) tapFired:(UITapGestureRecognizer *)sender
{
    [self.delegate cell:self didTapImageView:self.mediaImageView];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return self.isEditing == NO;
}

- (void) longPressFired:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        [self.delegate cell:self didLongPressImageView:self.mediaImageView];
    }
}

#pragma mark - ComposeCommentViewDelegate

- (void) commentViewDidPressCommentButton:(ComposeCommentView *)sender
{
    [self.delegate cell:self didComposeComment:self.mediaItem.temporaryComment];
}

- (void) commentView:(ComposeCommentView *)sender textDidChange:(NSString *)text
{
    self.mediaItem.temporaryComment = text;
}

- (void) commentViewWillStartEditing:(ComposeCommentView *)sender
{
    [self.delegate cellWillStartComposingComment:self];
}

- (void) stopComposingComment
{
    [self.commentView stopComposingComment];
}


- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    
    [super setSelected:NO animated:animated];

    // Configure the view for the selected state
}
    
@end

