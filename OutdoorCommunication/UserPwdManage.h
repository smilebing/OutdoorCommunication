//
//  UserPwdManage.h
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/26.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserPwdManage : NSObject
//获取密码
-(NSString *)getUserPwd;

//存储密码
-(void)saveUserPwd:(NSString *)pwd;

//清除密码
-(void)clearUserPwd;
@end
