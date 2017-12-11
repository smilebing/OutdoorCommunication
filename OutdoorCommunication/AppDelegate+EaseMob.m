
#import "AppDelegate+EaseMob.h"
#import "MainNavigationVC.h"
#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "EaseUI.h"
#import "TTGlobalUICommon.h"

#import "ChatHelper.h"
#import "MyLocationService.h"
#import "UserProfileManager.h"
/**
 *  本类中做了EaseMob初始化和推送等操作
 */

@implementation AppDelegate (EaseMob)

- (void)easemobApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
                    appkey:(NSString *)appkey
              apnsCertName:(NSString *)apnsCertName
               otherConfig:(NSDictionary *)otherConfig
{
    //注册登录状态监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStateChange:)
                                                 name:KNOTIFICATION_LOGINCHANGE
                                               object:nil];
    
    //AppKey:注册的AppKey，详细见下面注释。
    //apnsCertName:推送证书名（不需要加后缀），详细见下面注释。
    EMOptions *options = [EMOptions optionsWithAppkey:appkey];
    //options.apnsCertName = appkey;
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    
    
    
    
    BOOL isAutoLogin = [EMClient sharedClient].isAutoLogin;
    if (isAutoLogin){
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
    }
    
    [ChatHelper shareHelper];
    [[ChatHelper shareHelper] asyncGroupFromServer];
    [[ChatHelper shareHelper] asyncConversationFromDB];
    [[ChatHelper shareHelper] asyncPushOptions];
}

- (void)easemobApplication:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[EaseSDKHelper shareHelper] hyphenateApplication:application didReceiveRemoteNotification:userInfo];
}

#pragma mark - App Delegate

// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EMClient sharedClient] bindDeviceToken:deviceToken];
    });
}

// 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.failToRegisterApns", Fail to register apns)
                                                    message:error.description
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - login changed

- (void)loginStateChange:(NSNotification *)notification
{
    NSLog(@"收到登录状态改变通知");
    
    BOOL loginSuccess = [notification.object boolValue];
    if (loginSuccess) {
        //登陆成功加载主窗口控制器
        self.window.rootViewController=[[MainTabBarViewController alloc]init];
        NSLog(@"登陆成功加载主窗口控制器");
        
        //开始上传位置信息
        MyLocationService * locService=[MyLocationService sharedInstance];
        [locService initParameter];
        [locService starUploadLocService];
    }
    else{
        //登陆失败加载登陆页面控制器
        NSLog(@"登录状态为失败");
        
        UserProfileManager * userManage=[UserProfileManager sharedInstance];
        [userManage clearBmob];
        
        self.window.rootViewController=[UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]].instantiateInitialViewController;
      
        //停止上传位置信息
        //MyLocationService * locService=[MyLocationService sharedInstance];
        //[locService initParameter];
        //[locService stopUploadLocService];
    }
    
   }

#pragma mark - EMPushManagerDelegateDevice

// 打印收到的apns信息
-(void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo
                                                        options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *str =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.content", @"Apns content")
                                                    message:str
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
    
}




@end
