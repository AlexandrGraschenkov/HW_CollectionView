//
//  LPWindowsPhoneStyleNavigationController.m
//  WPImages
//
//  Created by Игорь Савельев on 12/10/14.
//  Copyright (c) 2014 Leonspok. All rights reserved.
//

#import "LPDoorStyleNavigationController.h"

@implementation LPDoorStyleNavigationController

- (id)init {
    self = [super init];
    if (self) {
        [self setupNavigationController];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupNavigationController];
    }
    return self;
}

- (id)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    self = [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
    if (self) {
        [self setupNavigationController];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setupNavigationController];
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self setupNavigationController];
    }
    return self;
}

- (void)setupNavigationController {
    self.animationDuration = 0.5;
    self.side = LPDoorLeftSide;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (animated) {
        [self animatePushingFrom:[self.viewControllers lastObject] toViewController:viewController duration:self.animationDuration];
    } else {
        [super pushViewController:viewController animated:animated];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if (animated && self.viewControllers.count >= 2) {
        return [[self animatePoppingTo:[self.viewControllers objectAtIndex:self.viewControllers.count-2] duration:self.animationDuration] lastObject];
    } else {
        return [super popViewControllerAnimated:animated];
    }
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (animated && [self.viewControllers containsObject:viewController]) {
        return [self animatePoppingTo:viewController duration:self.animationDuration];
    } else {
        return[super popToViewController:viewController animated:animated];
    }
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    if (animated) {
        return [self animatePoppingTo:[self.viewControllers firstObject] duration:self.animationDuration];
    } else {
        return [super popToRootViewControllerAnimated:animated];
    }
}

- (void)animatePushingFrom:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController duration:(NSTimeInterval)duration {
    
    fromViewController.view.userInteractionEnabled = NO;
    toViewController.view.userInteractionEnabled = NO;
    
    CGPoint oldFromViewControllerAnchorPoint = fromViewController.view.layer.anchorPoint;
    CGPoint oldFromViewControllerPosition = fromViewController.view.layer.position;
    CGPoint oldToViewControllerAnchorPoint = toViewController.view.layer.anchorPoint;
    CGPoint oldToViewControllerPosition = toViewController.view.layer.position;
    
    CATransform3D dismissTransform = CATransform3DIdentity;
    dismissTransform.m34 = -1.0/500.0;
    CATransform3D presentTransform = CATransform3DIdentity;
    presentTransform.m34 = -1.0/500.0;
    
    switch (self.side) {
        case LPDoorLeftSide:
            [self applyAnchorPoint:CGPointMake(0, 0.5) forLayer:fromViewController.view.layer];
            dismissTransform = CATransform3DRotate(dismissTransform, -M_PI/2, 0, 1, 0);
            presentTransform = CATransform3DRotate(presentTransform, M_PI/2, 0, 1, 0);
            break;
        case LPDoorRightSide:
            [self applyAnchorPoint:CGPointMake(1, 0.5) forLayer:fromViewController.view.layer];
            dismissTransform = CATransform3DRotate(dismissTransform, M_PI/2, 0, 1, 0);
            presentTransform = CATransform3DRotate(presentTransform, -M_PI/2, 0, 1, 0);
            break;
        case LPDoorTopSide:
            [self applyAnchorPoint:CGPointMake(0.5, 0) forLayer:fromViewController.view.layer];
            dismissTransform = CATransform3DRotate(dismissTransform, M_PI/2, 1, 0, 0);
            presentTransform = CATransform3DRotate(presentTransform, -M_PI/2, 1, 0, 0);
            break;
        case LPDoorBottomSide:
            [self applyAnchorPoint:CGPointMake(0.5, 1) forLayer:fromViewController.view.layer];
            dismissTransform = CATransform3DRotate(dismissTransform, -M_PI/2, 1, 0, 0);
            presentTransform = CATransform3DRotate(presentTransform, M_PI/2, 1, 0, 0);
            break;
    }
    
    [UIView beginAnimations:@"WPStylePushAnimation" context:nil];
    [UIView setAnimationDuration:duration*1/3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    {
        fromViewController.view.layer.transform = dismissTransform;
        fromViewController.view.layer.opacity = 0.0f;
    }
    [UIView commitAnimations];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration*1/3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [super pushViewController:toViewController animated:NO];
        
        switch (self.side) {
            case LPDoorLeftSide:
                [self applyAnchorPoint:CGPointMake(0, 0.5) forLayer:toViewController.view.layer];
                break;
            case LPDoorRightSide:
                [self applyAnchorPoint:CGPointMake(1, 0.5) forLayer:toViewController.view.layer];
                break;
            case LPDoorTopSide:
                [self applyAnchorPoint:CGPointMake(0.5, 0) forLayer:toViewController.view.layer];
                break;
            case LPDoorBottomSide:
                [self applyAnchorPoint:CGPointMake(0.5, 1) forLayer:toViewController.view.layer];
                break;
        }
        
        toViewController.view.layer.transform = presentTransform;
        toViewController.view.layer.opacity = 0.0f;
        
        [UIView beginAnimations:@"WPStylePushAnimation" context:nil];
        [UIView setAnimationDuration:duration*2/3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        {
            toViewController.view.layer.opacity = 1.0f;
            toViewController.view.layer.transform = CATransform3DIdentity;
        }
        [UIView commitAnimations];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration*2/3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            fromViewController.view.layer.transform = CATransform3DIdentity;
            fromViewController.view.layer.opacity = 1.0f;
            
            fromViewController.view.layer.anchorPoint = oldFromViewControllerAnchorPoint;
            fromViewController.view.layer.position = oldFromViewControllerPosition;
            
            toViewController.view.layer.anchorPoint = oldToViewControllerAnchorPoint;
            toViewController.view.layer.position = oldToViewControllerPosition;
            
            fromViewController.view.userInteractionEnabled = YES;
            toViewController.view.userInteractionEnabled = YES;
        });
    });
}

