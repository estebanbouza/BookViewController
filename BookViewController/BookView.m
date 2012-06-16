//
//  BookView.m
//  BookViewController
//
//  Created by Esteban on 3/29/12.
//  Copyright (c) 2012 EstebanBouza. All rights reserved.
//

#import "BookView.h"
#define degreesToRadians(__ANGLE__) (__ANGLE__) * M_PI / 180.0f
#define radiansToDegrees(__ANGLE__) (__ANGLE__) * (180.0f / M_PI)

#define kDistance           1500.0f
#define kAngleMultiplier    1.3f

#define kAnchorPoint        CGPointMake(0.5f, 0.5f);
#define kXVector            0.0f
#define kYVector            1.0f
#define kZVector            0.0f

#define kAngleMaxf          180.0f
#define kAngleMax           180

#define kFloatDelta         0.01f

#define kFlipAnimationDuration  0.3f;

typedef enum {
    kMovementPageBack = 100,
    kMovementPageNext,
    kMovementPageNoMove
} t_movement;

typedef enum {
    kPageLeft = 10,
    kPageRight,
    kPageNone
} t_page;

typedef enum {
    kDirectionLeft,
    kDirectionRight
} t_direction;

@interface BookView()

@property (nonatomic, retain) UIView        *currentView;
@property (nonatomic, retain) UIView        *nextView;
@property (nonatomic, retain) UIView        *prevView;
@property (nonatomic, assign) CGFloat       xoffset;
@property (nonatomic, assign) CGFloat       lastAngle;
@property (nonatomic, assign) CGFloat       lastAngleTMP;
@property (nonatomic, assign) NSInteger     currentPage;
@property (nonatomic, retain) NSArray       *views;
@property (nonatomic, assign) t_movement    lastMovement;
@property (nonatomic, assign) t_page        pageToMove;

@end

@implementation BookView
@synthesize currentView = _currentView;
@synthesize nextView = _nextView;
@synthesize prevView = _prevView;
@synthesize xoffset = _xoffset;
@synthesize lastAngle = _lastAngle;
@synthesize lastAngleTMP = _lastAngleTMP;
@synthesize currentPage = _currentPage;
@synthesize views = _views;
@synthesize lastMovement = _lastMovement;
@synthesize pageToMove = _pageToMove;


- (id)initWithFrame:(CGRect)frame views:(NSArray *)views {
    self = [super initWithFrame:frame];
    if (self) {
        self.xoffset = 0.0f;
        self.lastAngle = 0.0f;
        self.lastAngleTMP = 0.0f;
        self.currentPage = 0.0f;
        self.lastMovement = kMovementPageNoMove;
        
        self.views = views;
        
        self.backgroundColor = [UIColor darkGrayColor];
        
        self.prevView = self.currentView = self.nextView = nil;
        
        NSEnumerator *enumerator = [views reverseObjectEnumerator];
        
        NSInteger i = views.count - 1;
        for (UIView *aview in enumerator) {

            aview.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
            aview.layer.anchorPoint = kAnchorPoint;
            [self addSubview:aview];
            
            if (i == 1) {
                self.nextView = aview;
            } else if (i == 0) {
                self.currentView = aview;
            }
            i--;
        }
        
        self.pageToMove = kPageNone;
        
//        CATransform3D perspective = CATransform3DIdentity;
//        perspective.m34 = 1 / -kDistance;
//        self.layer.sublayerTransform = perspective;
        
    }
    return self;
}

