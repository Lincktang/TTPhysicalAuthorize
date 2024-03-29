//
//  TTAuthorizeManager.m
//  Pods-TTPhysicalAuthorize_Example
//
//  Created by Lincktang on 2019/8/12.
//

#import "TTAuthorizeManager.h"


#define kErrorDomain @"身份识别错误"

@interface TTAuthorizeManager()
@property (nonatomic, strong)LAContext* singleContext;
@end

@implementation TTAuthorizeManager

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
        NSString *msg = [self errorDescription:error];
        error = [NSError errorWithDomain:msg code:error.code userInfo:@{NSLocalizedFailureReasonErrorKey:msg}];
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
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:_authDescription reply:^(BOOL success, NSError *error) {
        if (success) {
            //验证成功，主线程处理UI
            if (successBlock) {
                successBlock();
            }
        }else{
            if (error.code == LAErrorUserFallback) {//验证失败，用户点击了fallback按钮
                if (backBlock) {
                    backBlock();
                }
            }else if (error.code == LAErrorUserCancel){//验证失败，用户点击了取消按钮
                if (cancelBlock) {
                    cancelBlock();
                }
            }else{

                if (@available(iOS 9.0, *)) {
                    //多次尝试指纹验证失败错误9.0后引入LAErrorTouchIDLockout,11.0后废弃改为LAErrorBiometryLockout
                    //出现这些错误后TouchID验证无法打开，需要验证手机密码才能正常使用
                    //如是TouchID验证，且捕获到此错误的，使用LAPolicyDeviceOwnerAuthentication
                    BOOL isLockoutError = NO;
                    BOOL isUsedTouchId = NO;
                    if (error.code == LAErrorTouchIDLockout) {
                        isLockoutError = YES;
                        isUsedTouchId = YES;
                    }
                    if (@available(iOS 11.0, *)){
                        if (error.code == LAErrorBiometryLockout) {
                            isLockoutError = YES;
                        }
                        isUsedTouchId = (context.biometryType == LABiometryTypeTouchID);
                    }
                    if (isLockoutError && isUsedTouchId) {
                        [self applySystemAuthorizeSuccess:^{
                            if (successBlock) {
                                successBlock();
                            }
                        } cancel:^{
                            if (cancelBlock) {
                                cancelBlock();
                            }
                        } otherFailure:^(NSError *error) {
                            if (failureBlock) {
                                failureBlock(error);
                            }
                        }];
                        return;
                    }
                }
                //验证失败，其他错误，直接返回错误信息
                if (failureBlock) {
                    NSString *errorMsg = [self errorDescription:error];
                    NSError *failureErr = [NSError errorWithDomain:kErrorDomain code:error.code userInfo:@{NSLocalizedFailureReasonErrorKey:errorMsg}];
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
    [_singleContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:_authDescription reply:^(BOOL success, NSError *error) {
        if (success) {
            //验证成功，主线程处理UI
            if (successBlock) {
                successBlock();
            }
        }else{
            if (error.code == LAErrorUserFallback) {//验证失败，用户点击了fallback按钮
                if (backBlock) {
                    backBlock();
                }
            }else if (error.code == LAErrorUserCancel){//验证失败，用户点击了取消按钮
                if (cancelBlock) {
                    cancelBlock();
                }
            }else{
                
                if (@available(iOS 9.0, *)) {
                    //多次尝试指纹验证失败错误9.0后引入LAErrorTouchIDLockout,11.0后废弃改为LAErrorBiometryLockout
                    //出现这些错误后TouchID验证无法打开，需要验证手机密码才能正常使用
                    //如是TouchID验证，且捕获到此错误的，使用LAPolicyDeviceOwnerAuthentication
                    BOOL isLockoutError = NO;
                    BOOL isUsedTouchId = NO;
                    if (error.code == LAErrorTouchIDLockout) {
                        isLockoutError = YES;
                        isUsedTouchId = YES;
                    }
                    if (@available(iOS 11.0, *)){
                        if (error.code == LAErrorBiometryLockout) {
                            isLockoutError = YES;
                        }
                        isUsedTouchId = (self->_singleContext.biometryType == LABiometryTypeTouchID);
                    }
                    if (isLockoutError && isUsedTouchId) {
                        [self applySystemAuthorizeSuccess:^{
                            if (successBlock) {
                                successBlock();
                            }
                        } cancel:^{
                            if (cancelBlock) {
                                cancelBlock();
                            }
                        } otherFailure:^(NSError *error) {
                            if (failureBlock) {
                                failureBlock(error);
                            }
                        }];
                        return;
                    }
                }
                //验证失败，其他错误，直接返回错误信息
                if (failureBlock) {
                    NSString *errorMsg = [self errorDescription:error];
                    NSError *failureErr = [NSError errorWithDomain:kErrorDomain code:error.code userInfo:@{NSLocalizedFailureReasonErrorKey:errorMsg}];
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
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:_authDescription reply:^(BOOL success, NSError *error) {
            if (success) {
                //验证成功，主线程处理UI
                if (successBlock) {
                    successBlock();
                }
            }else{
                if (error.code == LAErrorUserCancel){//验证失败，用户点击了取消按钮
                    if (cancelBlock) {
                        cancelBlock();
                    }
                }else{
                    //验证失败，其他错误，直接返回错误信息
                    if (failureBlock) {
                        NSString *errorMsg = [self errorDescription:error];
                        NSError *failureErr = [NSError errorWithDomain:kErrorDomain code:error.code userInfo:@{NSLocalizedFailureReasonErrorKey:errorMsg}];
                        failureBlock(failureErr);
                    }
                }
            }
        }];
    } else {
        //验证失败，其他错误，直接返回错误信息
        if (failureBlock) {
            NSString *errorMsg = @"版本不支持系统密码验证";
            NSError *failureErr = [NSError errorWithDomain:kErrorDomain code:-11 userInfo:@{NSLocalizedFailureReasonErrorKey:errorMsg}];
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

#pragma mark - getter method -
- (NSString *)authDescription{
    if (!_authDescription) {
        return @"短时间内多次验证失败，需要验证手机密码";
    }
    return _authDescription;
}
@end
