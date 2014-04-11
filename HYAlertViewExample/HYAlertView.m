//
//  HYAlertView.m
//  HYAlertViewExample
//
//  Created by Shadow on 14-3-10.
//  Copyright (c) 2014年 Shadow. All rights reserved.
//

#import "HYAlertView.h"

@class HYAlertViewWindow;
@class HYAlertViewController;

static HYAlertViewWindow *alertViewWindow = nil;
static HYAlertViewController *alertViewController = nil;

//变量、方法前向声明
@interface HYAlertView ()

@property (nonatomic, assign, getter = isShowing) BOOL show;
@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, assign) UIInterfaceOrientation forOrientation;

- (void)viewRotateToOrientation:(UIInterfaceOrientation)orientation;

@end

#pragma mark - Category

@interface UIImage (ImageByColor)

+ (UIImage *)imageByColor:(UIColor *)color;

@end

@implementation UIImage (ImageByColor)

+ (UIImage *)imageByColor:(UIColor *)color
{
    CGSize imageSize = CGSizeMake(1, 1);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    [color set];
    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

@interface UIColor (ColorWithString)

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;

@end

@implementation UIColor (ColorWithString)

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];//字符串处理
    //例子，stringToConvert #ffffff
    if ([cString length] < 6)
        return [UIColor whiteColor];//如果非十六进制，返回白色
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];//去掉头
    if ([cString length] != 6)//去头非十六进制，返回白色
        return [UIColor whiteColor];
    //分别取RGB的值
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int r, g, b;
    //NSScanner把扫描出的制定的字符串转换成Int类型
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    //转换为UIColor
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

@end

#pragma mark - HYAlertViewWindow

const UIWindowLevel level = 1999.f;

@interface HYAlertViewWindow : UIWindow

+ (instancetype)sharedInstance;

@end

@implementation HYAlertViewWindow

+ (instancetype)sharedInstance
{
    if (!alertViewWindow) {
        alertViewWindow = [[HYAlertViewWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
        alertViewWindow.windowLevel = level;
        alertViewWindow.backgroundColor = [UIColor clearColor];
    }
    return alertViewWindow;
}

@end

#pragma mark - HYAlertViewController

@interface HYAlertViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *alertViewArrays;

@property (nonatomic, readonly, getter = isShowing) BOOL show;

+ (instancetype)sharedInstance;

@end

@implementation HYAlertViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.alertViewArrays = [NSMutableArray array];
    }
    return self;
}

- (void)showAlertView:(HYAlertView *)alertView
{
    if (self.isShowing) {
        HYAlertView *lastView = [self.alertViewArrays lastObject];
        [self dismissAnimationWithAlertView:lastView completion:nil];
    } else {
        [self showAnimationWithBackgroundView];
    }
    [self.alertViewArrays addObject:alertView];
    
    CGPoint center;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (alertView.forOrientation != orientation) {
        [alertView viewRotateToOrientation:orientation];
    }
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame));
    } else {
        center = CGPointMake(CGRectGetMidY(self.view.frame), CGRectGetMidX(self.view.frame));
    }
    alertView.center = center;
    [self.view addSubview:alertView];
    
    HYAlertViewWindow *window = [HYAlertViewWindow sharedInstance];
    window.rootViewController = self;
    [window makeKeyAndVisible];
    
    [self showAnimationWithAlertView:alertView completion:^{
        if (alertView.delay > 0) {
            double delayInSeconds = alertView.delay;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self dismissAlertView:alertView];
            });
        }
    }];
    
    alertView.show = YES;
    _show = YES;
}

- (void)dismissAlertView:(HYAlertView *)alertView
{
    [self dismissAnimationWithAlertView:alertView completion:^{
        [alertView removeFromSuperview];
        [self.alertViewArrays removeObject:alertView];
        [self hideWindowIfNoAlertView];
    }];
    alertView.show = NO;
}

