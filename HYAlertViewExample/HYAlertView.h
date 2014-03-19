//
//  HYAlertView.h
//  HYAlertViewExample
//
//  Created by Shadow on 14-3-10.
//  Copyright (c) 2014年 Shadow. All rights reserved.
//

/** 使用说明
 * 1.需要按钮就使用HYAlertViewButton的类方法创建按钮,绑定事件block.
 * 2.选择使用合适的HYAlertView的类方法来显示提示窗.
 */

#import <UIKit/UIKit.h>

@class HYAlertViewButton;
@class HYAlertView;

typedef enum {
    HYAlertViewButtonTypeCustom = -1,        //自定义类型
    HYAlertViewButtonTypeNormal = 0,         //普通操作按钮类型
    HYAlertViewButtonTypeDestructive,        //重要操作按钮类型
    HYAlertViewButtonTypeCancel,             //取消操作按钮类型
}HYAlertViewButtonType;

typedef void(^HYAlertViewButtonActionBlock)(HYAlertView *alertView);

@interface HYAlertViewButton : UIButton

@property (nonatomic, strong) HYAlertViewButtonActionBlock action;
@property (nonatomic, readonly, weak) HYAlertView *alertView;

+ (instancetype)buttonWithTitle:(NSString *)title
                     buttonType:(HYAlertViewButtonType)type
                         action:(HYAlertViewButtonActionBlock)action;

@end

@interface HYAlertView : UIView

@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *messageColor;
@property (nonatomic, strong) UIColor *bgColor;

- (void)show;
- (void)dismiss;

//实例方法只会返回HYAlertView对象,不会自己显示.需要手动调用show方法.
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                      buttons:(NSArray *)buttons
            dismissAfterDelay:(NSTimeInterval)delay;

//类方法会立刻显示提示窗.
+ (instancetype)showWithTitle:(NSString *)title message:(NSString *)message;
+ (instancetype)showWithTitle:(NSString *)title message:(NSString *)message dismissAfterDelay:(NSTimeInterval)delay;
+ (instancetype)showWithTitle:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttons;
+ (instancetype)showWithTitle:(NSString *)title
                      message:(NSString *)message
                      buttons:(NSArray *)buttons
            dismissAfterDelay:(NSTimeInterval)delay;

@end