- (void)shiftArrayViewsDirectin:(t_direction)direction {

    if (direction == kDirectionRight) {
        self.nextView = self.currentView;
        self.currentView = self.prevView;
        if (self.currentPage > 0) {
            self.prevView = [self.views objectAtIndex:self.currentPage - 1];
        } else {
            self.prevView = nil;
        }
        
    } else if (direction == kDirectionLeft) {
        self.prevView = self.currentView;
        self.currentView = self.nextView;
        if (self.currentPage < [self.views count] - 1) {
            self.nextView = [self.views objectAtIndex:self.currentPage + 1];
        } else {
            self.nextView = nil;
        }
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([touches count] != 1) {
        NSLog(@"Warning, touches count = %d", [touches count]);
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    self.xoffset = point.x;
    
    
    if (point.x <= CGRectGetWidth(self.frame) / 2) {
        [self shiftArrayViewsDirectin:kDirectionRight];
        self.currentPage = self.currentPage - 1;
        NSLog(@"Page changed %d", self.currentPage);
        self.pageToMove = kPageLeft;
    } else {
        self.pageToMove = kPageRight;
    }
    
    if (self.pageToMove == kPageLeft) {
        self.lastAngle = -kAngleMaxf;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    CALayer *layer = [[self.views objectAtIndex:0] layer];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGFloat xevent = (point.x - self.xoffset) / (CGFloat)self.frame.size.width;
    
    xevent = -xevent;
    
    CGFloat angle = xevent * kAngleMaxf;
    angle = angle - self.lastAngle;
    
    if (angle > kAngleMaxf) {
        angle = kAngleMaxf;
    } else if (angle < -kAngleMaxf) {
        angle = -kAngleMaxf;
    } else if (angle < 0.0f) {
        angle = 0.0f;
    }
    angle = -angle;
    
    
//    CATransform3D transform = CATransform3DMakeRotation(degreesToRadians(angle), kXVector, kYVector, kZVector);
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = - 1.0/kDistance;
    transform = CATransform3DTranslate(transform, self.frame.size.width/2, self.frame.size.height/2, 0);
    transform = CATransform3DRotate(transform, degreesToRadians(angle), kXVector, kYVector, kZVector);
    transform = CATransform3DTranslate(transform, -self.frame.size.width/2, -self.frame.size.height/2, 0);

    layer.transform = transform;
    
    self.lastAngleTMP = angle;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CALayer *layer = self.currentView.layer;
    
    self.lastAngle = (CGFloat)((NSInteger) self.lastAngleTMP % (kAngleMax + 1));
    
    if ([self cgfloat:self.lastAngle isEqualToFloat:-kAngleMax] ||
        [self cgfloat:self.lastAngle isEqualToFloat:0.0f]) {
        [self handlePageMovementFinish];
        return;
    } else {
        
        CGFloat finalAngle;
        if (-self.lastAngleTMP < kAngleMaxf / 2) {
            finalAngle = 0.0f;
        } else {
            finalAngle = -kAngleMaxf;
        }
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        CATransform3D transform = CATransform3DMakeRotation(degreesToRadians(finalAngle), kXVector, kYVector, kZVector);
        
        animation.fromValue = [NSValue valueWithCATransform3D:layer.transform];
        animation.toValue = [NSValue valueWithCATransform3D:transform];
        animation.duration = kFlipAnimationDuration;
        animation.repeatCount = 0;
        animation.autoreverses = NO;
        animation.removedOnCompletion = YES;
        animation.fillMode = kCAFillModeForwards;
        animation.delegate = self;
        
        [layer addAnimation:animation forKey:nil];
        layer.transform = transform;
    }
    
}


- (void)handlePageMovementFinish {
    CALayer *layer = self.currentView.layer;
    
    CGFloat currentAngle = [[layer valueForKeyPath:@"transform.rotation.z"] floatValue];
    currentAngle = -radiansToDegrees(currentAngle);
    
    // Next page movement    
    if ([self cgfloat:currentAngle isEqualToFloat:-kAngleMax]
        && !(self.lastMovement == kMovementPageBack)
        ) {
        
        self.currentPage += 1;
        NSLog(@"Page changed %d", self.currentPage);
        
        [self shiftArrayViewsDirectin:kDirectionLeft];
        self.lastAngle = 0.0f;
        self.lastMovement = kMovementPageNext;
    } 
    // Back page movement
    else if ([self cgfloat:currentAngle isEqualToFloat:0.0f]
             && !(self.lastMovement == kMovementPageNext)
             ) {
        
        self.currentPage -= 1;
        NSLog(@"Page changed %d", self.currentPage);
        
        [self shiftArrayViewsDirectin:kDirectionRight];
        self.lastAngle = kAngleMaxf;
        self.lastMovement = kMovementPageBack;
    }
    [self bringSubviewToFront:self.currentView];
}


- (BOOL)cgfloat:(CGFloat)float1 isEqualToFloat:(CGFloat)float2 {
    if (fabsf((float2 - float1)) < kFloatDelta) {
        return YES;
    }
    return NO;
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)finished {
    if (finished) {
        [self handlePageMovementFinish];
    }
    
}

@end
