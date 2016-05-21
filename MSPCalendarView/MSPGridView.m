//
//  MSPGridView.m
//  MSPCalendarView
//
//  Created by 马了个马里奥 on 16/5/20.
//  Copyright © 2016年 马了个马里奥. All rights reserved.
//

#import "MSPGridView.h"
#define SINGLE_LINE_WIDTH           (1 / [UIScreen mainScreen].scale)
#define SINGLE_LINE_ADJUST_OFFSET   ((1 / [UIScreen mainScreen].scale) / 2)

@interface MSPGridView ()

@property (nonatomic, readwrite, assign) CGFloat width;

@property (nonatomic, readwrite, assign) CGFloat height;

@property (nonatomic, readwrite, strong) UIView *maskView;

@end

@implementation MSPGridView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _height = frame.size.height;
        _width = frame.size.width;
        _partHidden = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// transform event
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return false;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGFloat lineMargin = _width / 7;
    //仅当要绘制的线宽为奇数像素时，绘制位置需要调整
    CGFloat pixelAdjustOffset = 0;
    if (((int)[UIScreen mainScreen].scale + 1) % 2 == 0) {
        pixelAdjustOffset = SINGLE_LINE_ADJUST_OFFSET;
    }
    CGFloat xPos = 0 - pixelAdjustOffset;
    CGFloat yPos = 0 - pixelAdjustOffset;
    while (xPos <= _width) {
        CGContextMoveToPoint(context, xPos, 0);
        CGContextAddLineToPoint(context, xPos, _height);
        xPos += lineMargin;
    }
    while (yPos <= _height) {
        CGContextMoveToPoint(context, 0, yPos);
        CGContextAddLineToPoint(context, _width, yPos);
        yPos += lineMargin;
    }
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1].CGColor);
    CGContextStrokePath(context);
}

- (void)setPartHidden:(BOOL)partHidden {
    _partHidden = partHidden;
    if (partHidden) {
        [self addSubview:self.maskView];
    }
    else {
        if (_maskView) {
            [self.maskView removeFromSuperview];
        }
    }
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height * 6 / 7 + 1, self.frame.size.width, self.frame.size.height / 7)];
        _maskView.backgroundColor = [UIColor whiteColor];
    }
    return _maskView;
}

@end
