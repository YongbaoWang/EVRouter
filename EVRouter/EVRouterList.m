//
//  EVRouterList.m
//  EVRouter
//
//  Created by Ever on 2019/2/21.
//  Copyright © 2019 Ever. All rights reserved.
//

#import "EVRouterList.h"

//[
//     {
//         "target": { //转发对象A  到 对象B
//             "from": "A",
//             "to": "B"
//         },
//         "action": [] //为空，表示只更改转发对象
//     },
//     {
//         "target": { //转发对象一致，表示 转发对象不变动
//             "from": "A",
//             "to": "A"
//         },
//         "action": [{ //转发 方法a 到 方法b
//             "from": "a",
//             "to": "b",
//         }]
//     }
// ]

@interface NSDictionary (EVRouter)

- (id)safeObjectForKey:(NSString *)key;

@end

@implementation NSDictionary (EVRouter)

- (id)safeObjectForKey:(NSString *)key {
    if ([self.allKeys containsObject:key]) {
        return self[key];
    }
    return nil;
}

@end

@interface EVRouterList ()

//存放原始target
@property (nonatomic, strong) NSMutableArray<NSString *> *originalTargetArrayM;
//存放新的target
@property (nonatomic, strong) NSMutableArray<NSString *> *nowTargetArrayM;
//key为新target-原始action，value为新action
@property (nonatomic, strong) NSMutableDictionary<NSString *,NSString *> *actionDicM;

@end

@implementation EVRouterList

- (instancetype)init {
    self = [super init];
    if (self) {
        _ready = NO;
        _originalTargetArrayM = [[NSMutableArray alloc] initWithCapacity:0];
        _nowTargetArrayM = [[NSMutableArray alloc] initWithCapacity:0];
        _actionDicM = [[NSMutableDictionary alloc] initWithCapacity:0];
        [self loadRouterList];
    }
    return self;
}

- (void)loadRouterList {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *path = [self routerListPath];
        NSArray *list = [[NSArray alloc] initWithContentsOfFile:path];
        
        [self handleRouterList:list];
        self.ready = YES;
    });
}

- (void)saveRouterList:(NSArray *)array {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *path = [self routerListPath];
        [array writeToFile:path atomically:YES];
    });
}

- (NSString *)routerListPath {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:@"routerlist"];
    return path;
}

- (void)handleRouterList:(NSArray *)list {
    [self.originalTargetArrayM removeAllObjects];
    [self.nowTargetArrayM removeAllObjects];
    [self.actionDicM removeAllObjects];
    
    for (NSDictionary *item in list) {
        NSDictionary *targetDic = [item safeObjectForKey:@"target"];
        
        NSString *fromTarget = [targetDic safeObjectForKey:@"from"];
        NSString *toTarget = [targetDic safeObjectForKey:@"to"];
        
        if (fromTarget.length > 0 && toTarget.length > 0) {
            [self.originalTargetArrayM addObject:fromTarget];
            [self.nowTargetArrayM addObject:toTarget];
            
            NSArray *actionArray = [item safeObjectForKey:@"action"];
            for (NSDictionary *actionItem in actionArray) {
                NSString *fromAction = [actionItem safeObjectForKey:@"from"];
                NSString *toAction = [actionItem safeObjectForKey:@"to"];
                
                if (fromAction.length > 0 && toAction.length > 0) {
                    NSString *key = [NSString stringWithFormat:@"%@-%@",toTarget,fromAction];
                    [self.actionDicM setObject:toAction forKey:key];
                }
            }
        }
    }
}

- (NSString *)mapTarget:(NSString *)targetName {
    if (self.isReady) {
        if ([self.originalTargetArrayM containsObject:targetName]) {
            NSUInteger index = [self.originalTargetArrayM indexOfObject:targetName];
            return self.nowTargetArrayM[index];
        }
    }
    return targetName;
}

- (NSString *)mapAction:(NSString *)acitonName forTarget:(NSString *)targetName {
    if (self.isReady) {
        NSString *key = [NSString stringWithFormat:@"%@-%@",targetName,acitonName];
        NSString *value = [self.actionDicM safeObjectForKey:key];
        if (value.length > 0) {
            return value;
        }
    }
    return acitonName;
}

- (void)update {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (self.updatePolicy && [self.updatePolicy respondsToSelector:@selector(getNewRouterList:)]) {
            [self.updatePolicy getNewRouterList:^(NSArray *list) {
                self.ready = NO;
                [self saveRouterList:list];
                [self handleRouterList:list];
            }];
        }
    });
}

- (NSArray *)mockdata {
    return @[ @{@"target":@{@"from":@"A",@"to":@"B"},
                @"action": @[]
                },
              @{@"target":@{@"from":@"C",@"to":@"C"},
                @"action": @[@{@"from":@"a",@"to":@"b"}]
                },
              ];
}

@end
