//
//  EVRouter.m
//  EVRouter
//
//  Created by Ever on 2019/2/18.
//  Copyright © 2019 Ever. All rights reserved.
//

#import "EVRouter.h"
#import "EVRouterCenter.h"
#import "EVRouterList.h"

static EVRouter *router;

@interface EVRouter ()

@property (nonatomic, strong) EVRouterCenter *routerCenter;
@property (nonatomic, strong) EVRouterList *routerList;

@end

@implementation EVRouter

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [[super allocWithZone:NULL] init];
        router.routerCenter = [[EVRouterCenter alloc] init];
        router.routerList = [[EVRouterList alloc] init];
    });
    return router;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [EVRouter shared];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return [EVRouter shared];
}

- (id)mutableCopyWithZone:(struct _NSZone *)zone {
    return [EVRouter shared];
}

- (id)performTarget:(NSString *)targetName action:(NSString *)actionName {
    return [self performTarget:targetName action:actionName params:nil error:nil];
}

- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params {
    return [self performTarget:targetName action:actionName params:params error:nil];
}

- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params error:(id(^)(NSError *err))errorBlock {
    targetName = [self mapTarget:targetName];
    actionName = [self mapAction:actionName forTarget:targetName];
    return [self.routerCenter performTarget:targetName action:actionName actionType:EVRouterActionTypeUnknown params:params error:errorBlock];
}

- (id)performTarget:(NSString *)targetName classAction:(NSString *)actionName params:(NSDictionary *)params error:(id (^)(NSError *))errorBlock {
    targetName = [self mapTarget:targetName];
    actionName = [self mapAction:actionName forTarget:targetName];
    return [self.routerCenter performTarget:targetName action:actionName actionType:EVRouterActionTypeClass params:params error:errorBlock];
}

- (id)performTarget:(NSString *)targetName instanceAction:(NSString *)actionName params:(NSDictionary *)params error:(id (^)(NSError *))errorBlock {
    targetName = [self mapTarget:targetName];
    actionName = [self mapAction:actionName forTarget:targetName];
    return [self.routerCenter performTarget:targetName action:actionName actionType:EVRouterActionTypeInstance params:params error:errorBlock];
}

- (BOOL)performActionWithURL:(NSURL *)url {
    return [self.routerCenter performActionWithURL:url];
}

- (NSString *)mapTarget:(NSString *)targetName {
    if (self.routerList.isReady) {
        return [self.routerList mapTarget:targetName];
    }
    return targetName;
}

- (NSString *)mapAction:(NSString *)actionName forTarget:(NSString *)target {
    if (self.routerList.isReady) {
        return [self.routerList mapAction:actionName forTarget:target];
    }
    return actionName;
}

- (void)updateRouterList {
    if (self.updatePolicy) {
        [self.routerList update];
    } else {
        NSAssert(false, @"EVRouter:You must set the securityPolicy property!");
    }
}

- (void)setSecurityPolicy:(id<EVRouterSecurityPolicy>)securityPolicy {
    if ([securityPolicy conformsToProtocol:@protocol(EVRouterSecurityPolicy)]) {
        _securityPolicy = securityPolicy;
        self.routerCenter.securityPolicy = securityPolicy;
    }
}

- (void)setUpdatePolicy:(id<EVRouterListUpdatePolicy>)updatePolicy {
    if ([updatePolicy conformsToProtocol:@protocol(EVRouterListUpdatePolicy)]) {
        _updatePolicy = updatePolicy;
        self.routerList.updatePolicy = _updatePolicy;
    }
}

@end
