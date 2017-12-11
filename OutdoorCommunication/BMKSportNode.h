//
//  BMKSportNode.h
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/10.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import <Foundation/Foundation.h>

// 运动结点信息类
@interface BMKSportNode : NSObject

//经纬度
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
//方向（角度）
@property (nonatomic, assign) CGFloat angle;
//距离
@property (nonatomic, assign) CGFloat distance;
//速度
@property (nonatomic, assign) CGFloat speed;

@end
