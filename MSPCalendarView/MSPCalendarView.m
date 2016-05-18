//
//  MSPCalendarView.m
//  SZCalendarPicker
//
//  Created by 马了个马里奥 on 16/5/18.
//  Copyright © 2016年 Stephen Zhuang. All rights reserved.
//

#import "MSPCalendarView.h"
#import "MSPCalendarCell.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

NSString *const cellIdentifier = @"MSPCalendarCell";

@interface MSPCalendarView () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, readwrite, assign) MSPCalendarViewStyle style;

@property (nonatomic, readwrite, assign) MSPCalendarViewModel model;

@property (nonatomic, readwrite, strong) UICollectionView *collectionView;

@property (nonatomic, readwrite, strong) UIView *themeView;

@property (nonatomic, readwrite, strong) UILabel *label;

@property (nonatomic, readwrite, strong) UIButton *leftButton;

@property (nonatomic, readwrite, strong) UIButton *rightButton;

@property (nonatomic, readwrite, copy) NSArray *titleArray;

@property (nonatomic, readwrite, strong) NSDate *todayDate;

@property (nonatomic, readwrite, strong) NSDate *settingDate;

@end

@implementation MSPCalendarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
        [self addThemeView];
        [self addButton];
        [self addMainView];
    }
    return self;
}

+ (MSPCalendarView *)calendarViewWithFrame:(CGRect)frame style:(MSPCalendarViewStyle)style model:(MSPCalendarViewModel)model{
    MSPCalendarView *view = [[MSPCalendarView alloc] initWithFrame:frame];
    view.style = style;
    view.model = model;
    return view;
}

- (void)initialization {
    _pastColor = [UIColor blackColor];
    _todayColor = [UIColor colorWithRed:100/255.0 green:180/255.0 blue:248/255.0 alpha:1];
    _futureColor = [UIColor lightGrayColor];
    _selectedTitleColor = [UIColor whiteColor];
    _selectedBackgroundColor = [UIColor orangeColor];
    _themeColor = [UIColor colorWithRed:100/255.0 green:180/255.0 blue:248/255.0 alpha:1];
    _titleHiden = NO;
    _buttonHidden = NO;
    _titleArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    _todayDate = [NSDate date];
    _settingDate = [NSDate date];
}

- (void)addThemeView {
    if (!_titleHiden) {
        [self addSubview:self.themeView];
        [self.themeView addSubview:self.label];
    }
}

- (void)addButton {
    if (!_titleHiden && !_buttonHidden) {
        [self.themeView addSubview:self.leftButton];
        [self.themeView addSubview:self.rightButton];
    }
}

- (void)addMainView {
    if (!_titleHiden) {
        self.collectionView.frame = CGRectMake(0, SCREEN_WIDTH / 7, SCREEN_WIDTH, SCREEN_WIDTH);
    }
    [self addSubview:self.collectionView];
}

#pragma mark - NSDate
- (NSInteger)day:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return components.day;
}

- (NSInteger)month:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return components.month;
}

- (NSInteger)year:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return components.year;
}

- (NSInteger)firstDayInThisMonth:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar setFirstWeekday:1];
    NSDateComponents *comp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [comp setDay:1];
    NSDate *firstDayOfMonthDate = [calendar dateFromComponents:comp];
    
    NSUInteger firstWeekday = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:firstDayOfMonthDate];
    return firstWeekday - 1;
}

- (NSInteger)totalDaysInMonth:(NSDate *)date {
    NSRange daysInLastMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return daysInLastMonth.length;
}

#pragma mark - UICollectionView datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 7;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MSPCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.label.text = _titleArray[indexPath.item];
        cell.label.textColor = _themeColor;
    }
    else {
        NSInteger daysInThisMonth = [self totalDaysInMonth:_todayDate];
        NSInteger firstDay = [self firstDayInThisMonth:_todayDate];  //每个月第一天的位置
        
        NSInteger i = indexPath.item + (indexPath.section - 1) * 7;
        if (i >= firstDay && i <= firstDay + daysInThisMonth) {
            NSInteger day = i - firstDay + 1;
            cell.label.text = [NSString stringWithFormat:@"%i",(int)day];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"YYYYMM"];
            NSString *settingString = [formatter stringFromDate:_settingDate];
            NSString *todayString = [formatter stringFromDate:_todayDate];
            if ([settingString isEqualToString:todayString]) {  // same month
                if (day == [self day:_todayDate]) {
                    cell.label.textColor = _todayColor;
                }
                else if (day > [self day:_todayDate]) {
                    cell.label.textColor = _futureColor;
                }
                else if (day < [self day:_todayDate]) {
                    cell.label.textColor = _pastColor;
                }
            }
            else if ([settingString integerValue] > [todayString integerValue]) {
                cell.label.textColor = _futureColor;
            }
            else {
                cell.label.textColor = _pastColor;
            }
        }
    }
    return cell;
}

- (void)leftClick {
    
}

- (void)rightClick {
    
}

#pragma mark - setter
- (void)setFutureColor:(UIColor *)futureColor {
    _futureColor = futureColor;
    [self.collectionView reloadData];
}

- (void)setPastColor:(UIColor *)pastColor {
    _pastColor = pastColor;
    [self.collectionView reloadData];
}

- (void)setTodayColor:(UIColor *)todayColor {
    _todayColor = todayColor;
    [self.collectionView reloadData];
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor {
    
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor {
    
}

- (void)setTitleHiden:(BOOL)titleHiden {
    _titleHiden = titleHiden;
    [self.collectionView removeFromSuperview];
    self.collectionView = nil;
    [self addMainView];
}

- (void)setButtonHidden:(BOOL)buttonHidden {
    _buttonHidden = buttonHidden;
    if (buttonHidden) {
        self.leftButton.hidden = YES;
        self.rightButton.hidden = YES;
    }
    else {
        self.leftButton.hidden = NO;
        self.rightButton.hidden = NO;
    }
}


#pragma mark - lazy load
- (UILabel *)label {
    if (!_label) {
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/YYYY"];
        NSString *text = [formatter stringFromDate:date];
        CGSize size = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]}];
        _label = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - size.width) / 2, (SCREEN_WIDTH / 7 - size.height) / 2, size.width, size.height)];
        _label.font = [UIFont systemFontOfSize:18];
        _label.textColor = [UIColor whiteColor];
        _label.text = text;
    }
    return _label;
}

- (UIView *)themeView {
    if (!_themeView) {
        _themeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH / 7)];
        _themeView.backgroundColor = _themeColor;
    }
    return _themeView;
}

- (UIButton *)leftButton {
    if (!_leftButton) {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftButton.frame = CGRectMake(5, 10, SCREEN_WIDTH / 7 - 20, SCREEN_WIDTH / 7 - 20);
        [_leftButton setImage:[UIImage imageNamed:@"bt_previous"] forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(leftClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.frame = CGRectMake(SCREEN_WIDTH * 6 / 7 + 5, 10, SCREEN_WIDTH / 7 - 20, SCREEN_WIDTH / 7 - 20);
        [_rightButton setImage:[UIImage imageNamed:@"bt_next"] forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(rightClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.itemSize = CGSizeMake(SCREEN_WIDTH / 7, SCREEN_WIDTH / 7);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH) collectionViewLayout:layout];
        [_collectionView registerClass:[MSPCalendarCell class] forCellWithReuseIdentifier:cellIdentifier];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsVerticalScrollIndicator = NO;
    }
    return _collectionView;
}

@end
