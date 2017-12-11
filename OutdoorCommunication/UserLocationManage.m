//
//  UserLocationManage.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/11.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "UserLocationManage.h"
#import <BmobSDK/Bmob.h>

static UserLocationManage *sharedInstance = nil;


@implementation UserLocationManage
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


//上传用户位置
-(void)uploadUserLocation:(NSString *)username
                 location:(NSString *)location
               completion:(void (^)(BOOL success, NSError *error))completion
{
    //设置查询条件
    BmobQuery * query=[BmobQuery queryWithClassName:bmob_USER_LOCATION];
    [query whereKey:bmob_USER_LOCATION_USERNAME equalTo:username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if(!error)
        {
            //查找成功
            if([array count]>0)
            {
                //已经存在,更新数据
                BmobObject * object=[array objectAtIndex:0];
                [object deleteForKey:bmob_USER_LOCATION_UPDATED_AT];
                [object deleteForKey:bmob_USER_LOCATION_CREATED_AT];
                [object setObject:location forKey:bmob_USER_LOCATION_LOCATION];
                [object updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    completion(isSuccessful,error);
                }];
            }
            else
            {
                //新建数据
                BmobObject * object=[BmobObject objectWithClassName:bmob_USER_LOCATION];
                [object setObject:username forKey:bmob_USER_LOCATION_USERNAME];
                [object setObject:location forKey:bmob_USER_LOCATION_LOCATION];
                
                //保存
                [object saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    completion(isSuccessful,error);
                }];
            }
        }
        else
        {
            completion(NO,error);
        }
    }];
}


//安装群组id查找组内用户的位置
-(void)searchGroupUserLocation:(NSArray *)userArray
                    completion:(void (^)(NSArray * result, NSError *error))completion
{
    BmobQuery * query=[BmobQuery queryWithClassName:bmob_USER_LOCATION];
    
    //构造查询条件
    [query whereKey:bmob_USER_LOCATION_USERNAME containedIn:userArray];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        completion(array,error);
    }];
}


@end
