//
//  HistoryRouteManage.h
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/9.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BmobSDK/Bmob.h>




@interface HistoryRouteManage : NSObject<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,copy) NSString * username;
@property(nonatomic,copy) NSString * objectID;
@property(nonatomic,strong) BmobObject * object;


//单例
+ (instancetype)sharedInstance;

//设置开始时间
- (void)uploadStartTimeInBackground:(NSDate * )startTime
                     completion:(void (^)(BOOL success, NSError *error))completion;


//设置结束时间
- (void)uploadEndTimeInBackground:(NSDate * )endTime
                 historyRouteName:(NSString *)historyRouteName
                         completion:(void (^)(BOOL success, NSError *error))completion;


//查找所有轨迹
-(void)searchAllHistoryRoute:(void (^)(NSArray * result, NSError *error))completion;


//根据开始时间和结束时间进行搜索
-(void)searchHistoryRoute:(NSDate * )startTime
                              endTime:(NSDate *)endTime
                           completion:(void (^)(NSArray * result, NSError *error))completion;


@end
