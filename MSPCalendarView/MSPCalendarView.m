//
//  MSPCalendarView.m
//  SZCalendarPicker
//
//  Created by 马了个马里奥 on 16/5/18.
//  Copyright © 2016年 Stephen Zhuang. All rights reserved.
//

#import "MSPCalendarView.h"
#import "MSPCalendarCell.h"
#import "MSPGridView.h"

#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height
#define SINGLE_LINE_WIDTH           (1 / [UIScreen mainScreen].scale)
#define SINGLE_LINE_ADJUST_OFFSET   ((1 / [UIScreen mainScreen].scale) / 2)

NSString *const cellIdentifier = @"MSPCalendarCell";

@interface MSPCalendarView () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, readwrite, assign) MSPCalendarViewModel model;

@property (nonatomic, readwrite, strong) MSPGridView *gridView;

@property (nonatomic, readwrite, strong) UICollectionView *collectionView;

@property (nonatomic, readwrite, strong) UIView *themeView;

@property (nonatomic, readwrite, strong) UILabel *label;

@property (nonatomic, readwrite, strong) UIButton *leftButton;

@property (nonatomic, readwrite, strong) UIButton *rightButton;

@property (nonatomic, readwrite, copy) NSArray *titleArray;

@property (nonatomic, readwrite, strong) NSDate *todayDate;

@property (nonatomic, readwrite, strong) NSDate *settingDate;

@property (nonatomic, readwrite, assign) NSInteger selectedDay;

@property (nonatomic, readwrite, strong) UIColor *lastColor;

@end

@implementation MSPCalendarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
        [self addThemeView];
        [self addButton];
        [self addMainView];
        [self addGridView];
    }
    return self;
}

+ (MSPCalendarView *)calendarViewWithFrame:(CGRect)frame model:(MSPCalendarViewModel)model{
    MSPCalendarView *view = [[MSPCalendarView alloc] initWithFrame:frame];
    view.model = model;
    return view;
}

- (void)initialization {
    _pastColor = [UIColor blackColor];
    _todayColor = [UIColor colorWithRed:100/255.0 green:180/255.0 blue:248/255.0 alpha:1];
    _futureColor = [UIColor lightGrayColor];
    _selectedTitleColor = [UIColor whiteColor];
    _selectedBackgroundColor = [UIColor colorWithRed:100/255.0 green:180/255.0 blue:248/255.0 alpha:1];
    _themeColor = [UIColor colorWithRed:100/255.0 green:180/255.0 blue:248/255.0 alpha:1];
    _titleHiden = NO;
    _buttonHidden = NO;
    _titleArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    _todayDate = [NSDate date];
    _settingDate = [NSDate date];
    _selectedDay = 0;
    _lastColor = nil;
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
        self.collectionView.frame = CGRectMake(0, WIDTH / 7, WIDTH, WIDTH);
    }
    [self addSubview:self.collectionView];
}

