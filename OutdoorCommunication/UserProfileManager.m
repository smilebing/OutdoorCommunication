/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "UserProfileManager.h"
#import <BmobSDK/Bmob.h>
//#import "MessageModel.h"

#define kCURRENT_USERNAME [[EMClient sharedClient] currentUsername]

@implementation UIImage (UIImageExt)

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

@end

static UserProfileManager *sharedInstance = nil;
@interface UserProfileManager ()
{
    NSString *_curusername;
}

@property (nonatomic, strong) NSMutableDictionary *users;
@property (nonatomic, strong) NSString *objectId;
@property(nonatomic,strong) BmobACL * defaultACL;
@end

@implementation UserProfileManager

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
        _users = [NSMutableDictionary dictionary];
        
        _defaultACL=[BmobACL ACL];
        //设置所有人读权限为true
        [_defaultACL setPublicReadAccess];
        //设置所有人写权限为true
        [_defaultACL setPublicWriteAccess];
    }
    return self;
}


-(void)initBmob
{
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        id objectId = [ud objectForKey:[NSString stringWithFormat:@"%@%@",kPARSE_HXUSER,kCURRENT_USERNAME]];
        if (objectId) {
            self.objectId = objectId;
        }
        _curusername = kCURRENT_USERNAME;
        [self initData];
    
}



-(void)clearBmob
{
        self.objectId = nil;
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud removeObjectForKey:[NSString stringWithFormat:@"%@%@",kPARSE_HXUSER,_curusername]];
         _curusername = nil;
        [self.users removeAllObjects];
}

- (void)initData
{
    [self.users removeAllObjects];

    //查找表
    BmobQuery  * bquery = [BmobQuery queryWithClassName:kPARSE_HXUSER];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
//        if (!error) {
//            if (objects && [objects count] > 0) {
//                BmobObject *object = [objects objectAtIndex:0];
//                [object setACL:weakSelf.defaultACL];
//                weakSelf.objectId = object.objectId;
//                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//                [ud setObject:object.objectId forKey:[NSString stringWithFormat:@"%@%@",kPARSE_HXUSER,kCURRENT_USERNAME]];
//                [ud synchronize];
//                if (completion) {
//                    completion (object, error);
//                }
//            } else {
//                BmobObject *object = [BmobObject objectWithClassName:kPARSE_HXUSER];
//                [object setObject:kPARSE_HXUSER_USERNAME forKey:kCURRENT_USERNAME];
//                completion (object, error);
//            }
//        } else {
//            if (completion) {
//                completion (nil, error);
//            }
//        }
        if(!error)
        {
            if (array && [array count] > 0) {
                for (id user in array) {
                    if ([user isKindOfClass:[BmobObject class]]) {
                        UserProfileEntity *entity = [UserProfileEntity initWithBmobObject:user];
                        BmobObject * object= user;
                        [object setACL:self.defaultACL];
                        //NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                        //[ud setObject:object.objectId forKey:[NSString stringWithFormat:@"%@%@",kPARSE_HXUSER,entity.username]];
                        //[ud synchronize];
                        if (entity.username.length > 0) {
                            [self.users setObject:entity forKey:entity.username];
                            if(entity.username==_curusername)
                            {
                                NSLog(@"find this");
                                self.objectId=object.objectId;
                            }
                        }
                    }
                }
            }
        }
        else
        {
            
        }
    }];
    
}

//获取数据库中的id
-(void)getObjectID:(NSString *)userID
{
    BmobQuery * query=[BmobQuery queryWithClassName:kPARSE_HXUSER];
    NSString * username=[EMClient sharedClient].currentUsername;
    [query whereKey:kPARSE_HXUSER_USERNAME equalTo:username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if([array count]>0)
        {
            //如果存在
           // self.objectId=[array[0] ]
        }
    }];
}



//注册
-(void)registerWithPassword:(NSString * )username
                   password:(NSString * )password
                 completion:(void (^)(BOOL success, NSError *error))completion
{
    BmobObject * object=[BmobObject objectWithClassName:kPARSE_HXUSER];
    [object setObject:username forKey:kPARSE_HXUSER_USERNAME];
    [object setObject:password forKey:kPARSE_HXUSER_PASSWORD];
    
    BmobQuery * query=[BmobQuery queryWithClassName:kPARSE_HXUSER];
    [query whereKey:kPARSE_HXUSER_USERNAME equalTo:username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
       //判断是否已经存在记录
        if(!error && array.count==0)
       {
           //插入
           [object saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
               completion(isSuccessful,error);
           }];
       }
        else
        {
            completion(NO,error);
        }
    }];
}


