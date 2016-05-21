//
//  MSPCalendarView.h
//  SZCalendarPicker
//
//  Created by 马了个马里奥 on 16/5/18.
//  Copyright © 2016年 Stephen Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,MSPCalendarViewModel){
    MSPCalendarViewModelSingle,        // only be used to check current month
    MSPCalendarViewModelDefault        // default
};

@protocol MSPCalendarViewDelegate <NSObject>

@optional
- (void)didSelectItemAtDay:(NSInteger)day;

@end

@interface MSPCalendarView : UIView


/**
 *   label color with the day before today
 */
@property (nonatomic, readwrite, strong) UIColor *pastColor;


/**
 *   label color with today
 */
@property (nonatomic, readwrite, strong) UIColor *todayColor;


/**
 *   label color with the day after today
 */
@property (nonatomic, readwrite, strong) UIColor *futureColor;


/**
 *   label color with selected day
 */
@property (nonatomic, readwrite, strong) UIColor *selectedTitleColor;


/**
 *   cell background color with selected day
 */
@property (nonatomic, readwrite, strong) UIColor *selectedBackgroundColor;


/**
 *   title view background color
 */
@property (nonatomic, readwrite, strong) UIColor *themeColor;


/**
 *   hide title or not
 */
@property (nonatomic, readwrite, assign) BOOL titleHiden;


/**
 *   hide last button and next button or not
 */
@property (nonatomic, readwrite, assign) BOOL buttonHidden;


/**
 *   delegate
 */
@property (nonatomic, readwrite, weak) id<MSPCalendarViewDelegate> delegate;


+ (MSPCalendarView *)calendarViewWithFrame:(CGRect)frame model:(MSPCalendarViewModel)model;

@end
