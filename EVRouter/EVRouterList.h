//
//  EVRouterList.h
//  EVRouter
//
//  Created by Ever on 2019/2/21.
//  Copyright © 2019 Ever. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVRouterListUpdatePolicy.h"

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

@interface EVRouterList : NSObject

/**
 路由表是否可用
 */
@property (nonatomic, assign, getter = isReady) BOOL ready;

/**
 更新路由表代理
 */
@property (nonatomic, strong) id<EVRouterListUpdatePolicy> updatePolicy;

/**
 查询映射后的Target

 @param targetName targetName
 @return 映射后的targetName
 */
- (NSString *)mapTarget:(NSString *)targetName;

/**
 查询映射后的action

 @param acitonName actionName
 @param targetName targetName
 @return 映射后的actionName
 */
- (NSString *)mapAction:(NSString *)acitonName forTarget:(NSString *)targetName;

/**
 更新路由表
 */
- (void)update;

@end

