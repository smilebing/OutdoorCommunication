//
//  UserLocationManage.h
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/11.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserLocationManage : NSObject
//单例
+ (instancetype)sharedInstance;


//上传用户位置
-(void)uploadUserLocation:(NSString *)username
                 location:(NSString *)location
               completion:(void (^)(BOOL success, NSError *error))completion;


//按照群组id查找组内用户的位置
-(void)searchGroupUserLocation:(NSArray *)userArray
                    completion:(void (^)(NSArray * result, NSError *error))completion;



@end
