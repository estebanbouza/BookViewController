//
//  BookHalfPageView.m
//  BookViewController
//
//  Created by Esteban on 4/14/12.
//  Copyright (c) 2012 EstebanBouza. All rights reserved.
//

#import "BookHalfPageView.h"
#import <QuartzCore/QuartzCore.h>

#define kZDistance 1000.0f

#define kRectLeftImage      CGRectMake(0, 0, self.frame.size.width/2, self.frame.size.height)
#define kRectRightImage     CGRectMake(self.frame.size.width/2, 0, self.frame.size.width/2, self.frame.size.height)

#define kFlipAnimationDuration      0.5f;

@interface BookHalfPageView()

typedef enum {
    kPreviousPage,
    kCurrentPage,
    kNextPage
} t_pageToShow;

typedef enum {
    kPageLeft,
    kPageRight,
    kPageNone
} t_pageToMove;

@property (nonatomic, retain) NSArray *views;

// Hold a reference to the previous, current and next view
@property (nonatomic, retain) UIView *prevView;
@property (nonatomic, retain) UIView *currView;
@property (nonatomic, retain) UIView *nextView;

// Two image views used during the page flip
@property (nonatomic, retain) UIImageView *currLeftImageView;
@property (nonatomic, retain) UIImageView *currRightImageView;

// Screenshots of the images
@property (nonatomic, retain) UIImage *currRightImage;
@property (nonatomic, retain) UIImage *currLeftImage;
@property (nonatomic, retain) UIImage *nextImage;

// Starting point of a touch event
@property (nonatomic, assign) CGFloat xstart;

// Current page in the book view
@property (nonatomic, assign) NSInteger currPage;

// Next page to show during a page flip
@property (nonatomic, assign) t_pageToShow nextPageToShow;

// Reference to the last angle
@property (nonatomic, assign) CGFloat lastAngle;

// Current page being moved
@property (nonatomic, assign) t_pageToMove pageToMove;

@end


@implementation BookHalfPageView

@synthesize views = _views;
@synthesize prevView = _prevView;
@synthesize currView = _currView;
@synthesize nextView = _nextView;
@synthesize xstart;
@synthesize currLeftImageView, currRightImageView;
@synthesize currPage;
@synthesize nextImage = _nextImage;
@synthesize currLeftImage, currRightImage;
@synthesize nextPageToShow = _nextPageToShow;
@synthesize lastAngle = _lastAngle;
@synthesize pageToMove = _pageToMove;

- (id)initWithFrame:(CGRect)frame views:(NSArray *)views
{
    self = [super initWithFrame:frame];
    
    if (self) {
        CATransform3D baseTransform =  CATransform3DIdentity;
        baseTransform.m34 = -1.0f / kZDistance;
        self.layer.sublayerTransform = baseTransform;
        
        [self initDefaultValues];
        
        self.views = views;
        
        self.prevView = nil;
        self.currView = self.views.count >= 1 ? [self.views objectAtIndex:0] : nil;
        self.nextView = self.views.count >= 2 ? [self.views objectAtIndex:1] : nil;
        
        [self addSubview:self.currView];
        
    }
    
    return self;
}

- (void)initDefaultValues {
    self.prevView = self.currView = self.nextView = nil;
    self.nextPageToShow = kCurrentPage;
    self.clipsToBounds = NO;    
    self.currPage = 0;
    self.lastAngle = 0.0f;
    self.pageToMove = kPageNone;
}

#pragma mark - utils

// Returns an UIImage from a view.
// leftHalft indecates whether the image to take should be the left or right half.
- (UIImage *)imageForView:(UIView *)view leftHalf:(BOOL)leftHalf rotated:(BOOL)rotated {
    CGFloat scale = 1.0;
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, scale);
    
    if (rotated) {
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), view.frame.size.width, 0);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), -1, 1);
        leftHalf = !leftHalf;
    }
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGRect cropRect;
    CGFloat xcrop = leftHalf ? 0 : CGRectGetWidth(view.frame)/2.0f;
    cropRect = CGRectMake(xcrop, 0, CGRectGetWidth(view.frame)/2.0f, CGRectGetHeight(view.frame));
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([img CGImage], cropRect);
    
    img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return img;
}


