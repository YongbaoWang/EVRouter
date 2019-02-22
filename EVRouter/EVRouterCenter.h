//
//  EVRouterCenter.h
//  EVRouter
//
//  Created by Ever on 2019/2/21.
//  Copyright © 2019 Ever. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVRouterSecurityPolicy.h"

typedef enum : NSUInteger {
    EVRouterActionTypeUnknown,
    EVRouterActionTypeInstance,
    EVRouterActionTypeClass
} EVRouterActionType;

extern const NSUInteger EVRouterErrorCodeTargetNotFound;
extern const NSUInteger EVRouterErrorCodeClassActionNotFound;
extern const NSUInteger EVRouterErrorCodeInstanceActionNotFound;
extern const NSUInteger EVRouterErrorCodeClassAndInstanceActionNotFound;

@interface EVRouterCenter : NSObject

@property (nonatomic, weak, readwrite) EVRouter *router;
@property (nonatomic, strong, readwrite) id<EVRouterSecurityPolicy> securityPolicy;

//scheme://target/action/actionType?params
//evrouter://Target_Detail/remoteGotoDetailPage/0?param1=1&param2=2
- (BOOL)performActionWithURL:(NSURL *)url;

- (id)performTarget:(NSString *)targetName action:(NSString *)actionName actionType:(EVRouterActionType)actionType params:(NSDictionary *)params error:(id(^)(NSError *err))errorBlock;

@end

