//
//  ChangePwdViewController.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/26.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "ChangePwdViewController.h"
#import "UserPwdManage.h"
#import "MyLocationService.h"

@interface ChangePwdViewController ()
@property (weak, nonatomic) IBOutlet UITextField *orignalPwdTextField;

@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;

@property (weak, nonatomic) IBOutlet UITextField *pwdConfirmTextField;


// 用于网络请求的Session对象
@property (nonatomic, strong) AFHTTPSessionManager *session;
@end

@implementation ChangePwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 初始化Session对象
    self.session = [AFHTTPSessionManager manager];
    // 设置请求接口回来的时候支持什么类型的数据
    self.session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"application/x-json",@"text/html", nil];
    
    
    self.session.requestSerializer = [AFJSONRequestSerializer new];
    self.session.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    self.session.responseSerializer = [AFHTTPResponseSerializer serializer];//响应

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//点击空白处收回键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}



//修改密码
- (IBAction)changePwdAction:(id)sender {
    //判断是否为空
    if([_orignalPwdTextField.text isEqualToString:@""] ||
       [_pwdTextField.text isEqualToString:@""]||
       [_pwdConfirmTextField.text isEqualToString:@""])
    {
        [EMAlertView showAlertWithTitle:@"提示" message:@"请输入完整信息" completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
            
        } cancelButtonTitle:@"确定" otherButtonTitles:nil];
        return;
    }
    
    //判断密码一致
    if(![_pwdTextField.text isEqualToString:_pwdConfirmTextField.text])
    {
        [EMAlertView showAlertWithTitle:@"提示" message:@"新密码不一致" completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
            
        } cancelButtonTitle:@"确定" otherButtonTitles:nil];
        return;
    }
    
    //判断原始密码
    UserPwdManage * userPwdManage=[[UserPwdManage alloc]init];
    
    NSString * pwd=[userPwdManage getUserPwd];
    
    if([pwd isEqualToString:_orignalPwdTextField.text])
    {
        [self showHudInView:self.view hint:@"修改中"];
        
        //验证成功,修改密码
        
        NSString * url=[NSString stringWithFormat:@"https://a1.easemob.com/1182161114115254/outdoorchat/users/%@/password",[[EMClient sharedClient] currentUsername]];
        

        [self.session.requestSerializer setValue:@"Bearer YWMtHPtcnEH2EeeJr8VKJdCk7gAAAAAAAAAAAAAAAAAAAAGa0vEQqisR5oyWjUyiWGuOAgMAAAFcRBjRkABPGgCvZ7UAEO6L_eQp0T1UTat32V2WDUMM1-xQgbyVfyrf3g"forHTTPHeaderField:@"Authorization"];

        NSDictionary * para=[NSDictionary dictionaryWithObject:_pwdTextField.text forKey:@"newpassword"];
        
        [self.session PUT:url parameters:para success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //NSLog(@"成功 %@",responseObject);
            //修改成功
            [self hideHud];
            //注销登录
            [EMAlertView showAlertWithTitle:@"提示" message:@"密码修改成功，请重新登录" completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
                [self doLogOut];
            } cancelButtonTitle:@"确定" otherButtonTitles:nil];
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"失败 %@",error);
            //修改失败
            [self hideHud];
        }];
    }
    else
    {
        //密码验证失败
        [EMAlertView showAlertWithTitle:@"提示" message:@"原始密码验证失败" completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
            
        } cancelButtonTitle:@"确定" otherButtonTitles:nil];
    }
    
}

//退出登录
-(void)doLogOut
{
    __weak ChangePwdViewController *weakSelf = self;
    
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

@end