//修改密码
-(void)changeUserPassword:(NSString *)username
              oldPassword:(NSString *)oldPassword
              newPassword:(NSString *)newPassword
               completion:(void (^)(BOOL success, NSError *error))completion
{
    BmobQuery * query =[BmobQuery queryWithClassName:kPARSE_HXUSER];
    [query whereKey:kPARSE_HXUSER_USERNAME equalTo:username];
    [query whereKey:kPARSE_HXUSER_PASSWORD equalTo:oldPassword];
    
    //查询
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if(error)
        {
            completion(NO,error);
        }
        else if(array.count<=0)
        {
            //没有找到用户
            completion(NO,nil);
        }
        else
        {
            BmobObject * object= [array objectAtIndex:0];
            //找到用户，更新密码
            [object setObject:kPARSE_HXUSER_PASSWORD forKey:newPassword];
            
            [object updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                completion(isSuccessful,error);
            }];
        }
    }];
}


//上传用户头像
- (void)uploadUserHeadImageProfileInBackground:(UIImage*)image
                           completion:(void (^)(BOOL success, NSError *error))completion
{
    UIImage *img = [image imageByScalingAndCroppingForSize:CGSizeMake(120.f, 120.f)];
    if (_objectId && _objectId.length > 0) {
        NSLog(@"id:%@",_objectId);
        
        BmobObject *object=[BmobObject objectWithoutDataWithClassName:kPARSE_HXUSER objectId:_objectId];
        NSData *imageData = UIImageJPEGRepresentation(img, 0.5);
        BmobFile * imageFile=[[BmobFile alloc]initWithFileName:@"image.png" withFileData:imageData];


        [imageFile saveInBackground:^(BOOL isSuccessful, NSError *error) {
           
                if(isSuccessful)
                {
                    [object setObject:imageFile forKey:kPARSE_HXUSER_AVATAR];
                    //更新
                    [object updateInBackground];
                    //__weak BmobObject * weakObj=object;
                    //[self saveBmobUserInDisk:weakObj];
                }
              
                completion(isSuccessful,error);
            
        }];

    } else {
        [self queryBmobObjectWithCompletion:^(BmobObject *object, NSError *error) {
            if (object) {
                NSData *imageData = UIImageJPEGRepresentation(img, 0.5);
                BmobFile *imageFile = [[BmobFile alloc]initWithFileName:@"image.png" withFileData:imageData];

                [imageFile saveInBackground:^(BOOL isSuccessful, NSError *error) {

                        if(isSuccessful)
                        {
                            [object setObject:imageFile forKey:kPARSE_HXUSER_AVATAR];
                            [object setObject:_curusername forKey:kPARSE_HXUSER_USERNAME];
                            [object saveInBackground];
                            //__weak BmobObject * weakObj=object;
                            //[self saveBmobUserInDisk:weakObj];
                        }
                        completion(isSuccessful,error);
                    
                  
                }];
            } else {
                if (completion) {
                    completion(NO,error);
                }

            }
        }];
    }
}

//上传用户信息
- (void)updateUserProfileInBackground:(NSDictionary*)param
                           completion:(void (^)(BOOL success, NSError *error))completion
{
    if (_objectId && _objectId.length > 0) {
        NSLog(@"you id:%@",_objectId);
        BmobObject * object=[BmobObject objectWithoutDataWithClassName:kPARSE_HXUSER objectId:_objectId];
        if( param!=nil && [[param allKeys] count] > 0) {
            for (NSString *key in param) {
                [object setObject:[param objectForKey:key] forKey:key];
            }
        }
        __weak BmobObject* weakObj = object;
        [object updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            if(isSuccessful)
            {
                [self saveBmobUserInDisk:weakObj];
            }
            completion(isSuccessful,error);
        }];


    } else {

        [self queryBmobObjectWithCompletion:^(BmobObject *object, NSError *error) {
            if(object)
            {
                                if( param!=nil && [[param allKeys] count] > 0) {
                                    for (NSString *key in param) {
                                        [object setObject:[param objectForKey:key] forKey:key];
                                    }
                                }
                                __weak BmobObject* weakObj = object;
                [object saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                 
                        if(isSuccessful)
                        {
                            [self saveBmobUserInDisk:weakObj];
                        }
                        completion(isSuccessful,error);
                    
                }];

            }else
            {
                if(completion){
                    completion(NO,error);
                }
            }
        }];
    }
}

- (void)loadUserProfileInBackgroundWithBuddy:(NSArray*)buddyList
                                saveToLoacal:(BOOL)save
                                  completion:(void (^)(BOOL success, NSError *error))completion
{
    NSMutableArray *usernames = [NSMutableArray array];
    for (NSString *buddy in buddyList)
    {
        if ([buddy length])
        {
            if (![self getUserProfileByUsername:buddy]) {
                [usernames addObject:buddy];
            }
        }
    }
    if ([usernames count] == 0) {
        if (completion) {
            completion(YES,nil);
        }
        return;
    }
    [self loadUserProfileInBackground:usernames saveToLoacal:save completion:completion];
}