- (NSArray *)animatePoppingTo:(UIViewController *)toViewController duration:(NSTimeInterval)duration {
    UIViewController *fromViewController = [self.viewControllers lastObject];
    
    fromViewController.view.userInteractionEnabled = NO;
    toViewController.view.userInteractionEnabled = NO;
    
    CGPoint oldFromViewControllerAnchorPoint = fromViewController.view.layer.anchorPoint;
    CGPoint oldFromViewControllerPosition = fromViewController.view.layer.position;
    CGPoint oldToViewControllerAnchorPoint = toViewController.view.layer.anchorPoint;
    CGPoint oldToViewControllerPosition = toViewController.view.layer.position;
    
    CATransform3D dismissTransform = CATransform3DIdentity;
    dismissTransform.m34 = -1.0/500.0;
    CATransform3D presentTransform = CATransform3DIdentity;
    presentTransform.m34 = -1.0/500.0;
    
    switch (self.side) {
        case LPDoorLeftSide:
            [self applyAnchorPoint:CGPointMake(0, 0.5) forLayer:fromViewController.view.layer];
            dismissTransform = CATransform3DRotate(dismissTransform, M_PI/2, 0, 1, 0);
            presentTransform = CATransform3DRotate(presentTransform, -M_PI/2, 0, 1, 0);
            break;
        case LPDoorRightSide:
            [self applyAnchorPoint:CGPointMake(1, 0.5) forLayer:fromViewController.view.layer];
            dismissTransform = CATransform3DRotate(dismissTransform, -M_PI/2, 0, 1, 0);
            presentTransform = CATransform3DRotate(presentTransform, M_PI/2, 0, 1, 0);
            break;
        case LPDoorTopSide:
            [self applyAnchorPoint:CGPointMake(0.5, 0) forLayer:fromViewController.view.layer];
            dismissTransform = CATransform3DRotate(dismissTransform, -M_PI/2, 1, 0, 0);
            presentTransform = CATransform3DRotate(presentTransform, M_PI/2, 1, 0, 0);
            break;
        case LPDoorBottomSide:
            [self applyAnchorPoint:CGPointMake(0.5, 1) forLayer:fromViewController.view.layer];
            dismissTransform = CATransform3DRotate(dismissTransform, M_PI/2, 1, 0, 0);
            presentTransform = CATransform3DRotate(presentTransform, -M_PI/2, 1, 0, 0);
            break;
    }
    
    [UIView beginAnimations:@"WPStylePushAnimation" context:nil];
    [UIView setAnimationDuration:duration*1/3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    {
        fromViewController.view.layer.transform = dismissTransform;
        fromViewController.view.layer.opacity = 0.0f;
    }
    [UIView commitAnimations];

    NSInteger toVCIndex = [self.viewControllers indexOfObject:toViewController];
    NSArray *viewControllers = [self.viewControllers subarrayWithRange:NSMakeRange(toVCIndex+1, self.viewControllers.count-toVCIndex-1)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration*1/3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [super popToViewController:toViewController animated:NO];
        
        switch (self.side) {
            case LPDoorLeftSide:
                [self applyAnchorPoint:CGPointMake(0, 0.5) forLayer:toViewController.view.layer];
                break;
            case LPDoorRightSide:
                [self applyAnchorPoint:CGPointMake(1, 0.5) forLayer:toViewController.view.layer];
                break;
            case LPDoorTopSide:
                [self applyAnchorPoint:CGPointMake(0.5, 0) forLayer:toViewController.view.layer];
                break;
            case LPDoorBottomSide:
                [self applyAnchorPoint:CGPointMake(0.5, 1) forLayer:toViewController.view.layer];
                break;
        }
        
        toViewController.view.layer.transform = presentTransform;
        toViewController.view.layer.opacity = 0.0f;
        
        [UIView beginAnimations:@"WPStylePushAnimation" context:nil];
        [UIView setAnimationDuration:duration*2/3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        {
            toViewController.view.layer.opacity = 1.0f;
            toViewController.view.layer.transform = CATransform3DIdentity;
        }
        [UIView commitAnimations];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration*2/3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            fromViewController.view.layer.transform = CATransform3DIdentity;
            fromViewController.view.layer.opacity = 1.0f;
            
            fromViewController.view.layer.anchorPoint = oldFromViewControllerAnchorPoint;
            fromViewController.view.layer.position = oldFromViewControllerPosition;
            
            toViewController.view.layer.anchorPoint = oldToViewControllerAnchorPoint;
            toViewController.view.layer.position = oldToViewControllerPosition;
            
            fromViewController.view.userInteractionEnabled = YES;
            toViewController.view.userInteractionEnabled = YES;
        });
    });
    return viewControllers;
}

- (void)applyAnchorPoint:(CGPoint)anchorPoint forLayer:(CALayer *)layer {
    layer.anchorPoint = anchorPoint;
    layer.position = CGPointMake(layer.bounds.origin.x+layer.bounds.size.width*anchorPoint.x, layer.bounds.origin.y+layer.bounds.size.height*anchorPoint.y);
}

@end
