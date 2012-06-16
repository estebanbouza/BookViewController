//
//  BookHalfPageView.h
//  BookViewController
//
//  Created by Esteban on 4/14/12.
//  Copyright (c) 2012 EstebanBouza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookHalfPageView : UIView


// Init with parent view size and an array of UIViews to show
- (id)initWithFrame:(CGRect)frame views:(NSArray *)views;

@end
