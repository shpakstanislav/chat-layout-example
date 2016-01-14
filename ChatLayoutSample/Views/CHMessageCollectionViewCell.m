//
//  CHMessageCollectionViewCell.m
//  ChatLayoutSample
//
//  Created by Stanislav Shpak on 12/14/15.
//  Copyright © 2015 Stanislav Shpak.
//

#import "CHMessageCollectionViewCell.h"
#import "Message.h"

@interface CHMessageCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *containerImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerImageViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerImageViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profieImageViewWidth;
@end

// Margins to adjust text in bubble
static const CGFloat kTextInternalTopMargin = 5.f;
static const CGFloat kTextInternalMargin = 7.f;
static const CGFloat kTopMargin = 20.f;
static const CGFloat kCommonMargin = 10.f;
static const CGFloat kProfileImageViewWidth = 30.f;

@implementation CHMessageCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization interface from xib file
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"CHMessageCollectionViewCell" owner:self options:nil];
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        self = [arrayOfViews objectAtIndex:0];
        
        // Make round corner for profile image view
        self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.size.width/2;
        self.containerImageView.image = [[UIImage imageNamed:@"message_bubble_left"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
        
        // Transform to imitate bottom side origin for messages,
        // so new messages will be added to bottom and old messages will lift up
        // see ViewController -(void)setupCollectionView
        CGAffineTransform curTransform = self.baseView.transform;
        self.baseView.transform = CGAffineTransformScale(curTransform, 1, -1);
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self updateLayout];
}

- (void)updateLayout {
    self.containerImageViewWidth.constant = self.messageLabel.bounds.size.width + kTextInternalMargin*3 ;
    self.containerImageViewHeight.constant = self.messageLabel.bounds.size.height + kTextInternalTopMargin + kTextInternalMargin;
}

- (void)loadMessage:(Message *)message collectionViewWidth:(CGFloat)width {
    self.messageLabel.text = message.text;
    [self.messageLabel setPreferredMaxLayoutWidth:width - self.messageLabel.frame.origin.x - kCommonMargin - kTextInternalMargin - kTextInternalMargin];
    self.nameLabel.text = message.name;
}

+ (CGSize)sizeForText:(NSString *)text withCollectionViewWidth:(CGFloat)width {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    
    CGSize constraintSize = CGSizeMake(width - kProfileImageViewWidth - kCommonMargin*3 - kTextInternalMargin*3, MAXFLOAT);
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:font}];
    CGRect rect = [attributedText boundingRectWithSize:constraintSize
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                         context:nil];
    return CGSizeMake(width, rect.size.height + kTextInternalTopMargin + kTextInternalMargin + kCommonMargin + kTopMargin);
}

@end