- (void)showAnimationWithAlertView:(HYAlertView *)alertView completion:(void(^)(void))completion
{
    alertView.alpha = 0;
    alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
    [UIView animateWithDuration:0.25f animations:^{
        alertView.alpha = 1;
        alertView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)dismissAnimationWithAlertView:(HYAlertView *)alertView completion:(void(^)(void))completion
{
    [UIView animateWithDuration:0.25f animations:^{
        alertView.alpha = 0;
        alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
    } completion:^(BOOL finished) {
        alertView.transform = CGAffineTransformIdentity;
        if (completion) {
            completion();
        }
    }];
}

- (void)showAnimationWithBackgroundView
{
    self.view.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.3];
    self.view.alpha = 0;
    [UIView animateWithDuration:0.25f animations:^{
        self.view.alpha = 1;
    }];
}

- (void)dismissAnimationBackgroundViewWithCompletion:(void(^)(void))completion
{
    [UIView animateWithDuration:0.25f animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)hideWindowIfNoAlertView
{
    if (![self.alertViewArrays count]) {
        [self dismissAnimationBackgroundViewWithCompletion:^{
            self.view.window.hidden = YES;
            _show = NO;
        }];
    } else {
        HYAlertView *lastView = [self.alertViewArrays lastObject];
        [self showAnimationWithAlertView:lastView completion:nil];
    }
}

- (void)buttonClick:(HYAlertViewButton *)button
{
    if (button.action) {
        button.action(button.alertView);
    }
    [self dismissAlertView:button.alertView];
}

+ (instancetype)sharedInstance
{
    if (!alertViewController) {
        alertViewController = [[HYAlertViewController alloc]init];
    }
    return alertViewController;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    for (HYAlertView *view in self.alertViewArrays) {
        [view viewRotateToOrientation:toInterfaceOrientation];
        view.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    }
}

@end

#pragma mark - HYAlertViewButton

@interface HYAlertViewButton ()

@property (nonatomic, weak) HYAlertView *alertView;

@end

@implementation HYAlertViewButton

+ (instancetype)buttonWithTitle:(NSString *)title
                     buttonType:(HYAlertViewButtonType)type
                         action:(HYAlertViewButtonActionBlock)action
{
    HYAlertViewButton *button = [self buttonWithType:UIButtonTypeCustom];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
    switch (type) {
        case HYAlertViewButtonTypeNormal:
            [button setBackgroundImage:[UIImage imageByColor:[UIColor colorWithHexString:@"cccccc"]]
                              forState:UIControlStateNormal];
            break;
        case HYAlertViewButtonTypeDestructive:
            [button setBackgroundImage:[UIImage imageByColor:[UIColor colorWithHexString:@"FB8784"]]
                              forState:UIControlStateNormal];
            break;
        case HYAlertViewButtonTypeCancel:
            [button setBackgroundImage:[UIImage imageByColor:[UIColor colorWithHexString:@"7C8487"]]
                              forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
    if (action) {
        button.action = action;
    }
    [button addTarget:[HYAlertViewController sharedInstance] action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

@end

#pragma mark - HYAlertView

#define ALERT_VIEW_WIDTH 250.f
#define ALERT_VIEW_SPACING 20.f

#define ALERT_VIEW_MESSAGE_FONT [UIFont systemFontOfSize:14.f]

@interface HYAlertView ()

@property (nonatomic, weak) HYAlertViewController *controller;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) NSArray *buttons;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) CGFloat titleHeight;
@property (nonatomic, assign) CGFloat messageHeight;
@property (nonatomic, assign) CGFloat buttonHeight;

@end

@implementation HYAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"F7F9FA"];
        self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
        [self addSubview:self.scrollView];
        self.layer.cornerRadius = 8.f;
        self.clipsToBounds = YES;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                      buttons:(NSArray *)buttons
            dismissAfterDelay:(NSTimeInterval)delay
{
    self = [HYAlertView setupAlertViewWithTitle:title
                                        message:message
                                        buttons:buttons
                                          delay:delay];
    return self;
}

+ (instancetype)showWithTitle:(NSString *)title message:(NSString *)message
{
    return [self showWithTitle:title message:message buttons:nil dismissAfterDelay:0];
}

+ (instancetype)showWithTitle:(NSString *)title message:(NSString *)message dismissAfterDelay:(NSTimeInterval)delay
{
    return [self showWithTitle:title message:message buttons:nil dismissAfterDelay:delay];
}

+ (instancetype)showWithTitle:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttons
{
    return [self showWithTitle:title message:message buttons:buttons dismissAfterDelay:0];
}

+ (instancetype)showWithTitle:(NSString *)title
              message:(NSString *)message
              buttons:(NSArray *)buttons
    dismissAfterDelay:(NSTimeInterval)delay
{
    HYAlertView *alertView = [self setupAlertViewWithTitle:title
                                                   message:message
                                                   buttons:buttons
                                                     delay:delay];
    [alertView.controller showAlertView:alertView];
    return alertView;
}

+ (HYAlertView *)setupAlertViewWithTitle:(NSString *)title
                                 message:(NSString *)message
                                 buttons:(NSArray *)buttons
                                   delay:(NSTimeInterval)delay
{
    if (!title) {
        title = @"";
    }
    if (!message) {
        message = @"";
    }
    HYAlertView *alertView = [[HYAlertView alloc]initWithFrame:CGRectZero];
    
    alertView.title = title;
    alertView.message = message;
    alertView.buttons = buttons;
    alertView.delay = delay;
    
    alertView.controller = [HYAlertViewController sharedInstance];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [alertView viewRotateToOrientation:orientation];
    
    return alertView;
}

- (void)show
{
    if (!self.isShowing) {
        [self.controller showAlertView:self];
    }
}

- (void)dismiss
{
    if (self.isShowing) {
        [self.controller dismissAlertView:self];
    }
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    self.titleLabel.textColor = titleColor;
}

- (void)setMessageColor:(UIColor *)messageColor
{
    _messageColor = messageColor;
    self.messageLabel.textColor = messageColor;
}

- (void)setBgColor:(UIColor *)bgColor
{
    _bgColor = bgColor;
    self.backgroundColor = bgColor;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    if (!self.titleLabel) {
        self.titleLabel = [[UILabel alloc]initWithFrame:
                           CGRectMake(ALERT_VIEW_SPACING,
                                      ALERT_VIEW_SPACING,
                                      ALERT_VIEW_WIDTH-ALERT_VIEW_SPACING*2,
                                      20)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor colorWithHexString:@"575256"];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
        [self.scrollView addSubview:self.titleLabel];
    }
    self.titleHeight = 20.f;
    self.titleLabel.text = title;
}

- (void)setMessage:(NSString *)message
{
    _message = message;
    
    CGSize constraint = CGSizeMake(ALERT_VIEW_WIDTH-ALERT_VIEW_SPACING*2, CGFLOAT_MAX);
    CGSize size = [message sizeWithFont:ALERT_VIEW_MESSAGE_FONT
                      constrainedToSize:constraint
                          lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat height = MAX(size.height, 20.f);
    if (!self.messageLabel) {
        self.messageLabel = [[UILabel alloc]initWithFrame:
                             CGRectMake(ALERT_VIEW_SPACING,
                                        ALERT_VIEW_SPACING*2+20,
                                        ALERT_VIEW_WIDTH-ALERT_VIEW_SPACING*2,
                                        height)];
        self.messageLabel.backgroundColor = [UIColor clearColor];
        self.messageLabel.textColor = [UIColor colorWithHexString:@"7C8487"];
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        self.messageLabel.font = ALERT_VIEW_MESSAGE_FONT;
        self.messageLabel.numberOfLines = 0;
        [self.scrollView addSubview:self.messageLabel];
    }
    self.messageHeight = height;
    self.messageLabel.text = message;
}

- (void)setButtons:(NSArray *)buttons
{
    _buttons = buttons;
    if (!buttons || ![buttons count]) {
        self.buttonHeight = 0;
        return;
    }
    
    self.buttonHeight = 40.f;
    
    CGFloat buttonWidth = ALERT_VIEW_WIDTH / [buttons count];
    int i = 0;
    for (HYAlertViewButton *button in buttons) {
        button.alertView = self;
        button.frame = CGRectMake(buttonWidth*i,
                                  [self heightForAlertViewInCurrentOrientation]-self.buttonHeight,
                                  buttonWidth,
                                  self.buttonHeight);
        [self addSubview:button];
        i++;
    }
    
}

- (void)viewRotateToOrientation:(UIInterfaceOrientation)orientation
{
    self.forOrientation = orientation;
    
    CGFloat alertViewHeight = [self heightForAlertViewInOrientation:orientation];
    CGFloat scrollViewContentSizeHeight = [self heightForScrollViewContentSize];
    
    CGRect frame = self.frame;
    frame.size.width = ALERT_VIEW_WIDTH;
    frame.size.height = alertViewHeight;
    
    self.frame = frame;
    self.scrollView.frame = CGRectMake(0, 0, ALERT_VIEW_WIDTH, alertViewHeight-self.buttonHeight);
    self.scrollView.contentSize = CGSizeMake(ALERT_VIEW_WIDTH, scrollViewContentSizeHeight);
    self.buttons = self.buttons;
}

- (CGFloat)heightForScrollViewContentSize
{
    CGFloat height = self.titleHeight + self.messageHeight + ALERT_VIEW_SPACING*3;
    return height;
}

- (CGFloat)heightForAlertViewInCurrentOrientation
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    return [self heightForAlertViewInOrientation:orientation];
}

- (CGFloat)heightForAlertViewInOrientation:(UIInterfaceOrientation)orientation
{
    CGFloat height = self.titleHeight + self.messageHeight + ALERT_VIEW_SPACING*3 + self.buttonHeight;
    CGFloat screenHeight;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        screenHeight = CGRectGetMaxY([UIScreen mainScreen].bounds);
    } else {
        screenHeight = CGRectGetMaxX([UIScreen mainScreen].bounds);
    }
    if (height > screenHeight) {
        height = screenHeight - 40.f;
    }
    return height;
}

@end
