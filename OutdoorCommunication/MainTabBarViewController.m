//
//  QRJMainTabBarViewController.m
//  NewIT
//
//  Created by Alfa on 16/7/27.
//  Copyright © 2016年 alfa. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "EaseUI.h"
#import "MainNavigationVC.h"
#import "ConversationListVC.h"
#import "UserListViewController.h"
#import "MainMapViewController.h"

@interface MainTabBarViewController ()<UIAlertViewDelegate>
{
    //会话列表
    ConversationListVC * chatListVC;
    //联系人列表
    UserListViewController *listViewController;
    //发现
    MainNavigationVC * discoverVC;
    //地图
    MainMapViewController * mapView;
    //个人中心
    MainNavigationVC * profile;
    
}
@property (strong, nonatomic) NSDate *lastPlaySoundDate;

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 设置tabbar
 */
-(void)setupSubviews
{
    //回话列表
    chatListVC=[[ConversationListVC alloc]init];
    chatListVC.title=@"最近";
    MainNavigationVC * nvaChat=[[MainNavigationVC alloc]initWithRootViewController:chatListVC];
    [self addOneSubViewController:nvaChat title:@"最近" imageName:@"tabbar_mainframe" selectedImageName:@"tabbar_mainframeHL"];
    
    //联系人列表
    listViewController = [[UserListViewController alloc] init];
    listViewController.title=@"联系人";
    MainNavigationVC * nvaList=[[MainNavigationVC alloc]initWithRootViewController:listViewController];
    [self addOneSubViewController:nvaList title:@"联系人" imageName:@"tabbar_contacts" selectedImageName:@"tabbar_contactsHL"];
    
    
    //发现
    discoverVC=[UIStoryboard storyboardWithName:@"Discover" bundle:[NSBundle mainBundle]].instantiateInitialViewController;
    [self addOneSubViewController:discoverVC title:@"发现" imageName:@"发现" selectedImageName:nil];
    
    //地图
    mapView=[[MainMapViewController alloc]init];
    mapView.title=@"地图";
    MainNavigationVC * navMap=[[MainNavigationVC alloc]initWithRootViewController:mapView];
    [self addOneSubViewController:navMap title:@"地图" imageName:@"地图" selectedImageName:nil];
    
    //设置列表
    profile=[UIStoryboard storyboardWithName:@"Profile" bundle:[NSBundle mainBundle]].instantiateInitialViewController;
    [self addOneSubViewController:profile title:@"个人中心" imageName:@"tabbar_discover" selectedImageName:@"tabbar_discoverHL"];
}

/**
 将一个控制器加入到Tabbar中

 @param subViewController 控制器
 @param title 控制器标题
 @param imageName 正常状态下的图片
 @param selectedImageName 选中状态下的图片
 */
-(void)addOneSubViewController:(UIViewController*)subViewController title:(NSString*)title imageName:(NSString*)imageName selectedImageName:(NSString*)selectedImageName{
    
    subViewController.tabBarItem.title=title;
    subViewController.tabBarItem.image=[UIImage imageNamed:imageName];
    
    UIImage*selectedImage=[UIImage imageNamed:selectedImageName];
    
    subViewController.tabBarItem.selectedImage=selectedImage;
    
    [self addChildViewController:subViewController];
    
    
    
}


   
@end
