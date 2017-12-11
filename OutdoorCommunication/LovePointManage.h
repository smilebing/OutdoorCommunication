//
//  LovePointManage.h
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/8.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BmobSDK/Bmob.h>




@class LovePointEntity;

@interface LovePointEntity : NSObject
//单例
+ (instancetype)initWithBmobObject:(BmobObject*)object;

@property (nonatomic,strong) NSString *objectId;

@property (nonatomic,strong) NSString *userID;

@property (nonatomic,strong) NSString *location;

@property (nonatomic,strong) NSString *imageUrl1;



@end




@interface LovePointManage : NSObject
@property(nonatomic,strong) BmobACL * defaultACL;

//单例
+ (instancetype)sharedInstance;

/*
 *  上传图片
 */
- (void)uploadImageInBackground:(UIImage*)image
                       location:(NSString *)location
                    description:(NSString *)description
completion:(void (^)(BOOL success, NSError *error))completion;
/*
 *  上传笔记
 */
- (void)updateDetailInBackground:(NSString*)detail
                           completion:(void (^)(BOOL success, NSError *error))completion;

/*
 *  获取用户标注点 by userID,时间点
 */
- (void)searchLovePointInBackground:(NSString*)userID
                       starTime:(NSString *)startTime
                            endTime:(NSString *)endTime
                         completion:(void (^)(NSArray * result, NSError *error))completion;
@end
