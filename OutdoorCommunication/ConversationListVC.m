//
//  ConversationListVC.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/1/11.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "ConversationListVC.h"
#import "UserProfileManager.h"

@interface ConversationListVC ()
@property (nonatomic, strong) UIView *networkStateView;

@end

@implementation ConversationListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showRefreshHeader=YES;

    
    [self networkStateView];
    [self tableViewDidTriggerHeaderRefresh];

}

-(void)refreshDataSource
{
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self tableViewDidTriggerHeaderRefresh];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
