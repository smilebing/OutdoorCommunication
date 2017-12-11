//
//  ChatHelper.h
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/8.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConversationListVC.h"
#import "UserListViewController.h"
#import "MainNavigationVC.h"
#import "MainMapViewController.h"



@interface ChatHelper : NSObject <EMClientDelegate,EMChatManagerDelegate,EMContactManagerDelegate,EMGroupManagerDelegate,EMChatroomManagerDelegate>

//会话列表
@property(nonatomic,weak) ConversationListVC * conversationListVC;
//联系人列表
@property(nonatomic,weak) UserListViewController *contactViewVC;
//发现
@property(nonatomic,weak) MainNavigationVC * discoverVC;
//地图
@property(nonatomic,weak) MainMapViewController * mapView;
//个人中心
@property(nonatomic,weak) MainNavigationVC * profile;
+ (instancetype)shareHelper;

- (void)asyncPushOptions;

- (void)asyncGroupFromServer;

- (void)asyncConversationFromDB;

@end
