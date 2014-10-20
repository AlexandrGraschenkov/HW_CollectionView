//
//  LPWindowsPhoneStyleNavigationController.h
//  WPImages
//
//  Created by Игорь Савельев on 12/10/14.
//  Copyright (c) 2014 Leonspok. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LPDoorRightSide,
    LPDoorLeftSide,
    LPDoorTopSide,
    LPDoorBottomSide
} LPDoorSide;

@interface LPDoorStyleNavigationController : UINavigationController

@property (nonatomic) NSTimeInterval animationDuration;
@property (nonatomic) LPDoorSide side;

@end
