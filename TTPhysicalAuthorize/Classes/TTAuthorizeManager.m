//
//  TTAuthorizeManager.m
//  Pods-TTPhysicalAuthorize_Example
//
//  Created by Lincktang on 2019/8/12.
//

#import "TTAuthorizeManager.h"
#import <LocalAuthentication/LocalAuthentication.h>


#define kErrorDomain @"身份识别错误"

@interface TTAuthorizeManager()
@property (nonatomic, strong)LAContext* singleContext;
@property (nonatomic, assign)TTAuthorizeBiometryType privateType;
@end

@implementation TTAuthorizeManager
@dynamic biometryType;
#pragma mark - install method -
+ (instancetype)defaultManager{
    static TTAuthorizeManager *instanceManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceManager = [[TTAuthorizeManager alloc] init];
        instanceManager.singleContext = [[LAContext alloc] init];
    });
    return instanceManager;
}

#pragma mark - public method -
- (void)canSupportAuthorize:(void (^)(TTAuthorizeBiometryType, NSError *))block{
    NSError *error;
    TTAuthorizeBiometryType type = TTAuthorizeBiometryNone;
    LAContext *_authorizeContext = [[LAContext alloc] init];
    if (@available(iOS 9.0, *)) {
        [_authorizeContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error];
    } else {
        [_authorizeContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    }
    if (error) {
        error = [self authorizeErrorFromLAError:error];
    }else{
        if (@available(iOS 11.0, *)) {
            LABiometryType biometryType = _authorizeContext.biometryType;
            switch (biometryType) {
                case LABiometryTypeTouchID:
                    type = TTAuthorizeBiometryTouchID;
                    break;
                case LABiometryTypeFaceID:
                    type = TTAuthorizeBiometryFaceID;
                    break;
                default:
                    break;
            }
        } else {
            type = TTAuthorizeBiometryTouchID;
        }
    }
    self.privateType = type;
    if (block) {
        block(type,error);
    }
}

- (void)applyAuthorizeSuccess:(void (^)(void))successBlock fallback:(void (^)(void))backBlock cancel:(void (^)(void))cancelBlock otherFailure:(void (^)(NSError *))failureBlock{
    // 初始化上下文对象
    LAContext* context = [[LAContext alloc] init];
    
    if (_fallbackTitle != nil) {
        context.localizedFallbackTitle = _fallbackTitle;
    }
    if (_cancelTitle != nil) {
        if (@available(iOS 10.0, *)) {
            context.localizedCancelTitle = _cancelTitle;
        }
    }
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:self.authDescription reply:^(BOOL success, NSError *error) {
        if (success) {
            //验证成功，主线程处理UI
            if (successBlock) {
                successBlock();
            }
        }else{
            NSError *failureErr = [self authorizeErrorFromLAError:error];

            if (failureErr.code == TTAuthorizeErrorFallback) {//验证失败，用户点击了fallback按钮
                if (backBlock) {
                    backBlock();
                }
            }else if (failureErr.code == TTAuthorizeErrorCancel){//验证失败，用户点击了取消按钮
                if (cancelBlock) {
                    cancelBlock();
                }
            }else{
                //验证失败，其他错误，直接返回错误信息
                if (failureBlock) {
                    failureBlock(failureErr);
                }
            }
        }
    }];
}

- (void)applySingleAuthorizeSuccess:(void (^)(void))successBlock fallback:(void (^)(void))backBlock cancel:(void (^)(void))cancelBlock otherFailure:(void (^)(NSError *))failureBlock{
    // 初始化上下文对象
    if (_fallbackTitle != nil) {
        _singleContext.localizedFallbackTitle = _fallbackTitle;
    }
    if (_cancelTitle != nil) {
        if (@available(iOS 10.0, *)) {
            _singleContext.localizedCancelTitle = _cancelTitle;
        }
    }
    [_singleContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:self.authDescription reply:^(BOOL success, NSError *error) {
        if (success) {
            //验证成功，主线程处理UI
            if (successBlock) {
                successBlock();
            }
        }else{
            NSError *failureErr = [self authorizeErrorFromLAError:error];

            if (failureErr.code == TTAuthorizeErrorFallback) {//验证失败，用户点击了fallback按钮
                if (backBlock) {
                    backBlock();
                }
            }else if (failureErr.code == TTAuthorizeErrorCancel){//验证失败，用户点击了取消按钮
                if (cancelBlock) {
                    cancelBlock();
                }
            }else{
                //验证失败，其他错误，直接返回错误信息
                if (failureBlock) {
                    failureBlock(failureErr);
                }
            }
        }
    }];
}

- (void)resetSingleContext{
    self.singleContext = [[LAContext alloc] init];
}

