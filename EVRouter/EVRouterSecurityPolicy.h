//
//  EVRouterSecurityPolicy.h
//  EVRouter
//
//  Created by Ever on 2019/2/21.
//  Copyright © 2019 Ever. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EVRouter;

@protocol EVRouterSecurityPolicy <NSObject>

@required

@property (nonatomic, assign, getter = isRemoteInvokeEnabled) BOOL remoteInvokeEnabled;

@optional

@property (nonatomic, copy) NSString *remoteScheme;

@property (nonatomic, copy) NSArray *remoteTargetArray;

- (id)evrouter:(EVRouter *)router targetNotFound:(NSString *)targetName;

- (id)evrouter:(EVRouter *)router target:(NSString *)targetName actionNotFound:(NSString *)actionName;

- (id)evrouter:(EVRouter *)router unsupportedReturnType:(const char *)type;

@end

