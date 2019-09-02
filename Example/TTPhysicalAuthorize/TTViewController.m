//
//  TTViewController.m
//  TTPhysicalAuthorize
//
//  Created by Lincktang on 08/10/2019.
//  Copyright (c) 2019 Lincktang. All rights reserved.
//

#import "TTViewController.h"
#import "TTPhysicalAuthorize.h"

@interface TTViewController ()

@end

@implementation TTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)checkBiometryAction:(UIButton *)sender {
    TTAuthorizeManager *manager = [TTAuthorizeManager defaultManager];
    [manager canSupportAuthorize:^(TTAuthorizeBiometryType type, NSError *error) {
        switch (type) {
            case TTAuthorizeBiometryNone:
                [self showMessage:[NSString stringWithFormat:@"设备不支持身份验证%@",error]];
                break;
            case TTAuthorizeBiometryTouchID:
                [self showMessage:@"设备支持指纹验证"];
                break;
            case TTAuthorizeBiometryFaceID:
                [self showMessage:@"设备支持面容验证"];
                break;
            default:
                break;
        }
    }];
}

- (IBAction)applyAuthorizeAction:(UIButton *)sender {
    [[TTAuthorizeManager defaultManager] setAuthDescription:@"面容ID短时间内失败多次，需要验证手机密码"];
    [[TTAuthorizeManager defaultManager] setFallbackTitle:@""];
    
    [[TTAuthorizeManager defaultManager] applyAuthorizeSuccess:^{
        NSLog(@"验证成功");
    } fallback:^{
        NSLog(@"验证登录密码");
    } cancel:^{
        NSLog(@"用户取消验证");
    } otherFailure:^(NSError *error) {
        NSLog(@"其他验证错误%@",error);
    }];
}
- (IBAction)systemAuthorizeAction:(UIButton *)sender {
    [[TTAuthorizeManager defaultManager] applySystemAuthorizeSuccess:^{
        NSLog(@"验证成功");
    } cancel:^{
        NSLog(@"用户取消验证");
    } otherFailure:^(NSError *error) {
        NSLog(@"其他验证错误%@",error);
    }];
}

- (IBAction)singleAuthorizeAction:(UIButton *)sender {
    [[TTAuthorizeManager defaultManager] setAuthDescription:@"single面容ID短时间内失败多次，需要验证手机密码"];
    [[TTAuthorizeManager defaultManager] setFallbackTitle:@"single验证登录密码"];
    
    [[TTAuthorizeManager defaultManager] applySingleAuthorizeSuccess:^{
        NSLog(@"验证成功");
    } fallback:^{
        NSLog(@"验证登录密码");
    } cancel:^{
        NSLog(@"用户取消验证");
    } otherFailure:^(NSError *error) {
        NSLog(@"其他验证错误%@",error);
    }];
}

- (IBAction)resetSingleAuthorizeAction:(UIButton *)sender {
    [[TTAuthorizeManager defaultManager] resetSingleContext];
}

- (void)showMessage:(NSString *)message{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
