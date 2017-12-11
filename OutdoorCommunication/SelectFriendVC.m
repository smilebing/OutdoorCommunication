//
//  SelectFriendVC.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/2/1.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "SelectFriendVC.h"

@interface SelectFriendVC ()<EMUserListViewControllerDataSource>

@end

@implementation SelectFriendVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //添加右上角bar item
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(shareDest)];
    
    UIBarButtonItem *selectAllItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAll)];
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:shareItem, selectAllItem,nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//选中某一栏
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellTableIdentifier=@"CellTableIdentifier";

    UITableViewCell * cell= [tableView  cellForRowAtIndexPath:indexPath];
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellTableIdentifier];
    }
    if(cell.accessoryType!=UITableViewCellAccessoryCheckmark)
    {
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType=UITableViewCellAccessoryNone;
    }
  
}



//将目的地信息发送给好友
-(void)shareDest
{
    NSInteger  count=[self numberOfSectionsInTableView:self.tableView];
    Boolean flag=NO;
    for(int i=0;i<count;i++)
    {
        NSIndexPath * indexpath=[NSIndexPath indexPathForRow:i inSection:1];
        UITableViewCell * cell=[self.tableView cellForRowAtIndexPath:indexpath];
        if(cell.accessoryType==UITableViewCellAccessoryCheckmark)
        {
        //获取好友名称，发送
         EaseUserModel *model =[self.dataArray objectAtIndex:i];
         NSLog(@"%@",model.buddy);
            
        //构造消息类型
        //构造位置消息
        EMLocationMessageBody *body = [[EMLocationMessageBody alloc] initWithLatitude:39 longitude:116 address:@"地址"];
        NSString *from = [[EMClient sharedClient] currentUsername];
        
            
            
        // 生成message
        NSDictionary * ext=[NSDictionary dictionaryWithObjectsAndKeys:@"title",@"this is title",@"detail",@"this is deatil", nil];
            
            
        EMMessage *message = [[EMMessage alloc] initWithConversationID:from from:from to:model.buddy body:body ext:ext];
            
        message.chatType = EMChatTypeChat;// 设置为单聊消息
            //message.chatType = EMChatTypeGroupChat;// 设置为群聊消息
            //message.chatType = EMChatTypeChatRoom;// 设置为聊天室消息

        //异步发送信息
              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
                if(error==nil)
                {
                    NSLog(@"%@分享成功",model.buddy);
                }
            }];
            });
            
            
            flag=YES;
        }
        
    }
    //判断是否选中好友
    if(flag==NO)
    {
        //提示没有选择好友
        [self  showHint:@"请选择好友"];
    }
}


//全选好友
-(void)selectAll
{
    NSInteger  count=[self numberOfSectionsInTableView:self.tableView];
    for(int i=0;i<count;i++)
    {
        NSIndexPath * indexpath=[NSIndexPath indexPathForRow:i inSection:1];

        [self tableView:self.tableView didSelectRowAtIndexPath:indexpath];
    }
    
}


@end
