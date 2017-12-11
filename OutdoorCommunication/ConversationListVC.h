//
//  ConversationListVC.h
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/1/11.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "EaseConversationListViewController.h"

@interface ConversationListVC : EaseConversationListViewController
@property (strong, nonatomic) NSMutableArray *conversationsArray;

-(void)refreshDataSource;
@end
