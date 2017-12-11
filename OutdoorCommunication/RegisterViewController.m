//
//  RegisterViewController.m
//  OutdoorChat
//
//  Created by 朱贺 on 2016/11/28.
//  Copyright © 2016年 朱贺. All rights reserved.
//

#import "RegisterViewController.h"
#import "EMAlertView.h"
#import "MBProgressHUD.h"
#import "TTGlobalUICommon.h"
#import "UserProfileManager.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmTextField;

@end

@implementation RegisterViewController




- (void)viewDidLoad {
    [super viewDidLoad];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    // Do any additional setup after loading the view.
}

- (void)keyboardHide:(id)sender{
    
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//注册事件
- (IBAction)registerButtonDidClicked:(id)sender {
    //判断信息是否输入完整
    if([self isEmpty])
    {
        return;
    }
    
    //隐藏键盘
    [self.view endEditing:YES];
    
    //判断是否是中文，但不支持中英文混编
    if ([self.userNameTextField.text isChinese]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"请不要输入中文", @"Name does not support Chinese")
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    //显示注册进度
    [self showHudInView:self.view hint:NSLocalizedString(@"请稍后", @"注册中...")];
    __weak typeof(self) weakself = self;
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [[EMClient sharedClient] registerWithUsername:weakself.userNameTextField.text password:weakself.passwordTextField.text];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself hideHud];
            if (!error) {
                
                //向bmob中插入密码
                UserProfileManager * userProfileManager=[UserProfileManager sharedInstance];
                [userProfileManager registerWithPassword:_userNameTextField.text password:_passwordTextField.text completion:^(BOOL success, NSError *error) {
                    if(success)
                    {
                        TTAlertNoTitle(NSLocalizedString(@"注册成功", @"请登录"));

                    }
                    else
                    {
                        TTAlertNoTitle(NSLocalizedString(@"注册失败", @"请重试"));
                        NSLog(@"注册bmob写入失败 %@",error);
                    }
                }];
                
                
                
            }else{
                switch (error.code) {
                    case EMErrorServerNotReachable:
                        TTAlertNoTitle(NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!"));
                        break;
                    case EMErrorUserAlreadyExist:
                        TTAlertNoTitle(NSLocalizedString(@"register.repeat", @"You registered user already exists!"));
                        break;
                    case EMErrorNetworkUnavailable:
                        TTAlertNoTitle(NSLocalizedString(@"error.connectNetworkFail", @"No network connection!"));
                        break;
                    case EMErrorServerTimeout:
                        TTAlertNoTitle(NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!"));
                        break;
                    case EMErrorServerServingForbidden:
                        TTAlertNoTitle(NSLocalizedString(@"servingIsBanned", @"Serving is banned"));
                        break;
                    default:
                        TTAlertNoTitle(NSLocalizedString(@"register.fail", @"Registration failed"));
                        break;
                }
            }
        });
    });

  
}

//返回
- (IBAction)dismissButtonDidClicked:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}



//判断账号和密码是否为空
- (BOOL)isEmpty{
    BOOL ret = NO;
    NSString *username = _userNameTextField.text;
    NSString *password = _passwordTextField.text;
    if (username.length == 0 || password.length == 0) {
        ret = YES;
        [EMAlertView showAlertWithTitle:NSLocalizedString(@"警告", @"Prompt")
                                message:NSLocalizedString(@"请填写完整", @"Please enter username and password")
                        completionBlock:nil
                      cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                      otherButtonTitles:nil];
    }
    
    return ret;
}

#pragma  mark - TextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == _userNameTextField) {
        _passwordTextField.text = @"";
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _userNameTextField) {
        [_userNameTextField resignFirstResponder];
        [_passwordTextField becomeFirstResponder];
    } else if (textField == _passwordTextField) {
        [_passwordTextField resignFirstResponder];
        [self registerButtonDidClicked:nil];
    }
    return YES;
}

@end
