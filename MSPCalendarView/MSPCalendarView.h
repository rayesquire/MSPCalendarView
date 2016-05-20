//
//  MSPCalendarView.h
//  SZCalendarPicker
//
//  Created by 马了个马里奥 on 16/5/18.
//  Copyright © 2016年 Stephen Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,MSPCalendarViewStyle){
    MSPCalendarViewStyleCircle,        // cell is circle
    MSPCalendarViewStyleRectangle      // default, cell is rectangle
};

typedef NS_ENUM(NSInteger,MSPCalendarViewModel){
    MSPCalendarViewModelSingle,        // only be used to check current month
    MSPCalendarViewModelDefault        // default
};

@protocol MSPCalendarViewDelegate <NSObject>

@optional
- (void)didSelectItemAtDay:(NSInteger)day;

@end

@interface MSPCalendarView : UIView

@property (nonatomic, readwrite, strong) UIColor *pastColor;

@property (nonatomic, readwrite, strong) UIColor *todayColor;

@property (nonatomic, readwrite, strong) UIColor *futureColor;

@property (nonatomic, readwrite, strong) UIColor *selectedTitleColor;

@property (nonatomic, readwrite, strong) UIColor *selectedBackgroundColor;

@property (nonatomic, readwrite, strong) UIColor *themeColor;

@property (nonatomic, readwrite, assign) BOOL titleHiden;

@property (nonatomic, readwrite, assign) BOOL buttonHidden;

@property (nonatomic, readwrite, weak) id<MSPCalendarViewDelegate> delegate;


+ (MSPCalendarView *)calendarViewWithFrame:(CGRect)frame style:(MSPCalendarViewStyle)style model:(MSPCalendarViewModel)model;

@end
