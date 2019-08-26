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

@interface TTAuthorizeManager : NSObject
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
 */
- (void)canSupportAuthorize:(void (^) (TTAuthorizeBiometryType type, NSError *error))block;

/**
 启动生物识别身份验证

 @param successBlock 验证成功后的回调方法
 @param backBlock 点击验证错误后自定义标题按钮的回调方法
 @param cancelBlock 点击验证错误后取消按钮的回调方法
 @param failureBlock 验证错误其他错误回调方法
 */
- (void)applyAuthorizeSuccess:(void (^) (void))successBlock
                     fallback:(void (^) (void))backBlock
                       cancel:(void (^) (void))cancelBlock
                 otherFailure:(void (^) (NSError *error))failureBlock;

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
