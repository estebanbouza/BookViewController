//
//  BookDoublePageView.m
//  BookViewController
//
//  Created by Esteban on 4/1/12.
//  Copyright (c) 2012 EstebanBouza. All rights reserved.
//

#import "BookDoublePageView.h"
#import <QuartzCore/QuartzCore.h>

#define degreesToRadians(__ANGLE__) (__ANGLE__) * M_PI / 180.0f
#define radiansToDegrees(__ANGLE__) (__ANGLE__) * (180.0f / M_PI)

#define kDistance           1500.0f
#define kAngleMultiplier    1.3f

#define kAnchorPoint        CGPointMake(0.0f, 0.5f);
#define kXVector            0.0f
#define kYVector            1.0f
#define kZVector            0.0f

#define kAngleMaxf          180.0f
#define kAngleMax           180

#define kFloatDelta         0.01f

#define kFlipAnimationDuration  0.3f;




@interface BookDoublePageView()

@property (nonatomic, retain) NSArray *views;

@end


@implementation BookDoublePageView

@synthesize views = _views;

- (id)initWithFrame:(CGRect)frame views:(NSArray *)views {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.views = views;
        
        self.backgroundColor = [UIColor darkGrayColor];
        
        NSEnumerator *enumerator = [views reverseObjectEnumerator];
        
        NSInteger i = views.count - 1;
        for (UIView *aview in enumerator) {
            
            aview.frame = CGRectMake(i*10, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
            aview.layer.anchorPoint = kAnchorPoint;
            [self addSubview:aview];
            
            if (!(i%2)) {
                CATransform3D transform = CATransform3DIdentity;
                transform.m34 = - 1.0 / kDistance;
                transform = CATransform3DRotate(transform, degreesToRadians(180.0), kXVector, kYVector, kZVector);
                
                aview.layer.transform = transform;
            }
            
            i--;
            
        }
                
        CATransform3D perspective = CATransform3DIdentity;
        perspective.m34 = 1 / -kDistance;
        self.layer.sublayerTransform = perspective;
        
    }
    return self;
}




@end
