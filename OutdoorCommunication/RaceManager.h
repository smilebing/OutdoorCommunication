//
//  RaceManager.h
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/2/14.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BmobSDK/Bmob.h>

#define bmob_RACE @"race"
#define bmob_RACE_NAME @"name"
#define bmob_RACE_LOCATION @"location"
#define bmob_RACE_DETAIL @"detail"
#define bmob_RACE_CREATER @"creater"
#define bmob_RACE_RACERID @"racerID"
#define bmob_RACE_CHECKPOINT @"checkPoints"
#define bmob_RACE_OBJECTID @"objectId"


@class RaceEntity;

@interface RaceManager : NSObject

//单例
+ (instancetype)sharedInstance;

/*
 *创建比赛
 */
-(void)creatRace:(NSString *)raceName
        location:(NSString *)location
         details:(NSString * )detail
         creater:(NSString *)username
      completion:(void (^)(BOOL success
                           ,NSError * error
                           ,NSString *objectId))completion;

/*
 *删除比赛
 */
-(void)deleteRace:(NSString *)username
         racename:(NSString *)raceName
         objectID:(NSString *)objectID
       completion:(void (^)(BOOL success
                            ,NSError * error))completion;

/*
 *修改检查点
 */
-(void)editCheckPoints:(NSString   *)objectID
           checkPoints:(NSMutableDictionary *)checkPoints
            completion:(void (^)(BOOL success
                                 ,NSError * error))completion;
/*
 *获取本地缓存比赛
 */
-(NSMutableArray *)getRaces;


/*
 *获取数据库中的最新数据并存储到内存中
 */
-(void)updateLocalRaces:(void (^)(BOOL success
                                             ,NSError * error))completion;

/*
 *加入比赛
 */
-(void)joinRace:(NSString *)objectID
     completion:(void (^)(BOOL success
                          ,NSError * error))completion;


/*
 *退出比赛
 */
-(void)quitRace:(NSString *)objectID
     completion:(void (^)(BOOL success
                          ,NSError * error))completion;


/*
 *查找当前用户创建的比赛
 */
-(NSMutableArray *)getCurrentUserCreatedRace;

@end


//比赛的entity
@interface RaceEntity : NSObject

+ (instancetype)initWithBmobObject:(BmobObject*)object;

@property (nonatomic,strong) NSString *objectId;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *deatil;
@property (nonatomic,strong) NSString *creater;
@property (nonatomic,strong) NSString *location;
@property (nonatomic,strong) NSArray *racerID;
@property (nonatomic,strong) NSArray *points;



@end



