//
//  CHSimpleFlowLayout.m
//  ChatLayoutSample
//
// Example of flow layout partially was taken from here
// http://www.raizlabs.com/blog/2013/10/animating_items_uicollectionview/


#import "CHSimpleFlowLayout.h"

@interface CHSimpleFlowLayout ()

// Containers for keeping track of changing items
@property (nonatomic, strong) NSMutableArray *insertedIndexPaths;
@property (nonatomic, strong) NSMutableArray *removedIndexPaths;

// Caches for keeping current/previous attributes
@property (nonatomic, strong) NSMutableDictionary *currentCellAttributes;
@property (nonatomic, strong) NSMutableDictionary *cachedCellAttributes;

// Use to compute previous location of other cells when cells get removed/inserted
- (NSIndexPath*)previousIndexPathForIndexPath:(NSIndexPath*)indexPath accountForItems:(BOOL)checkItems;

@end

@implementation CHSimpleFlowLayout

- (id)init {
    self = [super init];
    if (self) {
        self.currentCellAttributes = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Subclass

- (void)prepareLayout {
    [super prepareLayout];
    
    // Deep-copy attributes in current cache
    self.cachedCellAttributes = [[NSMutableDictionary alloc] initWithDictionary:self.currentCellAttributes copyItems:YES];
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray * attributes = [super layoutAttributesForElementsInRect:rect];
    
    // Always cache all visible attributes so we can use them later when computing final/initial animated attributes
    // Never clear the cache as certain items may be removed from the attributes array prior to being animated out
    [attributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attributes, NSUInteger idx, BOOL *stop) {
        if (attributes.representedElementCategory == UICollectionElementCategoryCell) {
            [self.currentCellAttributes setObject:attributes
                                           forKey:attributes.indexPath];
        }
    }];
    return attributes;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    [super prepareForCollectionViewUpdates:updateItems];
    // Keep track of updates to items and sections so we can use this information to create nifty animations
    self.insertedIndexPaths     = [NSMutableArray array];
    self.removedIndexPaths      = [NSMutableArray array];
    
    [updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem *updateItem, NSUInteger idx, BOOL *stop) {
        if (updateItem.updateAction == UICollectionUpdateActionInsert) {
            [self.insertedIndexPaths addObject:updateItem.indexPathAfterUpdate];
        }
        else if (updateItem.updateAction == UICollectionUpdateActionDelete) {
            [self.removedIndexPaths addObject:updateItem.indexPathBeforeUpdate];
            
        }
    }];
}

// These layout attributes are applied to a cell that is "appearing" and will be eased into the nominal layout attributes for that cell
// Cells "appear" in several cases:
//  - Inserted explicitly or via a section insert
//  - Moved as a result of an insert at a lower index path
//  - Result of an animated bounds change repositioning cells
- (UICollectionViewLayoutAttributes*)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    if ([self.insertedIndexPaths containsObject:itemIndexPath]){
        // If this is a newly inserted item, make it grow into place from its nominal index path
        attributes = [[self.currentCellAttributes objectForKey:itemIndexPath] copy];
        //        attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
        attributes.alpha = 0;
    }
    return attributes;
}

// These layout attributes are applied to a cell that is "disappearing" and will be eased to from the nominal layout attribues prior to disappearing
// Cells "disappear" in several cases:
//  - Removed explicitly or via a section removal
//  - Moved as a result of a removal at a lower index path
//  - Result of an animated bounds change repositioning cells
- (UICollectionViewLayoutAttributes*)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    if ([self.removedIndexPaths containsObject:itemIndexPath]) {
        // Make it fall off the screen with a slight rotation
        attributes = [[self.cachedCellAttributes objectForKey:itemIndexPath] copy];
        CATransform3D transform = CATransform3DMakeTranslation(0, self.collectionView.bounds.size.height, 0);
        transform = CATransform3DRotate(transform, M_PI*0.2, 0, 0, 1);
        attributes.transform3D = transform;
        attributes.alpha = 0.0f;
    }
    return attributes;
}

- (void)finalizeCollectionViewUpdates {
    [super finalizeCollectionViewUpdates];
    self.insertedIndexPaths     = nil;
    self.removedIndexPaths      = nil;
}

#pragma mark - Helpers

- (NSIndexPath*)previousIndexPathForIndexPath:(NSIndexPath *)indexPath accountForItems:(BOOL)checkItems {
    __block NSInteger section = indexPath.section;
    __block NSInteger item = indexPath.item;
    
    if (checkItems){
        [self.removedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *rmIndexPath, NSUInteger idx, BOOL *stop) {
            if ([rmIndexPath section] == section && [rmIndexPath item] <= item){
                item++;
            }
        }];
    }
    
    if (checkItems){
        [self.insertedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *insIndexPath, NSUInteger idx, BOOL *stop) {
            if ([insIndexPath section] == [indexPath section] && [insIndexPath item] < [indexPath item]){
                item--;
            }
        }];
    }
    
    return [NSIndexPath indexPathForItem:item inSection:section];
}

@end