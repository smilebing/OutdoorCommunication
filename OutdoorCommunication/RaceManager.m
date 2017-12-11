//
//  RaceManager.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/2/14.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "RaceManager.h"

#define kCURRENT_USERNAME [[EMClient sharedClient] currentUsername]

static RaceManager *sharedInstance = nil;
@interface RaceManager()
{
    NSString *_curusername;
}

@property (nonatomic, strong) NSMutableArray *races;
@property (nonatomic,strong)  NSMutableArray* myRaces;
@property (nonatomic, strong) NSString *objectId;
@property(nonatomic,strong) BmobACL * defaultACL;
@end



@implementation RaceManager


+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _races = [[NSMutableArray alloc]initWithCapacity:1];
        _myRaces=[[NSMutableArray alloc]init];
        
        _defaultACL=[BmobACL ACL];
        //设置所有人读权限为true
        [_defaultACL setPublicReadAccess];
        //设置所有人写权限为true
        [_defaultACL setPublicWriteAccess];
    }
    
    _curusername=kCURRENT_USERNAME;
    return self;
}



/*
 *创建比赛
 */
-(void)creatRace:(NSString *)name
        location:(NSString *)location
         details:(NSString * )detail
         creater:(NSString *)creater
      completion:(void (^)(BOOL success
                           ,NSError * error
                           ,NSString * objectId))completion
{
    BmobObject * object=[BmobObject objectWithClassName:bmob_RACE];
    [object setObject:name forKey:bmob_RACE_NAME];
    [object setObject:location forKey:bmob_RACE_LOCATION];
    [object setObject:detail forKey:bmob_RACE_DETAIL];
    [object setObject:creater forKey:bmob_RACE_CREATER];
    
    //更新
    [object saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if(!isSuccessful)
        {
            NSLog(@"创建比赛出错：%@",error);
        }
        NSLog(@"id:%@",object.objectId);
        completion(isSuccessful,error,object.objectId);
    }];
}

/*
 *修改检查点
 */
-(void)editCheckPoints:(NSString   *)objectID
           checkPoints:(NSMutableDictionary *)checkPoints
            completion:(void (^)(BOOL success
                                 ,NSError * error))completion
{
    BmobObject * object=[BmobObject objectWithoutDataWithClassName:bmob_RACE objectId:objectID];
    
    NSData *data=[NSJSONSerialization dataWithJSONObject:checkPoints options:NSJSONWritingPrettyPrinted error:nil];
    NSString *str=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"JsonStr:%@",str);
    
    [object setObject:str forKey:bmob_RACE_CHECKPOINT];
    [object updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if(!isSuccessful)
        {
            NSLog(@"修改检查点出错%@",error);
        }
        completion(isSuccessful,error);
    }];
}


/*
 *删除比赛
 */
-(void)deleteRace:(NSString *)username
         racename:(NSString *)raceName
         objectID:(NSString *)objectID
       completion:(void (^)(BOOL success
                            ,NSError * error))completion
{
    
}

/*
 *获取数据库中的最新数据并存储到内存中
 */
-(void)updateLocalRaces:(void (^)(BOOL success,NSError * error))completion
{
    BmobQuery * query=[BmobQuery queryWithClassName:bmob_RACE];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if(!error)
        {
            //没有错误，更新本地缓存
            if(array&&[array count]>0)
            {
                //清空本地缓存
                if(_races.count)
                {
                    [_races removeAllObjects];
                }
                
                //清空本地缓存
                if(_myRaces.count)
                {
                    [_myRaces removeAllObjects];
                }
                
                for(id race in array)
                {
                    if([race isKindOfClass:[BmobObject class]])
                    {
                        RaceEntity * entity=[RaceEntity initWithBmobObject:race];
                        //存储到内存中
                        [_races addObject:entity];
                        //查找出当前用户创建的比赛
                        if(entity.creater==_curusername)
                        {
                            [_myRaces addObject:entity];
                        }
                    }
                }
            }
            completion(YES,error);
        }
        else
        {
            if(error)
            {
                NSLog(@"获取比赛出错：%@",error);
            }
            completion(NO,error);
        }
    }];
}


/*
 *查询比赛
 */
-(NSMutableArray *)getRaces
{
    return _races;
}


/*
 *加入比赛
 */
-(void)joinRace:(NSString *)objectID
     completion:(void (^)(BOOL success
                          ,NSError * error))completion
{
    BmobObject * object=[BmobObject objectWithoutDataWithClassName:bmob_RACE objectId:objectID ];
    [object addObjectsFromArray:@[_curusername] forKey:bmob_RACE_RACERID];
    
    
    [object updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if(!isSuccessful)
        {
            NSLog(@"加入比赛出错：%@",error);
        }
        completion(isSuccessful,error);
    }];
}


/*
 *退出比赛
 */
-(void)quitRace:(NSString *)objectID
     completion:(void (^)(BOOL success
                          ,NSError * error))completion
{
    BmobObject * object=[BmobObject objectWithoutDataWithClassName:bmob_RACE objectId:objectID];
    [object removeObjectsInArray:@[_curusername] forKey:bmob_RACE_RACERID];
    
    
    [object updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if(!isSuccessful)
        {
            NSLog(@"退出比赛出错：%@",error);
        }
        completion(isSuccessful,error);
    }];
}


/*
 *查找当前用户创建的比赛
 */
-(NSMutableArray *)getCurrentUserCreatedRace
{
    return _myRaces;
}


@end


@implementation RaceEntity

+ (instancetype) initWithBmobObject:(BmobObject *)object
{
    RaceEntity *entity = [[RaceEntity alloc] init];
    entity.name=[object objectForKey:bmob_RACE_NAME];
    entity.objectId=[object objectForKey:bmob_RACE_OBJECTID];
    entity.deatil=[object objectForKey:bmob_RACE_DETAIL];
    entity.creater=[object objectForKey:bmob_RACE_CREATER];
    entity.points=[object objectForKey: bmob_RACE_CHECKPOINT];
    entity.location=[object objectForKey:bmob_RACE_LOCATION];
    entity.racerID=[object objectForKey:bmob_RACE_RACERID];
    return entity;
}




@end
