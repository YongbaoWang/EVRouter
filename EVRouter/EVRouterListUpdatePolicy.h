//
//  EVRouterListUpdatePolicy.h
//  EVRouter
//
//  Created by Ever on 2019/2/21.
//  Copyright © 2019 Ever. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EVRouterListUpdatePolicy <NSObject>

@required
//list 结构
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
- (void)getNewRouterList:(void(^)(NSArray *list))complete;

@end

