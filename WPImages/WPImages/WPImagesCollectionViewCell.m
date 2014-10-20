//
//  WPImagesCollectionViewCell.m
//  WPImages
//
//  Created by Игорь Савельев on 19/10/14.
//  Copyright (c) 2014 Leonspok. All rights reserved.
//

#import "WPImagesCollectionViewCell.h"

@implementation WPImagesCollectionViewCell

- (id)init {
    self = [super self];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    UIView *contentView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:0] firstObject];
    [self setFrame:contentView.bounds];
    [self addSubview:contentView];
    
    [self.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.layer setShadowOpacity:1.0f];
    [self.layer setShadowRadius:5.0f];
    self.layer.masksToBounds = NO;
}

@end
