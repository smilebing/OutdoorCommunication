//
//  ProfileTableVC.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/1/13.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "ProfileTableVC.h"
#import "UserProfileManager.h"
#import "UIImageView+HeadImage.h"
#import "MyRouteTableViewController.h"
#import "MyLocationService.h"
#import "UserPwdManage.h"
#import "ChangePwdViewController.h"
#import "MyShareRouteTableViewController.h"

@interface ProfileTableVC ()<UITableViewDataSource,UITableViewDelegate>
{
    //UITableView *personalTableView;
    NSArray *dataSource;
    NSString * userID;

}
@property (strong, nonatomic) UIImageView * headImageView;
@property (strong, nonatomic) UILabel * usernameLabel;

@property (strong,nonatomic)ChangePwdViewController * changePwdVC;

@end

@implementation ProfileTableVC

-(void)viewWillAppear:(BOOL)animated
{
    [self loadUserProfile];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    userID= [EMClient sharedClient].currentUsername;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    //self.tableView.allowsSelection = NO;

    [self loadUserProfile];
}



- (UIImageView*)headImageView
{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.frame = CGRectMake(20, 10, 60, 60);
        _headImageView.contentMode = UIViewContentModeScaleToFill;
    }
    [_headImageView imageWithUsername:userID placeholderImage:nil];
    return _headImageView;
}

- (UILabel*)usernameLabel
{
    if (!_usernameLabel) {
        _usernameLabel = [[UILabel alloc] init];
        _usernameLabel.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame) + 10.f, 10, 200, 20);
        _usernameLabel.text = userID;
        _usernameLabel.textColor = [UIColor lightGrayColor];
    }
    return _usernameLabel;
}


//退出登录
-(void)doLogOut
{
    __weak ProfileTableVC *weakSelf = self;
    
    //显示进度
    [self showHudInView:self.view hint:@"注销中..."];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [[EMClient sharedClient] logout:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHud];
            if (error != nil) {
                [weakSelf showHint:error.errorDescription];
            }
            else{
                //[[ApplyViewController shareController] clear];
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
                
                //清除密码
                UserPwdManage * pwdManage=[[UserPwdManage alloc]init];
                [pwdManage clearUserPwd];
                
                
                MyLocationService * locService=[MyLocationService sharedInstance];
                [locService initParameter];
                [locService stopUploadLocService];
            }
        });
    });
}



#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
    {
        return 5;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    if(indexPath.section==0)
    {
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = @"头像";
            [cell.contentView addSubview:self.headImageView];
            
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"用户id";
            cell.detailTextLabel.text = self.usernameLabel.text;
            
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"昵称";
            UserProfileEntity *entity = [[UserProfileManager sharedInstance] getUserProfileByUsername:userID];
            if (entity && entity.nickname.length>0) {
                cell.detailTextLabel.text = entity.nickname;
            } else {
                cell.detailTextLabel.text = userID;
            }
            
        } else if(indexPath.row==3){
            cell.textLabel.text=@"我的路书";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if(indexPath.row==4)
        {
            cell.textLabel.text=@"我分享的路书";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else
    {
        
        if(indexPath.row==0)
        {
           //编辑个人信息
            cell.textLabel.text=@"修改密码";
        }
        else
        {
            //退出
            cell.textLabel.textAlignment=NSTextAlignmentCenter;
            //cell.backgroundColor=[UIColor redColor];
            cell.textLabel.text=@"退出";
        }
       
    }
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 &&indexPath.section==0) {
        return 80;
    }
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        if(indexPath.row==3)
        {
            //显示我的轨迹
            MyRouteTableViewController * myRoute=[[MyRouteTableViewController alloc]init];
            myRoute.title=@"我的路书";
            myRoute.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:myRoute animated:YES];
        }
        else if(indexPath.row==4)
        {
            MyShareRouteTableViewController * shareRouteVC=[[MyShareRouteTableViewController alloc]init];
            shareRouteVC.title=@"我的分享";
            shareRouteVC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:shareRouteVC animated:YES];
        }
      
    }
    else
    //编辑栏
    if(indexPath.section==1)
    {
        if(indexPath.row==0)
        {
            //修改密码
            NSLog(@"修改密码");
            _changePwdVC=[UIStoryboard storyboardWithName:@"ChangePwd" bundle:[NSBundle mainBundle]].instantiateInitialViewController;
            
            _changePwdVC.title=@"修改密码";
            
            [self.navigationController pushViewController:_changePwdVC animated:YES];

            
        }
        else
        {
            //退出登录
            NSLog(@"退出登录");
            [self doLogOut];
            
        }
    }
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0;
}


//加载用户数据
- (void)loadUserProfile
{
    [self hideHud];
    [self showHudInView:self.view hint:NSLocalizedString(@"loadData", @"Load data...")];
    __weak typeof(self) weakself = self;
    [[UserProfileManager sharedInstance] loadUserProfileInBackground:@[userID] saveToLoacal:YES completion:^(BOOL success, NSError *error) {
        [weakself hideHud];
        if (success) {
            [weakself.tableView reloadData];
        }
    }];
}



@end
