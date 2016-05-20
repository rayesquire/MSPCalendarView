//
//  ViewController.m
//  MSPCalendarView
//
//  Created by 马了个马里奥 on 16/5/18.
//  Copyright © 2016年 马了个马里奥. All rights reserved.
//

#import "ViewController.h"
#import "MSPCalendarView.h"

@interface ViewController () <MSPCalendarViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MSPCalendarView *view = [MSPCalendarView calendarViewWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width) style:MSPCalendarViewStyleRectangle model:MSPCalendarViewModelDefault];
    view.delegate = self;
    [self.view addSubview:view];

}

- (void)didSelectItemAtDay:(NSInteger)day {
    NSLog(@"value:%d",(int)day);
}

@end
