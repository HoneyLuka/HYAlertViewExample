//
//  ViewController.m
//  HYAlertViewExample
//
//  Created by Shadow on 14-3-10.
//  Copyright (c) 2014年 Shadow. All rights reserved.
//

#import "ViewController.h"
#import "HYAlertView.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *showAlertViewButton;
@property (nonatomic, strong) UIButton *startTimerButton;
@property (nonatomic, strong) UIButton *longMessageButton;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.bgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg3.jpg"]];
    self.bgImageView.frame = self.view.bounds;
    [self.view addSubview:self.bgImageView];
    
    self.showAlertViewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.showAlertViewButton setTitle:@"显示窗口" forState:UIControlStateNormal];
    self.showAlertViewButton.frame = CGRectMake(20, 20, 120, 30);
    [self.view addSubview:self.showAlertViewButton];
    [self.showAlertViewButton addTarget:self
                                 action:@selector(showButtonClick:)
                       forControlEvents:UIControlEventTouchUpInside];
    
    self.startTimerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.startTimerButton setTitle:@"多窗口定时弹出" forState:UIControlStateNormal];
    self.startTimerButton.frame = CGRectMake(20, 50, 120, 30);
    [self.view addSubview:self.startTimerButton];
    [self.startTimerButton addTarget:self
                              action:@selector(startTimerButtonClick:)
                    forControlEvents:UIControlEventTouchUpInside];
    
    self.stateLabel = [[UILabel alloc]initWithFrame:CGRectMake(150, 50, 100, 30)];
    self.stateLabel.font = [UIFont systemFontOfSize:15.f];
    self.stateLabel.text = @"关闭";
    [self.view addSubview:self.stateLabel];
    
    self.longMessageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.longMessageButton setTitle:@"长文本提示窗" forState:UIControlStateNormal];
    self.longMessageButton.frame = CGRectMake(20, 80, 120, 30);
    [self.view addSubview:self.longMessageButton];
    [self.longMessageButton addTarget:self
                               action:@selector(longButtonClick:)
                     forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - target/action

- (void)showButtonClick:(UIButton *)button
{
    HYAlertViewButton *deleteButton = [HYAlertViewButton buttonWithTitle:@"删除"
                                                              buttonType:HYAlertViewButtonTypeDestructive
                                                                  action:
                                       ^(HYAlertView *alertView) {
                                           NSLog(@"delete");
                                       }];
    HYAlertViewButton *cancelButton = [HYAlertViewButton buttonWithTitle:@"取消"
                                                              buttonType:HYAlertViewButtonTypeCancel
                                                                  action:
                                       ^(HYAlertView *alertView) {
                                           NSLog(@"cancel");
                                       }];
    HYAlertViewButton *normalButton = [HYAlertViewButton buttonWithTitle:@"普通"
                                                              buttonType:HYAlertViewButtonTypeNormal
                                                                  action:
                                       ^(HYAlertView *alertView) {
                                           NSLog(@"normal");
                                       }];
    
    [HYAlertView showWithTitle:@"提示"
                       message:@"这是一条提示消息!"
                       buttons:@[deleteButton, cancelButton, normalButton]];
}

- (void)startTimerButtonClick:(UIButton *)button
{
    if (self.timer.isValid) {
        [self.timer invalidate];
        self.timer = nil;
        self.stateLabel.text = @"关闭";
        return;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.f
                                                  target:self
                                                selector:@selector(beginShowAlertView)
                                                userInfo:nil
                                                 repeats:YES];
    self.stateLabel.text = @"开启";
}

- (void)longButtonClick:(UIButton *)button
{
    HYAlertViewButton *okButton = [HYAlertViewButton buttonWithTitle:@"明白了"
                                                          buttonType:HYAlertViewButtonTypeCancel
                                                              action:
                                   ^(HYAlertView *alertView) {
                                                                  
                                   }];
    [HYAlertView showWithTitle:@"提示" message:@"这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n这是一个长文本提示框!\n" buttons:@[okButton]];
}

#pragma mark - other method

- (void)beginShowAlertView
{
    HYAlertViewButton *normalButton = [HYAlertViewButton buttonWithTitle:@"我已经明白了" buttonType:HYAlertViewButtonTypeNormal action:^(HYAlertView *alertView) {
        
    }];
    [HYAlertView showWithTitle:@"提示" message:@"测试消息" buttons:@[normalButton] dismissAfterDelay:0];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    self.bgImageView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
