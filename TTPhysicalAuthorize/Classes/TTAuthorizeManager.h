//
//  TTAuthorizeManager.h
//  Pods-TTPhysicalAuthorize_Example
//
//  Created by Lincktang on 2019/8/12.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,TTAuthorizeBiometryType) {
    TTAuthorizeBiometryNone,//不支持身份验证鉴权
    TTAuthorizeBiometryTouchID,//支持指纹身份认证鉴权
    TTAuthorizeBiometryFaceID//支持面容身份认证鉴权
};

typedef NS_ENUM(NSInteger,TTAuthorizeError) {
    TTAuthorizeErrorFailed,//身份认证不正确，对应错误LAErrorAuthenticationFailed
    TTAuthorizeErrorNotEnrolled,//未设置指纹/面容或未设置手机密码,对应错误LAErrorBiometryNotEnrolled，LAErrorTouchIDNotEnrolled
    TTAuthorizeErrorNotAvailable,//未授权使用指纹/面容，对应错误LAErrorBiometryNotAvailable，LAErrorTouchIDNotAvailable
    TTAuthorizeErrorFallback,//反馈错误，用户点击错误弹窗非取消按钮外的另一个按钮是返回的错误类型对应错误LAErrorUserFallback
    TTAuthorizeErrorCancel,//用户或APP或系统，取消认证，用户点击取消，系统来电，APP手动终止LAErrorAppCancel，LAErrorSystemCancel，LAErrorUserCancel
    TTAuthorizeErrorLockout,//短时间内多次验证失败，导致识别被锁定，需输入手机密码解锁，该错误已做处理会唤起密码验证，出现在指纹解锁上
    TTAuthorizeErrorOtherwise//对应其他授权错误
};

@interface TTAuthorizeManager : NSObject

/**
 当前设备支持的生物识别类型
 */
@property (nonatomic, readonly) TTAuthorizeBiometryType biometryType;
/**
 生物识别身份认证，描述文字
 */
@property (nonatomic, copy) NSString *authDescription;
/**
 生物识别身份认证，发生错误后，弹窗fallback按钮标题
 */
@property (nonatomic, copy) NSString *fallbackTitle;
/**
 生物识别身份认证，发生错误后，弹窗取消按钮标题，iOS10以后可设置
 */
@property (nonatomic, copy) NSString *cancelTitle;
/**
 创建全局鉴权管理对象单例

 @return 返回鉴权管理对象实例
 */
+ (instancetype)defaultManager;

/**
  判断设备是否支持进行身份验证

 @param block 回调代码，type表示是否支持和支持的类型,type表示支持的类型，error表示不支持的错误信息
 @see TTAuthorizeError
 @li 检测是否支持面容/指纹识别，会返回TTAuthorizeErrorNotAvailable错误，表示用户没有授权应用使用生物识别功能
 */
- (void)canSupportAuthorize:(void (^) (TTAuthorizeBiometryType type, NSError *error))block;

/**
 启动生物识别身份验证，每次都会启动面容或指纹识别（即系统弹框）

 @param successBlock 验证成功后的回调方法
 @param backBlock 点击验证错误后自定义标题按钮的回调方法，认证错误为LAErrorUserFallback回调
 @param cancelBlock 点击验证错误后取消按钮的回调方法，认证错误为LAErrorAppCancel，LAErrorSystemCancel，LAErrorUserCancel，统一归为TTAuthorizeErrorCancel错误时回调
 @param failureBlock 验证错误其他错误回调方法，其他错误回调
 @see TTAuthorizeError
 */
- (void)applyAuthorizeSuccess:(void (^) (void))successBlock
                     fallback:(void (^) (void))backBlock
                       cancel:(void (^) (void))cancelBlock
                 otherFailure:(void (^) (NSError *error))failureBlock;

/**
 启动单例生物识别验证，此验证成功一次后再次验证时，会直接返回成功，不会再次识别面容或指纹（即系统弹框）

 @param successBlock 验证成功后的回调方法
 @param backBlock 点击验证错误后自定义标题按钮的回调方法
 @param cancelBlock 点击验证错误后取消按钮的回调方法
 @param failureBlock 验证错误其他错误回调方法
 */
- (void)applySingleAuthorizeSuccess:(void (^) (void))successBlock
                           fallback:(void (^) (void))backBlock
                             cancel:(void (^) (void))cancelBlock
                       otherFailure:(void (^) (NSError *error))failureBlock;

/**
 重置单例生物验证，让单例验证重新弹出验证框（即系统弹框）
 */
- (void)resetSingleContext;
/**
 启动生物识别验证附带系统密码验证

 @param successBlock 验证成功后的回调方法
 @param cancelBlock 点击验证错误后取消按钮的回调方法
 @param failureBlock 验证错误其他错误回调方法
 */
- (void)applySystemAuthorizeSuccess:(void (^) (void))successBlock
                             cancel:(void (^) (void))cancelBlock
                       otherFailure:(void (^)(NSError *error))failureBlock NS_AVAILABLE_IOS(9.0);

@end
