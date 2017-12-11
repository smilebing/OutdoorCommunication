//
//  ShareRouteManage.h
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/11.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareRouteManage : NSObject
//单例
+ (instancetype)sharedInstance;


//上传线路信息
-(void)uploadRoute:(NSString *)routeName
         startTime:(NSDate *)startTime
           endTime:(NSDate *)endTime
           creater:(NSString *)userName
          distance:(NSString *)distance
        completion:(void (^)(BOOL success, NSError *error))completion;

//获取所有轨迹
-(void)searchAllShareRoute:(void (^)(NSArray * result, NSError *error))completion;

//获取莫某个人共享的轨迹
-(void)searchRouteByUsername:(NSString *)username
                       completion:(void (^)(NSArray * result, NSError *error))completion;



@end