- (void)rotateView:(UIView *)view angle:(CGFloat)angle pageToMove:(t_pageToMove)pageToMove{
    CALayer *layer = view.layer;
    CATransform3D transform;
    
    if (pageToMove == kPageRight) {
        transform = CATransform3DIdentity;
        transform = CATransform3DTranslate(transform, -CGRectGetWidth(self.frame) / 4.0f, 0, 0);
        transform = CATransform3DRotate(transform, angle, 0, 1, 0);
        transform = CATransform3DTranslate(transform, CGRectGetWidth(self.frame) / 4.0f, 0, 0);
    } else if (pageToMove == kPageLeft) {
        transform = CATransform3DIdentity;
        transform = CATransform3DTranslate(transform, CGRectGetWidth(self.frame) / 4.0f, 0, 0);
        transform = CATransform3DRotate(transform, angle, 0, 1, 0);
        transform = CATransform3DTranslate(transform, -CGRectGetWidth(self.frame) / 4.0f, 0, 0);
    }
    
    layer.transform = transform;
}


// Returns a constrained angle between 0 and PI depending on the page to move
- (CGFloat)constrainedAngle:(CGFloat)angle pageToMove:(t_pageToMove)pageToMove {
    switch (pageToMove) {
        case kPageRight:
            if (angle < -M_PI) {
                return -M_PI;
            } else if (angle > 0.0f) {
                return 0.0f;
            }
            return angle;
            
            break;
            
        case kPageLeft:
            if (angle > M_PI) {
                return M_PI;
            } else if (angle < 0.0f) {
                return 0.0f;
            }
            return angle;
            break;
            
        default:
            break;
    }
    return  -1;
}


#pragma mark - touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    // Store X coordinate of starting event
    self.xstart = [touch locationInView:self].x;
    
    // Decide which page to move based on the starting event.
    self.pageToMove = self.xstart < CGRectGetWidth(self.frame)/2 ? kPageLeft : kPageRight;
    
    // Store two half screenshots of the current view
    self.currLeftImage = [self imageForView:self.currView leftHalf:YES rotated:NO];
    self.currRightImage = [self imageForView:self.currView leftHalf:NO rotated:NO];
    
    // Create two image views based on the previous 
    self.currLeftImageView = [[[UIImageView alloc] initWithImage:self.currLeftImage] autorelease];
    self.currRightImageView = [[[UIImageView alloc] initWithImage:self.currRightImage] autorelease];
    self.currLeftImageView.frame = kRectLeftImage;
    self.currRightImageView.frame = kRectRightImage;
    
    UIImage *image;
    UIImageView *imageView;
    switch (self.pageToMove) {
        case kPageLeft:
            image = [self imageForView:self.prevView leftHalf:NO rotated:YES];
            imageView = [[UIImageView alloc] initWithImage:image];
            imageView.backgroundColor = [UIColor blueColor];
            imageView.center = CGPointMake(self.superview.center.x , self.superview.center.y - 240);
            
            [self.superview addSubview:imageView];
            self.nextImage = image;
            [self insertSubview:self.prevView belowSubview:self.currView];
            break;
            
        case kPageRight:
            // Store the next image to show in the other side of the current page
            self.nextImage = [self imageForView:self.nextView leftHalf:YES rotated:YES];
            
            // Insert the view below the current view
            [self insertSubview:self.nextView belowSubview:self.currView];
            break;
            
        default:
            break;
    }
    
    // Remove the current view and replace it by two half images we created before.
    [self.currView removeFromSuperview];
    [self addSubview:self.currLeftImageView];
    [self addSubview:self.currRightImageView];
    
}



- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    // Calculate the touch movement based on the start point
    CGFloat xpoint = [touch locationInView:self].x - self.xstart;
    
    // Get the angle based on the movement
    CGFloat angle = [self constrainedAngle:xpoint / CGRectGetWidth(self.frame) * M_PI pageToMove:self.pageToMove];
    
    UIView *viewToRotate = nil;
    
    // Moving to next page
    if (self.pageToMove == kPageRight) {
        // if we are moving the right page, set the right image view as the one to rotate
        viewToRotate = self.currRightImageView;
        
        // The first half of the movement will show the current page.
        // After the first half, the next page must be shown.
        if (angle < -M_PI_2 && self.nextPageToShow != kNextPage) {

            // Since the next page is already being shown, if the user stops moving touches
            // the next page must be shown in the animation.
            self.nextPageToShow = kNextPage;
            self.currRightImageView.image = self.nextImage;        
        } else if (angle >= -M_PI_2 && self.nextPageToShow != kCurrentPage) {
            
            // Since the angle is to small and the current page is being show, if the user
            // stops moving touches the current page must be shown in the animation.
            self.nextPageToShow = kCurrentPage;
            self.currRightImageView.image = self.currRightImage;
        }
        
        // Moving to previous page
    } else if (self.pageToMove == kPageLeft) {
        viewToRotate = self.currLeftImageView;
        if (angle < M_PI_2 && self.nextPageToShow != kCurrentPage) {
            self.nextPageToShow = kCurrentPage;
            self.currLeftImageView.image = self.currLeftImage;        
        } else if (angle >= M_PI_2 && self.nextPageToShow != kPreviousPage) {
            self.nextPageToShow = kPreviousPage;
            self.currLeftImageView.image = self.nextImage;
        }
    }
    \
    self.lastAngle = angle;
    
    [self rotateView:viewToRotate angle:angle pageToMove:self.pageToMove];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGFloat finalAngle;
    CALayer *layer = nil;
    
    if (self.nextPageToShow == kNextPage) {
        // Calculate the final angle for the next page
        finalAngle = (self.lastAngle < -M_PI_2) ? -M_PI : 0.0f;
        self.currRightImageView.frame = CGRectMake(CGRectGetWidth(self.frame)/4, 0, CGRectGetWidth(kRectRightImage), CGRectGetHeight(kRectRightImage));
        layer = self.currRightImageView.layer;
        layer.anchorPoint = CGPointMake(0.0f, 0.5f);
        
    } else if (self.nextPageToShow == kPreviousPage) {
        finalAngle = (self.lastAngle > M_PI_2) ? M_PI : 0.0f;
        self.currLeftImageView.frame = CGRectMake(CGRectGetWidth(self.frame)/4, 0, CGRectGetWidth(kRectRightImage), CGRectGetHeight(kRectRightImage));
        layer = self.currLeftImageView.layer;
        layer.anchorPoint = CGPointMake(1.0f, 0.5f);
    }
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D transformTo = CATransform3DIdentity;
    transformTo = CATransform3DRotate(transformTo, finalAngle, 0, 1, 0);
    
    
    CATransform3D transformFrom = CATransform3DIdentity;
    transformFrom = CATransform3DMakeRotation(self.lastAngle, 0, 1, 0);
    animation.fromValue = [NSValue valueWithCATransform3D:transformFrom];
    animation.toValue = [NSValue valueWithCATransform3D:transformTo];
    animation.duration = kFlipAnimationDuration;
    animation.repeatCount = 0;
    animation.autoreverses = NO;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    animation.delegate = self;
    
    [layer addAnimation:animation forKey:nil];
    layer.transform = transformTo;    
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    // Restart the last angle
    self.lastAngle = 0.0f;
    
    // Remove the animating image views. Will be replaced for real views
    // in the following lines
    [self.currRightImageView removeFromSuperview];
    [self.currLeftImageView removeFromSuperview];
    
    
    switch (self.nextPageToShow) {
        case kNextPage:
            // Adjust current page
            self.currPage++;
            
            // Don't need to store the previous view any more since it's not going to be showing
            [self.prevView removeFromSuperview];
            
            // Adjust previous, current and next view
            self.prevView = self.currView;
            self.currView = self.nextView;
            self.nextView = (self.currPage + 1 < self.views.count) ? [self.views objectAtIndex:self.currPage + 1] : nil;
            
            // Add next view below the current view
            [self addSubview:self.nextView];
            [self addSubview:self.currView];
            break;
            
        case kCurrentPage:
            
            break;
            
        case kPreviousPage:
            self.currPage--;
            [self.nextView removeFromSuperview];
            self.nextView = self.currView;
            self.currView = self.prevView;
            self.prevView = (self.currPage - 1) >= 0 ? [self.views objectAtIndex:self.currPage - 1] : nil;
            [self addSubview:self.prevView];
            [self addSubview:self.currView];
            break;
            
        default:
            break;
    }
    
    // Restart the next page to shown and the page to move
    self.nextPageToShow = kCurrentPage;
    self.pageToMove = kPageNone;
    
}


@end
