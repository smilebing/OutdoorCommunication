//
//  HistoryRouteManage.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/9.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "HistoryRouteManage.h"

static HistoryRouteManage *sharedInstance = nil;

@implementation HistoryRouteManage

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


//设置开始时间
- (void)uploadStartTimeInBackground:(NSDate * )startTime
                         completion:(void (^)(BOOL success, NSError *error))completion
{
    //插入
    BmobObject * saveObject =[BmobObject objectWithClassName:bmob_HISTORY_ROUTE];
    [saveObject setObject: [[EMClient sharedClient] currentUsername] forKey:bmob_HISTORY_ROUTE_USERNAME];
    [saveObject setObject:startTime forKey:bmob_HISTORY_ROUTE_START_TIME];
    
    [saveObject saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
       if(isSuccessful)
       {
           _object=saveObject;
       }
        completion(isSuccessful,error);
    }];
    //获取 objectID
}


//设置结束时间
- (void)uploadEndTimeInBackground:(NSDate * )endTime
                 historyRouteName:(NSString *)historyRouteName
                       completion:(void (^)(BOOL success, NSError *error))completion
{
    if(_object!=nil)
    {
        [_object setObject:historyRouteName forKey:bmob_HISTORY_ROUTE_HISTORY_ROUTE_NAME];
        [_object setObject:endTime forKey:bmob_HISTORY_ROUTE_END_TIME];
        [_object updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            completion(isSuccessful,error);
        }];
    }
}


//查找所有轨迹
-(void)searchAllHistoryRoute:(void (^)(NSArray * result, NSError *error))completion
{
    //构造查询语句
    BmobQuery  * bquery = [BmobQuery queryWithClassName:bmob_HISTORY_ROUTE];
    
    [bquery whereKey:bmob_HISTORY_ROUTE_USERNAME equalTo:[[EMClient sharedClient]currentUsername]];
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        completion(array,error);
    }];

}

//根据开始时间和结束时间进行搜索
-(void)searchHistoryRoute:(NSDate * )startTime
                              endTime:(NSDate *)endTime
                           completion:(void (^)(NSArray * result, NSError *error))completion

{
    //构造查询语句
    BmobQuery  * bquery = [BmobQuery queryWithClassName:bmob_HISTORY_ROUTE];
    
    [bquery whereKey:bmob_HISTORY_ROUTE_USERNAME equalTo:[[EMClient sharedClient]currentUsername]];
    
    [bquery whereKey:bmob_HISTORY_ROUTE_END_TIME lessThanOrEqualTo:endTime];
    
    [bquery whereKey:bmob_HISTORY_ROUTE_START_TIME greaterThanOrEqualTo:startTime];
    
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        completion(array,error);
    }];
}


@end
