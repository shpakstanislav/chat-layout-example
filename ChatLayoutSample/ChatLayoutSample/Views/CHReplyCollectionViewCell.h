//
//  CHReplyCollectionViewCell.h
//  ChatLayoutSample
//
//  Created by Stanislav Shpak on 12/14/15.
//  Copyright © 2015 Stanislav Shpak.
//

#import <UIKit/UIKit.h>

@class Message;

@interface CHReplyCollectionViewCell : UICollectionViewCell

// Load Message in cell
- (void)loadMessage:(Message *)message collectionViewWidth:(CGFloat)width;

// Calculate size for collection view data source method
+ (CGSize)sizeForText:(NSString *)text withCollectionViewWidth:(CGFloat)width;

@end
