//
//  ViewController.m
//  BookViewController
//
//  Created by Esteban on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "BookView.h"
#import "BookDoublePageView.h"
#import "BookHalfPageView.h"

#define kViewWidth 400
#define kViewHeight 250


@interface ViewController ()

@property (nonatomic, retain) BookView *bookView;
@property (nonatomic, retain) BookDoublePageView *bookDoublePageView;

@end

@implementation ViewController

@synthesize bookView = _bookView;
@synthesize bookDoublePageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    NSMutableArray *views = [[NSMutableArray alloc] init];
    for (int i = 0; i < 1; i++) {
        UIImageView *imgview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"img%d", i]]];
        imgview.contentMode = UIViewContentModeScaleAspectFill;
        imgview.clipsToBounds = YES;
        imgview.frame = CGRectMake(0, 0, kViewWidth, kViewHeight);

        [views addObject:imgview];
        [imgview release];
    }
    
    self.bookView = [[[BookView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, kViewHeight) views:views] autorelease];
    self.bookView.center = CGPointMake(self.view.center.x, self.view.center.y - 200);
    [self.view addSubview:self.bookView];
    
    [views release];
    

    
    views = [[NSMutableArray alloc] init];
    for (int i = 0; i < 6; i++) {
        UIImageView *imgview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"img%d", i]]];
        imgview.contentMode = UIViewContentModeScaleAspectFill;
        imgview.clipsToBounds = YES;
        imgview.frame = CGRectMake(0, 0, kViewWidth, kViewHeight);
        
        [views addObject:imgview];
        [imgview release];
    }
        
//    UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, kViewHeight)];
//    loadingView.backgroundColor = [UIColor lightGrayColor];
//    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kViewWidth/2, 30)];
//    loadingLabel.backgroundColor = [UIColor clearColor];
//    loadingLabel.textAlignment = UITextAlignmentCenter;
//    loadingLabel.text = @"Loading...";
//    loadingLabel.center = CGPointMake(kViewWidth/2, kViewHeight/2 - 30);
//    [loadingView addSubview:loadingLabel];
//    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    activity.hidesWhenStopped = NO;
//    activity.center = CGPointMake(kViewWidth/2, kViewHeight/2);
//    [activity startAnimating];
//    [loadingView addSubview:activity];
//    [views insertObject:loadingView atIndex:views.count/2/2];
//    
//    UIView *aTableView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, kViewHeight)];
//    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, kViewHeight)];
//    [aTableView addSubview:tableView];
//    [views insertObject:aTableView atIndex:views.count/2/2];
//
//    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, kViewHeight)];
//    buttonView.backgroundColor = [UIColor grayColor];
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [button setTitle:@"Press Me" forState:UIControlStateNormal];
//    button.center = buttonView.center;
//    [buttonView addSubview:button];
//    button.frame = CGRectMake(90, 50, 200, 150);
//    [views insertObject:buttonView atIndex:views.count/2/2];
    
    BookHalfPageView *bhpv = [[BookHalfPageView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, kViewHeight) views:views];
    bhpv.center = CGPointMake(self.view.center.x, self.view.center.y + 200);
    [self.view addSubview:bhpv];
    
    
    [views release];
}

- (UIView *)viewWithText:(NSString *)text color:(UIColor *)aColor {
    UIView *aView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, kViewHeight)] autorelease];
    aView.backgroundColor = aColor;

    UILabel *aLabel = [[[UILabel alloc] init] autorelease];
    aLabel.text = text;
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.font = [UIFont systemFontOfSize:22];
    [aLabel sizeToFit];
    aLabel.center = aView.center;
    [aView addSubview:aLabel];
    
    return aView;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

@end