- (void)addGridView {
    if (!_titleHiden) {
        _gridView = [[MSPGridView alloc] initWithFrame:CGRectMake(0, WIDTH / 7, WIDTH, WIDTH)];
        [self addSubview:_gridView];
    }
    else {
        _gridView = [[MSPGridView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, WIDTH)];
        [self addSubview:_gridView];
    }
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

- (NSDate *)lastMonth:(NSDate *)date{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = -1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

- (NSDate*)nextMonth:(NSDate *)date{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = +1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

#pragma mark - UICollectionView datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger firstDay = [self firstDayInThisMonth:self.settingDate];
    NSInteger daysInThisMonth = [self totalDaysInMonth:self.settingDate];
    if ((firstDay + daysInThisMonth) > 35) {
        collectionView.frame = CGRectMake(0, collectionView.frame.origin.y, WIDTH, WIDTH);
        if (_gridView) {
            [_gridView setPartHidden:NO];
        }
        return 7;
    }
    collectionView.frame = CGRectMake(0, collectionView.frame.origin.y, WIDTH, WIDTH * 6 / 7);
    if (_gridView) {
        [_gridView setPartHidden:YES];
    }
    return 6;
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
        NSInteger daysInThisMonth = [self totalDaysInMonth:self.settingDate];
        NSInteger firstDay = [self firstDayInThisMonth:self.settingDate];  //每个月第一天的位置
        NSInteger i = indexPath.item + (indexPath.section - 1) * 7;
        if (i >= firstDay && i < firstDay + daysInThisMonth) {
            NSInteger day = i - firstDay + 1;
            cell.label.text = [NSString stringWithFormat:@"%i",(int)day];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"YYYYMM"];
            NSString *settingString = [formatter stringFromDate:self.settingDate];
            NSString *todayString = [formatter stringFromDate:self.todayDate];
            if ([settingString isEqualToString:todayString]) {  // same month
                if (day == [self day:self.todayDate]) {
                    cell.label.textColor = _todayColor;
                }
                else if (day > [self day:self.todayDate]) {
                    cell.label.textColor = _futureColor;
                }
                else if (day < [self day:self.todayDate]) {
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
        else {
            cell.label.text = @"";
        }
        NSInteger value = [self year:self.settingDate] * 10000 + [self month:self.settingDate] * 100 + indexPath.item + (indexPath.section - 1) * 7 - [self firstDayInThisMonth:self.settingDate] + 1;
        if (value == _selectedDay) {
            cell.backgroundColor = _themeColor;
            cell.label.textColor = [UIColor whiteColor];
        }
        else {
            cell.backgroundColor = [UIColor whiteColor];
        }
    }
    return cell;
}

#pragma mark - UICollectionView delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return;
    }
    else {
        NSInteger daysInThisMonth = [self totalDaysInMonth:self.settingDate];
        NSInteger firstDay = [self firstDayInThisMonth:self.settingDate];
        NSInteger i = indexPath.item + (indexPath.section - 1) * 7;
        NSInteger value = [self year:self.settingDate] * 10000 + [self month:self.settingDate] * 100 + i - firstDay + 1;
        // click same cell, nothing will happen
        if (value == _selectedDay) {
            return;
        }
        // click other cell
        MSPCalendarCell *cell = (MSPCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (i < firstDay || i >= (firstDay + daysInThisMonth)) {
            return;
        }
        else {
            // 点击cell和之前选中的cell在同一界面下
            if (_selectedDay / 10000 == [self year:_settingDate] && _selectedDay % 10000 / 100 == [self month:_settingDate]) {
                NSInteger x = _selectedDay % 100 - 1 + firstDay;
                NSInteger item = x % 7;
                NSInteger section = (x - item) / 7 + 1;
                NSIndexPath *path = [NSIndexPath indexPathForItem:item inSection:section];
                MSPCalendarCell *lastCell = (MSPCalendarCell *)[collectionView cellForItemAtIndexPath:path];
                lastCell.label.textColor = _lastColor;
                lastCell.backgroundColor = [UIColor whiteColor];
            }
            _lastColor = cell.label.textColor;
            _selectedDay = value;
            cell.backgroundColor = _selectedBackgroundColor;
            cell.label.textColor = _selectedTitleColor;
        }
        if (self.delegate &&[self.delegate respondsToSelector:@selector(didSelectItemAtDay:)]) {
            [self.delegate didSelectItemAtDay:value];
        }
    }
}

- (void)leftClick {
    [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCurlDown animations:^(void) {
        self.settingDate = [self lastMonth:_settingDate];
        self.label.text = [self stringFromDate:self.settingDate];
    } completion:nil];
}

- (void)rightClick {
    [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCurlUp animations:^(void) {
        self.settingDate = [self nextMonth:_settingDate];
        self.label.text = [self stringFromDate:self.settingDate];
    } completion:nil];
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
    _selectedTitleColor = selectedTitleColor;
    [_collectionView reloadData];
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor {
    _selectedBackgroundColor = selectedBackgroundColor;
    [_collectionView reloadData];
}

- (void)setThemeColor:(UIColor *)themeColor {
    _themeColor = themeColor;
    _themeView.backgroundColor = themeColor;
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

- (void)setSettingDate:(NSDate *)settingDate {
    _settingDate = settingDate;
    [_collectionView reloadData];
}

- (void)setModel:(MSPCalendarViewModel)model {
    _model = model;
    if (_model == MSPCalendarViewModelSingle) {
        _buttonHidden = YES;
    }
}

- (NSString *)stringFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/YYYY"];
    return [formatter stringFromDate:date];
}

#pragma mark - lazy load
- (UILabel *)label {
    if (!_label) {
        NSString *text = [self stringFromDate:[NSDate date]];
        CGSize size = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]}];
        _label = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - size.width) / 2, (WIDTH / 7 - size.height) / 2, size.width + 20, size.height)];
        _label.font = [UIFont systemFontOfSize:18];
        _label.textColor = [UIColor whiteColor];
        _label.text = text;
    }
    return _label;
}

- (UIView *)themeView {
    if (!_themeView) {
        _themeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, WIDTH / 7)];
        _themeView.backgroundColor = _themeColor;
    }
    return _themeView;
}

- (UIButton *)leftButton {
    if (!_leftButton) {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftButton.frame = CGRectMake(5, 10, WIDTH / 7 - 20, WIDTH / 7 - 20);
        [_leftButton setImage:[UIImage imageNamed:@"bt_previous"] forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(leftClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.frame = CGRectMake(WIDTH * 6 / 7 + 5, 10, WIDTH / 7 - 20, WIDTH / 7 - 20);
        [_rightButton setImage:[UIImage imageNamed:@"bt_next"] forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(rightClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.itemSize = CGSizeMake(WIDTH / 7, WIDTH / 7);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, WIDTH) collectionViewLayout:layout];
        [_collectionView registerClass:[MSPCalendarCell class] forCellWithReuseIdentifier:cellIdentifier];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsVerticalScrollIndicator = NO;
    }
    return _collectionView;
}

@end