- (void)applySystemAuthorizeSuccess:(void (^)(void))successBlock cancel:(void (^)(void))cancelBlock otherFailure:(void (^)(NSError *))failureBlock{
    if (@available(iOS 9.0, *)) {
        LAContext *context = [[LAContext alloc] init];
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:self.authDescription reply:^(BOOL success, NSError *error) {
            if (success) {
                //验证成功，主线程处理UI
                if (successBlock) {
                    successBlock();
                }
            }else{
                NSError *failureErr = [self authorizeErrorFromLAError:error];

                if (failureErr.code == TTAuthorizeErrorCancel){//验证失败，用户点击了取消按钮
                    if (cancelBlock) {
                        cancelBlock();
                    }
                }else{
                    //验证失败，其他错误，直接返回错误信息
                    if (failureBlock) {
                        failureBlock(failureErr);
                    }
                }
            }
        }];
    } else {
        //验证失败，其他错误，直接返回错误信息
        if (failureBlock) {
            NSString *errorMsg = @"版本不支持系统密码验证";
            NSError *failureErr = [NSError errorWithDomain:kErrorDomain code:-1 userInfo:@{NSLocalizedFailureReasonErrorKey:errorMsg}];
            failureBlock(failureErr);
        }
    }
}

#pragma mark - private method -

/**
 根据错误类型，翻译错误

 @param error 身份验证返回的错误
 @return 解析后返回的错误描述
 */
- (NSString *)errorDescription:(NSError *)error{
    NSString *errorMsg = nil;
    switch (error.code) {
        case LAErrorAppCancel:
            errorMsg = @"身份验证被应用取消，(调用了终止方法)";
            break;
        case LAErrorSystemCancel:
            errorMsg = @"身份验证被系统取消,(比如另一个应用程序去前台,切换到其他 APP)";
            break;
        case LAErrorUserCancel:
            errorMsg = @"身份验证被用户取消,(用户点击取消按钮)";
            break;
        case LAErrorBiometryLockout:
            errorMsg = @"身份验证被锁定，多次身份验证失败";
            break;
        case LAErrorBiometryNotAvailable:
            errorMsg = @"身份验证无法启动,因为验证不可用";
            break;
        case LAErrorBiometryNotEnrolled:
            errorMsg = @"身份验证无法启动,因为验证未设置";
            break;
        case LAErrorAuthenticationFailed:
            errorMsg = @"用户未提供有效证书,(3次机会失败 --身份验证失败)";
            break;
        case LAErrorInvalidContext:
            errorMsg = @"身份验证无法启动,(验证对象实例化失败)";
            break;
        case LAErrorNotInteractive:
            errorMsg = @"身份验证无法启动,(没有交互权限)";
            break;
        case LAErrorPasscodeNotSet:
            errorMsg = @"身份验证无法启动,(用户没有设置密码)";
            break;
        case LAErrorUserFallback:
            errorMsg = @"身份验证被用户取消,(用户取消密码验证)";
            break;
        default:
            errorMsg = @"未知错误";
            break;
    }
    return errorMsg;
}

- (NSError *)authorizeErrorFromLAError:(NSError *)error{
    NSString *errorMsg = [self errorDescription:error];
    NSInteger code = TTAuthorizeErrorOtherwise;
    if (error.code == LAErrorAuthenticationFailed) {
        code = TTAuthorizeErrorFailed;
    }
    if (error.code == LAErrorUserCancel || error.code == LAErrorSystemCancel) {
        code = TTAuthorizeErrorCancel;
    }
    if (@available(iOS 9.0, *)) {
        if (error.code == LAErrorAppCancel) {
            code = TTAuthorizeErrorCancel;
        }
    }
    if (error.code == LAErrorTouchIDNotEnrolled) {
        code = TTAuthorizeErrorNotEnrolled;
    }
    if (@available(iOS 11.0, *)) {
        if (error.code == LAErrorBiometryNotEnrolled) {
            code = TTAuthorizeErrorNotEnrolled;
        }
    }
    if (error.code == LAErrorTouchIDNotAvailable) {
        code = TTAuthorizeErrorNotAvailable;
    }
    if (@available(iOS 11.0, *)) {
        if (error.code == LAErrorBiometryNotAvailable) {
            code = TTAuthorizeErrorNotAvailable;
        }
    }
    //多次尝试指纹验证失败错误9.0后引入LAErrorTouchIDLockout,11.0后废弃改为LAErrorBiometryLockout
    //出现这些错误后TouchID验证无法打开，需要验证手机密码才能正常使用
    //如是TouchID验证，且捕获到此错误的，使用LAPolicyDeviceOwnerAuthentication
    if (@available(iOS 9.0, *)) {
        if (error.code == LAErrorTouchIDLockout) {
            code = TTAuthorizeErrorLockout;
        }
    }
    if (@available(iOS 11.0, *)) {
        if (error.code == LAErrorBiometryLockout) {
            code = TTAuthorizeErrorLockout;
        }
    }
    if (error.code == LAErrorUserFallback) {
        code = TTAuthorizeErrorFallback;
    }
    NSError *failureErr = [NSError errorWithDomain:kErrorDomain code:code userInfo:@{NSLocalizedFailureReasonErrorKey:errorMsg}];
    
    return failureErr;
}

#pragma mark - getter method -
- (NSString *)authDescription{
    if (!_authDescription) {
        return @"短时间内多次验证失败，需要验证手机密码";
    }
    return _authDescription;
}

- (TTAuthorizeBiometryType)biometryType{
    if (_privateType == TTAuthorizeBiometryNone) {
        [self canSupportAuthorize:nil];
    }
    return _privateType;
}
@end
