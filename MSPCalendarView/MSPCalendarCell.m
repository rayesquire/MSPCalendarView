//
//  MSPCalendarCell.m
//  SZCalendarPicker
//
//  Created by 马了个马里奥 on 16/5/18.
//  Copyright © 2016年 Stephen Zhuang. All rights reserved.
//

#import "MSPCalendarCell.h"

@implementation MSPCalendarCell

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        [_label setTextAlignment:NSTextAlignmentCenter];
        _label.font = [UIFont systemFontOfSize:17];
        [self addSubview:_label];
    }
    return _label;
}

@end
