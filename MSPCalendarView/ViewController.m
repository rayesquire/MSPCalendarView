//
//  ViewController.m
//  MSPCalendarView
//
//  Created by 马了个马里奥 on 16/5/18.
//  Copyright © 2016年 马了个马里奥. All rights reserved.
//

#import "ViewController.h"
#import "MSPCalendarView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MSPCalendarView *view = [[MSPCalendarView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width)];
    [self.view addSubview:view];

}

@end
