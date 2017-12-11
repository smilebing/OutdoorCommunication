//
//  ShareRouteManage.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/11.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "ShareRouteManage.h"
#import <BmobSDK/Bmob.h>

static ShareRouteManage *sharedInstance = nil;


@implementation ShareRouteManage
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


//上传线路信息
-(void)uploadRoute:(NSString *)routeName
         startTime:(NSDate *)startTime
           endTime:(NSDate *)endTime
           creater:(NSString *)userName
          distance:(NSString *)distance
        completion:(void (^)(BOOL success, NSError *error))completion
{
    BmobObject * object=[BmobObject objectWithClassName:bmob_SHARE_ROUTE];
    
    //设置键值对
    [object setObject:routeName forKey:bmob_SHARE_ROUTE_NAME];
    [object setObject:startTime forKey:bmob_SHARE_ROUTE_START_TIME];
    [object setObject:endTime forKey:bmob_SHARE_ROUTE_END_TIME];
    [object setObject:distance forKey:bmob_SHARE_ROUTE_DISTANCE];
    [object setObject:userName forKey:bmob_SHARE_ROUTE_USERNAME];
    
    //保存
    [object saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        completion(isSuccessful,error);
    }];
}

//查找所有
-(void)searchAllShareRoute:(void (^)(NSArray * result, NSError *error))completion
{
    BmobQuery * query =[BmobQuery queryWithClassName:bmob_SHARE_ROUTE];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        completion(array,error);
    }];
}


//获取某个人共享的轨迹
-(void)searchRouteByUsername:(NSString *)username
                       completion:(void (^)(NSArray * result, NSError *error))completion
{
    BmobQuery * query=[BmobQuery queryWithClassName:bmob_SHARE_ROUTE];
    [query whereKey:bmob_SHARE_ROUTE_USERNAME equalTo:username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        completion(array,error);
    }];
}



@end
