//
//  ViewController.m
//  ChatLayoutSample
//
//  Created by Stanislav Shpak on 12/14/15.
//  Copyright © 2015 Stanislav Shpak.
//

#import "ViewController.h"

#import "CHSpringFlowLayout.h"
#import "CHSimpleFlowLayout.h"
#import "CHMessageCollectionViewCell.h"
#import "CHReplyCollectionViewCell.h"

#import "Message.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate> {
    NSMutableArray *_data;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *addMessageButton;
@end

@implementation ViewController

#pragma mark - Lifecycle and setup -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup navigation bar layout
    [self setupNavigationBar];
    
    // Setup collection view layout
    [self setupCollectionView];
    
    // Initialize data
    _data = [[Message populateMessages:3] mutableCopy];
    [self.collectionView reloadData];
}

- (void)setupNavigationBar {
    self.title = @"Chat";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearData:)];
}

- (void)setupCollectionView {
    // Create and add spring ui behaivor for collection view
    CHSpringFlowLayout *flowLayout = [[CHSpringFlowLayout alloc] init];
    
    // CollectionView Flow Layout without spring behaivor
//    CHSimpleFlowLayout *flowLayout = [[CHSimpleFlowLayout alloc] init];
    
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    // Register custom cells
    [self.collectionView registerClass:[CHMessageCollectionViewCell class] forCellWithReuseIdentifier:@"CellMessage"];
    [self.collectionView registerClass:[CHReplyCollectionViewCell class] forCellWithReuseIdentifier:@"CellReply"];
    
    // Collection view basic ui setups
    self.collectionView.backgroundView = nil;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // Transform to imitate bottom side origin for messages,
    // so new messages will be added to bottom and old messages will lift up
    CGAffineTransform curTransform = self.collectionView.transform;
    self.collectionView.transform = CGAffineTransformScale(curTransform, 1, -1);
}

#pragma mark - CollectionView DataSource -

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Message *message = _data[indexPath.row];
    
    // Return cell corresponding to message type
    if (message.type == CHMessageTypeInbox) {
        CHMessageCollectionViewCell *cell = (CHMessageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellMessage" forIndexPath:indexPath];
        [cell loadMessage:message collectionViewWidth:collectionView.bounds.size.width];
        [cell setNeedsDisplay];
        return cell;
    } else {
        CHReplyCollectionViewCell *cell = (CHReplyCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellReply" forIndexPath:indexPath];
        [cell loadMessage:message collectionViewWidth:collectionView.bounds.size.width];
        [cell setNeedsDisplay];
        return cell;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _data.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Calcuate cell size from message text
    Message *message = _data[indexPath.row];
    CGSize size;
    if (message.type == CHMessageTypeInbox)
        size = [CHMessageCollectionViewCell sizeForText:message.text withCollectionViewWidth:self.collectionView.bounds.size.width];
    else
        size = [CHReplyCollectionViewCell sizeForText:message.text withCollectionViewWidth:self.collectionView.bounds.size.width];
    
    return size;
}

#pragma mark - Others -

- (IBAction)addMessage:(id)sender {
    // Add random message to data and update collection view
    self.addMessageButton.enabled = NO;
    [_collectionView performBatchUpdates:^{
        Message *message = [Message populateSingleMessage];
        [_data insertObject:message atIndex:0];
        NSIndexPath *bottomIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        [_collectionView insertItemsAtIndexPaths:@[bottomIndexPath]];
    } completion:^(BOOL finished) {
        self.addMessageButton.enabled = YES;
    }];
}

- (void)clearData:(id)sender {
    [_data removeAllObjects];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
