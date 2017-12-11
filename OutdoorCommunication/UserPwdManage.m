//
//  UserPwdManage.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/26.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#define USER_PASSWORD @"userPassword"

#import "UserPwdManage.h"
#import <AFNetworking/AFNetworking.h>

@implementation UserPwdManage

//获取密码
-(NSString *)getUserPwd
{
    NSUserDefaults * userDefault=[NSUserDefaults standardUserDefaults];

    NSString * pwd= [userDefault objectForKey:USER_PASSWORD];
    
    return pwd;
}

//存储密码
-(void)saveUserPwd:(NSString *)pwd
{
    NSUserDefaults * userDefault=[NSUserDefaults standardUserDefaults];
    [userDefault setObject:pwd forKey:USER_PASSWORD];
}

//清除密码
-(void)clearUserPwd
{
    NSUserDefaults * userDefault=[NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:USER_PASSWORD];
}

@end
