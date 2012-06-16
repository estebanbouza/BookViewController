//
//  BookHalfPageView.m
//  BookViewController
//
//  Created by Esteban on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "old_BookHalfPageView.h"
#import <QuartzCore/QuartzCore.h>

#define degreesToRadians(__ANGLE__) (__ANGLE__) * M_PI / 180.0f
#define radiansToDegrees(__ANGLE__) (__ANGLE__) * (180.0f / M_PI)

#define kAnchorPoint        CGPointMake(0.5f, 0.5f);
#define kXVector            0.0f
#define kYVector            1.0f
#define kZVector            0.0f

@interface old_BookHalfPageView()

@property (nonatomic, retain) NSArray *views;
@property (nonatomic, retain) UIImage *leftImage;
@property (nonatomic, retain) UIImage *rightImage;
@property (nonatomic, assign) CGPoint xPointStart;
@property (nonatomic, retain) UIView *currentView;
@property (nonatomic, retain) UIView *nextView;

@property (nonatomic, retain) UIImageView *leftImageView;
@property (nonatomic, retain) UIImageView *rightImageView;

@property (nonatomic, assign) BOOL isMoving;

@end


@implementation old_BookHalfPageView

@synthesize views = _views;
@synthesize leftImage = _leftImage;
@synthesize rightImage = _rightImage;
@synthesize xPointStart = _xPointStart;
@synthesize currentView = _currentView;
@synthesize leftImageView, rightImageView, isMoving;
@synthesize nextView = _nextView;

- (id)initWithFrame:(CGRect)frame views:(NSArray *)views
{
    self = [super initWithFrame:frame];
    if (self) {
        self.views = views;
        
        self.currentView = [views objectAtIndex:0];
        self.currentView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.currentView.layer.anchorPoint = kAnchorPoint;
        
        self.nextView = [views objectAtIndex:1];
        self.nextView.frame = self.currentView.frame;
        self.nextView.layer.anchorPoint = kAnchorPoint;
        self.nextView.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
        
        [self addSubview:self.nextView];
        [self addSubview:self.currentView];
        
        self.isMoving = NO;
    }
    return self;
}

- (UIImage *)imageForView:(UIView *)view leftHalf:(BOOL)leftHalf
{
    CGFloat scale = 1.0;
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    CGRect cropRect;
    if (leftHalf) {
        cropRect = CGRectMake(0, 0, CGRectGetWidth(view.frame)/2, CGRectGetHeight(view.frame));
    } else {
        cropRect = CGRectMake(CGRectGetWidth(view.frame)/2, 0,  CGRectGetWidth(view.frame)/2, CGRectGetHeight(view.frame));
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([img CGImage], cropRect);
    img = [UIImage imageWithCGImage:imageRef];
    //    [UIImageView setImage:[UIImage imageWithCGImage:imageRef]]; 
    CGImageRelease(imageRef);
    
    return img;
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.xPointStart = [[touches anyObject] locationInView:self];
    
    if (!self.isMoving) {
        self.isMoving = YES;
        self.leftImage = [self imageForView:self leftHalf:YES];
        self.rightImage = [self imageForView:self leftHalf:NO];
        
        self.leftImageView = [[[UIImageView alloc] initWithImage:self.leftImage] autorelease];
        self.rightImageView = [[[UIImageView alloc] initWithImage:self.rightImage] autorelease];
        
        self.leftImageView.frame = CGRectMake(0,
                                              0,
                                              self.leftImage.size.width,
                                              self.leftImage.size.height);
        
        self.rightImageView.frame = CGRectMake(self.leftImage.size.width,
                                               0,
                                               self.rightImage.size.width,
                                               self.rightImage.size.height);
        
        self.rightImageView.backgroundColor = [UIColor blueColor];
        
        self.leftImageView.layer.anchorPoint = self.rightImageView.layer.anchorPoint = kAnchorPoint;
        
        [self.currentView removeFromSuperview];
        [self addSubview:self.leftImageView];
        [self addSubview:self.rightImageView];
    }
    
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGFloat xpoint = self.xPointStart.x - [[touches anyObject] locationInView:self].x;
    CGFloat angle = xpoint/CGRectGetWidth(self.frame) * 180.0f;
    angle = degreesToRadians(angle);
    
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0f/1000.0f;
    CGFloat xtrans = self.frame.size.width/4.0f;
    transform = CATransform3DTranslate(transform,
                                       -xtrans, 
                                       0,
                                       0);
    
    transform = CATransform3DRotate(transform, angle, kXVector, kYVector, kZVector);
    transform = CATransform3DTranslate(transform,
                                       xtrans,
                                       0,
                                       0);
    
    self.rightImageView.layer.transform = transform;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