- (void)loadUserProfileInBackground:(NSArray*)usernames
                       saveToLoacal:(BOOL)save
                         completion:(void (^)(BOOL success, NSError *error))completion
{
    BmobQuery * query=[BmobQuery queryWithClassName:kPARSE_HXUSER];
    [query whereKey:kPARSE_HXUSER_USERNAME containedIn:usernames];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (id user in objects) {
                if ([user isKindOfClass:[BmobObject class]]) {
                    BmobObject *pfuser = (BmobObject*)user;
                    if (save) {
                        [self saveBmobUserInDisk:pfuser];
                    } else {
                        [self saveBmobUserInMemory:pfuser];
                    }
                }
            }
            if (completion) {
                completion(YES, nil);
            }
        } else {
            if (completion) {
                completion(NO, error);
            }
        }
    }];
}

- (UserProfileEntity*)getUserProfileByUsername:(NSString*)username
{
    if ([_users objectForKey:username]) {
        return [_users objectForKey:username];
    }
    
    return nil;
}

- (UserProfileEntity*)getCurUserProfile
{
    if ([_users objectForKey:kCURRENT_USERNAME]) {
        return [_users objectForKey:kCURRENT_USERNAME];
    }
    
    return nil;
}

- (NSString*)getNickNameWithUsername:(NSString*)username
{
    UserProfileEntity* entity = [self getUserProfileByUsername:username];
    if (entity.nickname && entity.nickname.length > 0) {
        NSLog(@"%@返回nickname=%@",username,entity.nickname);
        return entity.nickname;
    } else {
        NSLog(@"%@返回username",username);
        return username;
    }
}

#pragma mark - private

//- (void)savePFUserInDisk:(PFObject*)object
//{
//    if (object) {
//        [object pinInBackgroundWithName:kCURRENT_USERNAME];
//        [self savePFUserInMemory:object];
//    }
//}

- (void)saveBmobUserInDisk:(BmobObject*)object
{
    if (object) {
        //[object]
        //[object pinInBackgroundWithName:kCURRENT_USERNAME];
        [self saveBmobUserInMemory:object];
    }
}

- (void)saveBmobUserInMemory:(BmobObject*)object
{
    if (object) {
        UserProfileEntity *entity = [UserProfileEntity initWithBmobObject:object];
        [_users setObject:entity forKey:entity.username];
        
        if([entity.username isEqualToString:kCURRENT_USERNAME])
        {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setObject:object.objectId forKey:[NSString stringWithFormat:@"%@%@",kPARSE_HXUSER,kCURRENT_USERNAME]];
            [ud synchronize];
        }
    }
}

- (void)queryBmobObjectWithCompletion:(void (^)(BmobObject *object, NSError *error))completion
{
    BmobQuery * query=[BmobQuery queryWithClassName:kPARSE_HXUSER];
    [query whereKey:kPARSE_HXUSER_USERNAME equalTo:kCURRENT_USERNAME];
    __weak typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            if (objects && [objects count] > 0) {
                BmobObject *object = [objects objectAtIndex:0];
                [object setACL:weakSelf.defaultACL];
                weakSelf.objectId = object.objectId;
                //NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                //[ud setObject:object.objectId forKey:[NSString stringWithFormat:@"%@%@",kPARSE_HXUSER,kCURRENT_USERNAME]];
                //[ud synchronize];
                if (completion) {
                    completion (object, error);
                }
            } else {
                BmobObject *object = [BmobObject objectWithClassName:kPARSE_HXUSER];
                [object setObject:kCURRENT_USERNAME forKey:kPARSE_HXUSER_USERNAME];
                completion (object, error);
            }
        } else {
            if (completion) {
                completion (nil, error);
            }
        }
    }];
}

@end

@implementation UserProfileEntity

+ (instancetype) initWithBmobObject:(BmobObject *)object
{
    UserProfileEntity *entity = [[UserProfileEntity alloc] init];
    entity.username=[object objectForKey:kPARSE_HXUSER_USERNAME];
    entity.nickname=[object objectForKey:kPARSE_HXUSER_NICKNAME];
    entity.password=[object objectForKey:kPARSE_HXUSER_PASSWORD];
    
    BmobFile * userImageFile=[object objectForKey:kPARSE_HXUSER_AVATAR];
    if (userImageFile) {
        entity.imageUrl = userImageFile.url;
    }
    return entity;
}

@end
