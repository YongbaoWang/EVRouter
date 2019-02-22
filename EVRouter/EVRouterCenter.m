//
//  EVRouterCenter.m
//  EVRouter
//
//  Created by Ever on 2019/2/21.
//  Copyright © 2019 Ever. All rights reserved.
//

#import "EVRouterCenter.h"
#import <CoreGraphics/CoreGraphics.h>

#define CHECK_VOID_TYPE \
if (strcmp(returnType, @encode(void)) == 0) { \
NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature]; \
if (signature.numberOfArguments == 3) { \
const char *paramType = [signature getArgumentTypeAtIndex:2]; \
if (strcmp(paramType, @encode(NSDictionary *)) == 0) { \
[invocation setArgument:&params atIndex:2]; \
}} \
[invocation setTarget:target]; \
[invocation setSelector:action]; \
[invocation invoke]; \
return nil; \
}

#define CHECK_BASIC_TYPE(Type) \
if (strcmp(returnType, @encode(Type)) == 0) { \
NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature]; \
if (signature.numberOfArguments == 3) { \
const char *paramType = [signature getArgumentTypeAtIndex:2]; \
if (strcmp(paramType, @encode(NSDictionary *)) == 0) { \
[invocation setArgument:&params atIndex:2]; \
}} \
[invocation setTarget:target]; \
[invocation setSelector:action]; \
[invocation invoke]; \
Type ret; \
[invocation getReturnValue:&ret]; \
return @(ret); \
}

#define CHECK_CHAR_POINTER_TYPE \
if (strcmp(returnType, @encode(char *)) == 0) { \
NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature]; \
if (signature.numberOfArguments == 3) { \
const char *paramType = [signature getArgumentTypeAtIndex:2]; \
if (strcmp(paramType, @encode(NSDictionary *)) == 0) { \
[invocation setArgument:&params atIndex:2]; \
}} \
[invocation setTarget:target]; \
[invocation setSelector:action]; \
[invocation invoke]; \
char *c; \
[invocation getReturnValue:&c]; \
NSValue *ret = [NSValue valueWithPointer:c]; \
return ret; \
}

#define CHECK_SEL_TYPE \
if (strcmp(returnType, @encode(SEL)) == 0) { \
NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature]; \
if (signature.numberOfArguments == 3) { \
const char *paramType = [signature getArgumentTypeAtIndex:2]; \
if (strcmp(paramType, @encode(NSDictionary *)) == 0) { \
[invocation setArgument:&params atIndex:2]; \
}} \
[invocation setTarget:target]; \
[invocation setSelector:action]; \
[invocation invoke]; \
SEL ret; \
[invocation getReturnValue:&ret]; \
return NSStringFromSelector(ret); \
}

#define CHECK_STRUCT_TYPE \
if (returnType[0] == '{') { \
NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature]; \
if (signature.numberOfArguments == 3) { \
const char *paramType = [signature getArgumentTypeAtIndex:2]; \
if (strcmp(paramType, @encode(NSDictionary *)) == 0) { \
[invocation setArgument:&params atIndex:2]; \
}} \
[invocation setTarget:target]; \
[invocation setSelector:action]; \
[invocation invoke]; \
void *v = calloc(1,signature.methodReturnLength); \
[invocation getReturnValue:v]; \
NSValue *ret = [NSValue valueWithPointer:v]; \
free(v); \
return ret; \
}

#define CHECK_POINTER_TYPE \
if (returnType[0] == '^') { \
NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature]; \
if (signature.numberOfArguments == 3) { \
const char *paramType = [signature getArgumentTypeAtIndex:2]; \
if (strcmp(paramType, @encode(NSDictionary *)) == 0) { \
[invocation setArgument:&params atIndex:2]; \
}} \
[invocation setTarget:target]; \
[invocation setSelector:action]; \
[invocation invoke]; \
void *v; \
[invocation getReturnValue:&v]; \
NSValue *ret = [NSValue valueWithPointer:v]; \
return ret; \
}

#define CHECK_BLOCK_TYPE \
if (strcmp(returnType, @encode(void(^)(void))) == 0) { \
NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature]; \
if (signature.numberOfArguments == 3) { \
const char *paramType = [signature getArgumentTypeAtIndex:2]; \
if (strcmp(paramType, @encode(NSDictionary *)) == 0) { \
[invocation setArgument:&params atIndex:2]; \
}} \
[invocation setTarget:target]; \
[invocation setSelector:action]; \
[invocation invoke]; \
void *v; \
[invocation getReturnValue:&v]; \
NSValue *ret = [NSValue valueWithPointer:v]; \
return ret; \
}

const NSUInteger EVRouterErrorCodeTargetNotFound = 700001;
const NSUInteger EVRouterErrorCodeClassActionNotFound = 700002;
const NSUInteger EVRouterErrorCodeInstanceActionNotFound = 700003;
const NSUInteger EVRouterErrorCodeClassAndInstanceActionNotFound = 700004;

@implementation EVRouterCenter

