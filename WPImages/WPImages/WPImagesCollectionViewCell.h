//
//  WPImagesCollectionViewCell.h
//  WPImages
//
//  Created by Игорь Савельев on 19/10/14.
//  Copyright (c) 2014 Leonspok. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LP3DResponsiveView.h"

@interface WPImagesCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
