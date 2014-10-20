//
//  UICollectionViewSineLayout.m
//  WPImages
//
//  Created by Игорь Савельев on 19/10/14.
//  Copyright (c) 2014 Leonspok. All rights reserved.
//

#import "UICollectionViewSineLayout.h"

#define SINE_COEF 100.0f
#define STEP 40.0f
#define CELL_SIDE 60.0f

@implementation UICollectionViewSineLayout {
    NSDictionary *layoutInfo;
}

- (void)prepareLayout {
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = 1;
    if ([self.collectionView respondsToSelector:@selector(numberOfSections)]) {
        sectionCount = [self.collectionView numberOfSections];
    }
    NSIndexPath *indexPath;
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < itemCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            CGFloat amplitude = (self.collectionView.frame.size.width-CELL_SIDE*2)/2;

            CGPoint centerPosition;
            centerPosition.y = CELL_SIDE+indexPath.item*STEP+STEP/2;
            centerPosition.x = CGRectGetMidX(self.collectionView.frame)+amplitude*sin((centerPosition.y-CELL_SIDE)/SINE_COEF);
            
            CGPoint nextCenterPosition;
            nextCenterPosition.y = CELL_SIDE+(indexPath.item+1)*STEP+STEP/2;
            nextCenterPosition.x = CGRectGetMidX(self.collectionView.frame)+amplitude*sin((nextCenterPosition.y-CELL_SIDE)/SINE_COEF);
            
            CGPoint previousCenterPosition;
            previousCenterPosition.y = CELL_SIDE+(indexPath.item-1)*STEP+STEP/2;
            previousCenterPosition.x = CGRectGetMidX(self.collectionView.frame)+amplitude*sin((previousCenterPosition.y-CELL_SIDE)/SINE_COEF);
            
            CGFloat nextAngle = atan((nextCenterPosition.x-centerPosition.x)/(nextCenterPosition.y-centerPosition.y));
            CGFloat prevAngle = atan((centerPosition.x-previousCenterPosition.x)/(centerPosition.y-previousCenterPosition.y));
            
            CGFloat angle = (nextAngle+prevAngle)/2;
            
            itemAttributes.transform = CGAffineTransformMakeRotation(-angle);
            itemAttributes.center = centerPosition;
            itemAttributes.size = CGSizeMake(CELL_SIDE, CELL_SIDE);
            itemAttributes.zIndex = item;
                        
            [cellLayoutInfo setObject:itemAttributes forKey:indexPath];
        }
    }
    
    layoutInfo = cellLayoutInfo;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *allAttributes = [NSMutableArray array];
    
    for (UICollectionViewLayoutAttributes *attributes in [layoutInfo allValues]) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [allAttributes addObject:attributes];
        }
    }
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [layoutInfo objectForKey:indexPath];
}

- (CGSize)collectionViewContentSize {
    NSInteger sectionCount = 1;
    if ([self.collectionView respondsToSelector:@selector(numberOfSections)]) {
        sectionCount = [self.collectionView numberOfSections];
    }
    
    NSInteger allItemsCount = 0;
    for (NSInteger section = 0; section < sectionCount; section++) {
        allItemsCount += [self.collectionView numberOfItemsInSection:section];
    }
    
    CGFloat height = STEP*(allItemsCount+2);
    return CGSizeMake(self.collectionView.frame.size.width, height);
}

@end
