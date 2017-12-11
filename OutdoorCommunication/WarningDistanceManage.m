//
//  WarningDistanceManage.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/27.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "WarningDistanceManage.h"

#define USER_WARNING_DISTANCE @"warning_distance"

@implementation WarningDistanceManage

//设置距离
+(void)setDestance:(NSInteger) distance
{
    NSUserDefaults * userDefault=[NSUserDefaults standardUserDefaults];
    
    [userDefault setInteger:distance forKey:USER_WARNING_DISTANCE];
}

//获取距离
+(NSInteger)getDistance
{
    NSUserDefaults * userDefault=[NSUserDefaults standardUserDefaults];

    float distance = [userDefault integerForKey:USER_WARNING_DISTANCE];
    
    if(distance==0)
    {
        return 100;
    }
    
    return distance;

}


@end
