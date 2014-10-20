//
//  RedViewController.m
//  WPImages
//
//  Created by Игорь Савельев on 12/10/14.
//  Copyright (c) 2014 Leonspok. All rights reserved.
//

#import "ImagesViewController.h"
#import "LPDoorStyleNavigationController.h"
#import "WPImagesCollectionViewCell.h"
#import "UICollectionViewSineLayout.h"
#import "DropboxImagesClient.h"
#import "ImageViewController.h"

static NSString *const imageCellIdentifier = @"imageCellIdentifier";
static NSString *const loadCellIdentifier = @"loadCellIdentifier";

@interface ImagesViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation ImagesViewController {
    UICollectionViewFlowLayout *gridLayout;
    UICollectionViewFlowLayout *listLayout;
    UICollectionViewSineLayout *sineLayout;
    
    NSInteger pages;
    NSMutableArray *imageURLs;
    
    NSCache *imageCache;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    gridLayout = [[UICollectionViewFlowLayout alloc] init];
    [gridLayout setMinimumInteritemSpacing:5.0f];
    [gridLayout setMinimumLineSpacing:5.0f];
    listLayout = [[UICollectionViewFlowLayout alloc] init];
    [listLayout setMinimumLineSpacing:10.0f];
    sineLayout = [[UICollectionViewSineLayout alloc] init];
    
    [self.collectionView registerClass:WPImagesCollectionViewCell.class forCellWithReuseIdentifier:imageCellIdentifier];
    [self.collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:loadCellIdentifier];
    
    pages = 0;
    imageURLs = [NSMutableArray array];
    
    imageCache = [[NSCache alloc] init];
    
    [self.collectionView setCollectionViewLayout:listLayout animated:YES];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.collectionView performBatchUpdates:nil completion:nil];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return imageURLs.count+1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == imageURLs.count) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:loadCellIdentifier forIndexPath:indexPath];
        return cell;
    }
    
    WPImagesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:imageCellIdentifier forIndexPath:indexPath];
    [cell.label setText:[NSString stringWithFormat:@"%ld", (long)indexPath.item]];
    
    [cell.imageView setImage:nil];
    if ([imageCache objectForKey:indexPath]) {
        [cell.imageView setImage:[imageCache objectForKey:indexPath]];
    } else {
        [[DropboxImagesClient sharedClient] getImageForURL:[imageURLs objectAtIndex:indexPath.item] success:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!image) {
                    return;
                }
                if ([indexPath isEqual:[self.collectionView indexPathForCell:cell]]) {
                    [cell.imageView setImage:image];
                    [imageCache setObject:image forKey:indexPath];
                }
            });
        } failure:^(NSError *error) {
            NSLog(@"%@", [error description]);
        }];
    }
    
    return cell;
}

#pragma mark UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionViewLayout == gridLayout) {
        CGFloat side = 0.0f;
        if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            side = (collectionView.frame.size.width-25.0f)/6;
        } else {
            side = (collectionView.frame.size.width-15.0f)/4;
        }
        return CGSizeMake(side, side);
    } else if (collectionViewLayout == listLayout) {
        CGFloat side = collectionView.frame.size.width;
        return CGSizeMake(side, side*2/5);
    }
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == imageURLs.count) {
        [[DropboxImagesClient sharedClient] loadImagesForPage:pages success:^(NSArray *newImageURLs) {
            [imageURLs addObjectsFromArray:newImageURLs];
            pages++;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        } failure:^(NSError *error) {
            NSLog(@"%@", [error description]);
        }];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageViewController *vc = [[ImageViewController alloc] initWithNibName:NSStringFromClass(ImageViewController.class) bundle:nil];
    
    if ([imageCache objectForKey:indexPath]) {
        vc.image = [imageCache objectForKey:indexPath];
    } else {
        [[DropboxImagesClient sharedClient] getImageForURL:[imageURLs objectAtIndex:indexPath.item] success:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!image) {
                    return;
                }
                vc.image = image;
                [imageCache setObject:image forKey:indexPath];
            });
        } failure:^(NSError *error) {
            NSLog(@"%@", [error description]);
        }];
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark UIActions

- (IBAction)setGridLayout:(id)sender {
    [self.collectionView setCollectionViewLayout:gridLayout animated:YES];
}

- (IBAction)setListLayout:(id)sender {
    [self.collectionView setCollectionViewLayout:listLayout animated:YES];
}

- (IBAction)setSineLayout:(id)sender {
    [self.collectionView setCollectionViewLayout:sineLayout animated:YES];
}

@end
