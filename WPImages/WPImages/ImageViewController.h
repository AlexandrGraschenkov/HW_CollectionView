//
//  ImageViewController.h
//  WPImages
//
//  Created by Игорь Савельев on 20/10/14.
//  Copyright (c) 2014 Leonspok. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) UIImage *image;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
