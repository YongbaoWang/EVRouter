//
//  EVRouter.h
//  EVRouter
//
//  Created by Ever on 2019/2/18.
//  Copyright © 2019 Ever. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVRouterSecurityPolicy.h"
#import "EVRouterListUpdatePolicy.h"

extern const NSUInteger EVRouterErrorCodeTargetNotFound;
extern const NSUInteger EVRouterErrorCodeClassActionNotFound;
extern const NSUInteger EVRouterErrorCodeInstanceActionNotFound;
extern const NSUInteger EVRouterErrorCodeClassAndInstanceActionNotFound;

@interface EVRouter : NSObject

/**
 可配置路由安全策略
 */
@property (nonatomic, strong, readwrite) id<EVRouterSecurityPolicy> securityPolicy;

/**
 更新路由表代理【当调用更新路由表update方法时，需实现此代理】
 */
@property (nonatomic, strong) id<EVRouterListUpdatePolicy> updatePolicy;

/**
 单例

 @return EVRouter
 */
+ (instancetype)shared;

/**
 本地路由

 @param targetName 路由目标类
 @param actionName 路由目标方法（优先寻找类方法；没有则寻找实例方法）
 @return 路由目标方法返回值，如果为void，则返回nil；int等类型返回NSNumber；struct，pointer等类型返回 NSValue。
 */
- (id)performTarget:(NSString *)targetName action:(NSString *)actionName;

/**
 本地路由

 @param targetName 路由目标类
 @param actionName 路由目标方法（优先寻找类方法；没有则寻找实例方法）
 @param params 路由目标方法入参（必须为字典形式）
 @return 路由目标方法返回值，如果为void，则返回nil；int等类型返回NSNumber；struct，pointer等类型返回 NSValue。
 */
- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params;

/**
 本地路由

 @param targetName 路由目标类
 @param actionName 路由目标方法（优先寻找类方法；没有则寻找实例方法）
 @param params 路由目标方法入参（必须为字典形式）
 @param errorBlock 错误处理，返回的 id 即为该方法的返回值；其处理优先级比EVRouterSecurityPolicy高
 @return 路由目标方法返回值，如果为void，则返回nil；int等类型返回NSNumber；struct，pointer等类型返回 NSValue。
 */
- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params error:(id(^)(NSError *err))errorBlock;

/**
 本地路由

 @param targetName 路由目标类
 @param actionName 路由目标方法（只寻找类方法）
 @param params 路由目标方法入参（必须为字典形式）
 @param errorBlock 错误处理，返回的id即为该方法的返回值；其处理优先级比EVRouterSecurityPolicy高
 @return 路由目标方法返回值，如果为void，则返回nil；int等类型返回NSNumber；struct，pointer等类型返回 NSValue。
 */
- (id)performTarget:(NSString *)targetName classAction:(NSString *)actionName params:(NSDictionary *)params error:(id(^)(NSError *err))errorBlock;

/**
 本地路由
 
 @param targetName 路由目标类
 @param actionName 路由目标方法（只寻找实例方法）
 @param params 路由目标方法入参（必须为字典形式）
 @param errorBlock 错误处理，返回的id即为该方法的返回值；其处理优先级比EVRouterSecurityPolicy高
 @return 路由目标方法返回值，如果为void，则返回nil；int等类型返回NSNumber；struct，pointer等类型返回 NSValue。
 */
- (id)performTarget:(NSString *)targetName instanceAction:(NSString *)actionName params:(NSDictionary *)params error:(id(^)(NSError *err))errorBlock;

/**
 远程路由

 @param url format scheme://target/action/actionType?params
 @return 是否调用成功
 */
- (BOOL)performActionWithURL:(NSURL *)url;

/**
 更新路由表
 */
- (void)updateRouterList;

@end

