//
//  ImageViewController.m
//  WPImages
//
//  Created by Игорь Савельев on 20/10/14.
//  Copyright (c) 2014 Leonspok. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    
    self.scrollView.contentSize = self.view.bounds.size;
    [self.imageView setImage:self.image];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self.imageView setImage:image];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