//scheme://target/action?params
//evrouter://Target_Detail/remoteGotoDetailPage?param1=1&param2=2
- (BOOL)performActionWithURL:(NSURL *)url {
    if (url == nil) {
        return NO;
    }
    NSString *scheme = url.scheme;
    NSString *target = url.host;
    NSArray *pathComponents = url.pathComponents;
    //检查URL是否合法
    if (scheme.length == 0 || target.length == 0 || pathComponents.count != 2) {
        return NO;
    }
    //检查安全策略
    if (self.securityPolicy != nil) {
        if (!self.securityPolicy.isRemoteInvokeEnabled) {
            return NO;
        }
        if (self.securityPolicy.remoteScheme.length > 0 && ![self.securityPolicy.remoteScheme isEqualToString:scheme]) {
            return NO;
        }
        if (self.securityPolicy.remoteTargetArray.count > 0 && ![self.securityPolicy.remoteTargetArray containsObject:target]) {
            return NO;
        }
    }
    
    NSString *action = pathComponents[1];
    
    NSMutableDictionary *paramsDicM = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.name.length > 0 && obj.value.length > 0) {
            [paramsDicM setObject:obj.value forKey:obj.name];
        }
    }];
    
    [self performTarget:target action:action actionType:EVRouterActionTypeUnknown params:paramsDicM error:nil];
    
    return YES;
}

- (id)performTarget:(NSString *)targetName action:(NSString *)actionName actionType:(EVRouterActionType)actionType params:(NSDictionary *)params error:(id(^)(NSError *err))errorBlock {
    id(^safeErrorBlock)(NSString *, NSUInteger) = ^id(NSString *domain, NSUInteger code){
        if (errorBlock) {
            return errorBlock([NSError errorWithDomain:domain code:code userInfo:nil]);
        } else if (self.securityPolicy) {
            if (code == EVRouterErrorCodeTargetNotFound && [self.securityPolicy respondsToSelector:@selector(evrouter:targetNotFound:)]) {
                [self.securityPolicy evrouter:self.router targetNotFound:targetName];
            } else if (code != EVRouterErrorCodeTargetNotFound && [self.securityPolicy respondsToSelector:@selector(evrouter:target:actionNotFound:)]) {
                [self.securityPolicy evrouter:self.router target:targetName actionNotFound:actionName];
            }
        }
        return nil;
    };
    
    id errRet = nil;
    Class CLS = NSClassFromString(targetName);
    if (CLS) {
        SEL selector = NSSelectorFromString(actionName);
        
        if (actionType == EVRouterActionTypeClass) {
            if ([CLS respondsToSelector:selector]) {
                id ret = [self safePerformTarget:CLS action:selector params:params];
                return ret;
            } else {
                errRet = safeErrorBlock([NSString stringWithFormat:@"EVRouter:class action: %@ not found!",actionName],EVRouterErrorCodeClassActionNotFound);
            }
        } else if (actionType == EVRouterActionTypeInstance) {
            NSObject *target = [[CLS alloc] init];
            if ([target respondsToSelector:selector]) {
                id ret = [self safePerformTarget:target action:selector params:params];
                return ret;
            } else {
                errRet = safeErrorBlock([NSString stringWithFormat:@"EVRouter:instance action: %@ not found!",actionName],EVRouterErrorCodeInstanceActionNotFound);
            }
        } else if (actionType == EVRouterActionTypeUnknown) {
            if ([CLS respondsToSelector:selector]) {
                id ret = [self safePerformTarget:CLS action:selector params:params];
                return ret;
            }
            NSObject *target = [[CLS alloc] init];
            if ([target respondsToSelector:selector]) {
                id ret = [self safePerformTarget:target action:selector params:params];
                return ret;
            }
            errRet = safeErrorBlock([NSString stringWithFormat:@"EVRouter:action: %@ not found!",actionName],EVRouterErrorCodeClassAndInstanceActionNotFound);
        } else {
            NSAssert(false, @"EVRouter: action type is error!");
        }
    } else {
        errRet = safeErrorBlock([NSString stringWithFormat:@"EVRouter:target: %@ not found!",targetName],EVRouterErrorCodeTargetNotFound);
    }
    return errRet;
}

- (id)safePerformTarget:(id)target action:(SEL)action params:(NSDictionary *)params {
    NSMethodSignature *signature = [target methodSignatureForSelector:action];
    
    if (signature == nil) {
        NSAssert(false, @"EVRouter:methodSignatureForSelector can't be nil!");
        return nil;
    }

    const char * returnType = signature.methodReturnType;
    CHECK_VOID_TYPE
    CHECK_BASIC_TYPE(char)
    CHECK_BASIC_TYPE(int)
    CHECK_BASIC_TYPE(short)
    CHECK_BASIC_TYPE(long)
    CHECK_BASIC_TYPE(long long)
    CHECK_BASIC_TYPE(unsigned char)
    CHECK_BASIC_TYPE(unsigned int)
    CHECK_BASIC_TYPE(unsigned short)
    CHECK_BASIC_TYPE(unsigned long)
    CHECK_BASIC_TYPE(unsigned long long)
    CHECK_BASIC_TYPE(float)
    CHECK_BASIC_TYPE(double)
    CHECK_BASIC_TYPE(BOOL)
    CHECK_CHAR_POINTER_TYPE
    CHECK_SEL_TYPE
    CHECK_STRUCT_TYPE
    CHECK_POINTER_TYPE
    CHECK_BLOCK_TYPE

    if (strcmp(returnType, @encode(id)) == 0 || strcmp(returnType, @encode(Class)) == 0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id ret = [target performSelector:action withObject:params];
#pragma clang diagnostic pop
        return ret;
    } else {
        //unsupported type: union/c array/bit/unknown type
        NSLog(@"EVRouter:unsupported type: %s",returnType);
        if (self.securityPolicy && [self.securityPolicy respondsToSelector:@selector(evrouter:unsupportedReturnType:)]) {
            return [self.securityPolicy evrouter:self.router unsupportedReturnType:returnType];
        }
    }
    
    return nil;
}

@end
