//
//  LoginViewController.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/1/9.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "LoginViewController.h"
#import "EMAlertView.h"
#import "MBProgressHUD.h"
#import "TTGlobalUICommon.h"
#import "UserPwdManage.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

//点击空白处收回键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//登录按钮
- (IBAction)doLogin:(id)sender {
    //登录信息不完整
    if([self isEmpty])
    {
        return;
    }
    
    [self.view endEditing:YES];
    //支持是否为中文
    if ([self.usernameTextField.text isChinese]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"警告", @"请不要输入中文")
                              message:nil
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                              otherButtonTitles:nil];
        
        [alert show];
        
        return;
    }

      [self loginWithUsername:_usernameTextField.text password:_passwordTextField.text];
    
}


//点击登陆后的操作
- (void)loginWithUsername:(NSString *)username password:(NSString *)password
{
    
    //显示登录进度
    [self showHudInView:self.view hint:NSLocalizedString(@"请稍候", @"登录中...")];

    
    NSLog(@"点击了登录");
    //异步登陆账号
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [[EMClient sharedClient] loginWithUsername:username password:password];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself hideHud];
            if (!error) {
                //设置是否自动登录
                [[EMClient sharedClient].options setIsAutoLogin:YES];
                
                //获取数据库中数据
                //[MBProgressHUD showHUDAddedTo:weakself.view animated:YES];
                [self.navigationController popoverPresentationController];
                //发送自动登陆状态通知
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@([[EMClient sharedClient] isLoggedIn])];
                
                //存储密码
                if([[EMClient sharedClient]isLoggedIn])
                {
                    UserPwdManage * pwdManage=[[UserPwdManage alloc]init];
                    [pwdManage saveUserPwd:_passwordTextField.text];
                }
                
                
            } else
                   {
                switch (error.code)
                {
                        //                    case EMErrorNotFound:
                        //                        TTAlertNoTitle(error.errorDescription);
                        //                        break;
                    case EMErrorNetworkUnavailable:
                        TTAlertNoTitle(@"网络连接失败");
                        break;
                    case EMErrorServerNotReachable:
                        TTAlertNoTitle(@"无法连接服务器");
                        break;
                    case EMErrorUserAuthenticationFailed:
                        //密码不正确
                        TTAlertNoTitle(@"用户名或者密码不正确");
                        break;
                    case EMErrorServerTimeout:
                        TTAlertNoTitle(@"连接超时");
                        break;
                    case EMErrorServerServingForbidden:
                        TTAlertNoTitle(NSLocalizedString(@"servingIsBanned", @"Serving is banned"));
                        break;
                    default:
                        TTAlertNoTitle(NSLocalizedString(@"login.fail", @"Login failure"));
                        break;
                }
            }
        });
    
    });
}

//弹出提示的代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView cancelButtonIndex] != buttonIndex) {
        //获取文本输入框
        UITextField *nameTextField = [alertView textFieldAtIndex:0];
        if(nameTextField.text.length > 0)
        {
            //设置推送设置
            [[EMClient sharedClient] setApnsNickname:nameTextField.text];
        }
    }
    //登陆
    [self loginWithUsername:_usernameTextField.text password:_passwordTextField.text];
}



//判断账号和密码是否为空
- (BOOL)isEmpty{
    BOOL ret = NO;
    NSString *username = _usernameTextField.text;
    NSString *password = _passwordTextField.text;
    if (username.length == 0 || password.length == 0) {
        ret = YES;
        [EMAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                message:NSLocalizedString(@"login.inputNameAndPswd", @"Please enter username and password")
                        completionBlock:nil
                      cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                      otherButtonTitles:nil];
    }
    
    return ret;
}


#pragma  mark - TextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == _usernameTextField) {
        _passwordTextField.text = @"";
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _usernameTextField) {
        [_usernameTextField resignFirstResponder];
        [_passwordTextField becomeFirstResponder];
    } else if (textField == _passwordTextField) {
        [_passwordTextField resignFirstResponder];
        [self doLogin:nil];
    }
    return YES;
}
@end
