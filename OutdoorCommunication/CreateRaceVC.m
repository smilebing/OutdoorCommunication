//
//  CreateRaceVC.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/2/17.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "CreateRaceVC.h"
#import "RaceManager.h"
#import "EMAlertView.h"

#import "AddCheckPointVC.h"

@interface CreateRaceVC ()

@end

@implementation CreateRaceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //设置textView边框
    _raceDetailTextView.layer.borderWidth=1;
    
    //添加右上角bar item
    UIBarButtonItem *createRaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createRaceAction)];
    self.navigationItem.rightBarButtonItem=createRaceItem;

}


/*
 *创建比赛
 */
-(void)createRaceAction
{
    if(_raceNameTextField.text.length==0||_raceLocTextField.text.length==0||
       _raceDetailTextView.text.length==0)
    {
        [EMAlertView showAlertWithTitle:@"警告" message:@"请输入完整信息" completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
            
        } cancelButtonTitle:@"确定" otherButtonTitles:nil];
        return;
    }
    
    //显示进度
    [self hideHud];
    [self showHudInView:self.view hint:@"创建中..."];
    
    NSString * currentUserName=[EMClient sharedClient].currentUsername;
    
    [[RaceManager sharedInstance]creatRace:_raceNameTextField.text location:_raceDetailTextView.text details:_raceLocTextField.text creater: currentUserName completion:^(BOOL success, NSError *error,NSString * objectId) {
        
        //关闭进度
        [self hideHud];
        
        if(success)
        {
            //创建成功
            [EMAlertView showAlertWithTitle:@"信息" message:@"比赛创建成功,请添加检查点" completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
                NSLog(@"success comp");

                //添加检查点
                //显示地图页面，添加若干个检查点
                AddCheckPointVC * addCheckPointVC=[[AddCheckPointVC alloc]initWithObjectID:objectId];
                [self.navigationController pushViewController:addCheckPointVC animated:YES];
                //[self presentViewController:addCheckPointVC animated:YES completion:nil];
                
            } cancelButtonTitle:@"确定" otherButtonTitles:nil];
        }
        else
        {
            //创建失败
            [EMAlertView showAlertWithTitle:@"信息" message:@"比赛创建失败" completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
                NSLog(@"fail comp");

            } cancelButtonTitle:@"确定" otherButtonTitles:nil];
        }
    }];
    
}

- (void)dealloc
{
    NSLog(@"CreateRaceVC dealloc");
}

@end
