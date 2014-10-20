/**
 The MIT License (MIT)
 
 Copyright (c) 2014 Igor Savelev (Leonspok)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "LP3DResponsiveView.h"

#define MAX_ANIMATION_DURATION 0.0
#define MAX_ROTATION_ANGLE M_PI/9
#define MAX_ROTATION_RATIO 1.5
#define ANIMATION_NAME @"LP3DResponsibleViewAnimation"

@implementation LP3DResponsiveView {
    BOOL touchPerforming;
}

- (id)init {
    self = [super init];
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
    self.maxRotationAngle = MAX_ROTATION_ANGLE;
    self.maxAnimationDuration = MAX_ANIMATION_DURATION;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.nextResponder touchesBegan:touches withEvent:event];
    if (event.type == UIEventTypeTouches && touches.count == 1) {
        [self responseToBeginTouch:[touches anyObject]];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self.nextResponder touchesMoved:touches withEvent:event];
    if (event.type == UIEventTypeTouches && touches.count == 1 && touchPerforming) {
        [self responseToBeginTouch:[touches anyObject]];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self.nextResponder touchesEnded:touches withEvent:event];
    if (event.type == UIEventTypeTouches && touches.count == 1) {
        [self responseToEndTouch:[touches anyObject]];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self.nextResponder touchesCancelled:touches withEvent:event];
    if (event.type == UIEventTypeTouches && touches.count == 1) {
        [self responseToEndTouch:[touches anyObject]];
    }
}

- (void)responseToBeginTouch:(UITouch *)touch {
    touchPerforming = YES;
    CGPoint location = [touch locationInView:self];

    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGVector vector = CGVectorMake(location.x - center.x, location.y - center.y);
    
    CGFloat length = sqrt((location.x-center.x)*(location.x-center.x)+(location.y-center.y)*(location.y-center.y));
    CGFloat edgeDistance1 = self.bounds.size.height*length/(2*ABS(vector.dy));
    CGFloat edgeDistance2 = self.bounds.size.width*length/(2*ABS(vector.dx));
    CGFloat edgeDistance = MIN(edgeDistance1, edgeDistance2);
    
    CGFloat rotatingRatio = length/edgeDistance;
    
    if (rotatingRatio > 1.0 && rotatingRatio < MAX_ROTATION_RATIO) {
        return;
    } else if (rotatingRatio >= MAX_ROTATION_RATIO) {
        [self responseToEndTouch:touch];
        return;
    }
    
    CGFloat angle = self.maxRotationAngle*rotatingRatio;
    
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DRotate(transform, angle, vector.dy, -vector.dx, 0);
    
    [UIView beginAnimations:ANIMATION_NAME context:nil];
    [UIView setAnimationDuration:self.maxAnimationDuration*rotatingRatio];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    {
        self.layer.transform = transform;
    }
    [UIView commitAnimations];
}

- (void)responseToEndTouch:(UITouch *)touch {
    CATransform3D transform = CATransform3DIdentity;
    
    [UIView beginAnimations:ANIMATION_NAME context:nil];
    [UIView setAnimationDuration:self.maxAnimationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    {
        self.layer.transform = transform;
    }
    [UIView commitAnimations];
    
    touchPerforming = NO;
}

@end
