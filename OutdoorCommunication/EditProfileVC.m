//
//  EditProfileVC.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/2/10.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "EditProfileVC.h"
#import "UserProfileManager.h"
#import "UIImageView+HeadImage.h"
#import "EMAlertView.h"
#import <BmobSDK/Bmob.h>
@interface EditProfileVC ()<UIActionSheetDelegate,UIImagePickerControllerDelegate>
{
    NSString * userID;
    UIImage  *tempImg;
}
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;

@end

@implementation EditProfileVC




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    userID= [EMClient sharedClient].currentUsername;
    [self loadUserProfile];
}

//加载用户数据
- (void)loadUserProfile
{
    [self hideHud];
    [self showHudInView:self.view hint:@"加载中..."];
    __weak typeof(self) weakself = self;
    [[UserProfileManager sharedInstance] loadUserProfileInBackground:@[userID] saveToLoacal:NO completion:^(BOOL success, NSError *error) {
        [weakself hideHud];
        if (success) {
            [self inputProfile];
        }
    }];
}

//填充到界面上
-(void)inputProfile
{
    UserProfileEntity * entity=[[UserProfileManager sharedInstance]getUserProfileByUsername:userID];
        self.nicknameTextField.text=entity.username;
    [_headImageView imageWithUsername:userID placeholderImage:nil];
    _userIDLabel.text = [NSString stringWithFormat:@"用户ID:%@",userID];;
    _nicknameTextField.text=entity.nickname;
    
    tempImg=_headImageView.image;
}

//点击空白处收回键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


//修改昵称信息
- (IBAction)doEdit:(id)sender {
    
    [self hideHud];
    [self showHudInView:self.view hint:@"加载中..."];
    __weak typeof(self) weakself = self;
    
    NSData *imageData = UIImageJPEGRepresentation(_headImageView.image, 0.5);
    BmobFile * imageFile=[[BmobFile alloc]initWithFileName:@"image.png" withFileData:imageData];

    NSDictionary * profile=[[NSDictionary alloc]initWithObjectsAndKeys:userID,kPARSE_HXUSER_USERNAME,_nicknameTextField.text,kPARSE_HXUSER_NICKNAME ,nil];
    [[UserProfileManager sharedInstance]updateUserProfileInBackground:profile completion:^(BOOL success, NSError *error) {
        [weakself hideHud];
        
        if(success)
        {
            [self showHint:@"更新成功"];
        }
        else
        {
            [self showHint:@"更新失败"];
            NSLog(@"更新失败：%@",error);
        }
    }];
}

- (IBAction)changeImg:(id)sender {
    //更换头像
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"照相" otherButtonTitles:@"相册", nil];
    [sheet showInView:self.view];
}


//判断昵称是否为空
- (BOOL)isEmpty{
    BOOL ret = NO;
    NSString *nickname = _nicknameTextField.text;
    if (nickname.length == 0 ) {
        return YES;
    }
    
    return ret;
}

#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 2){//取消
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    // 设置代理
    imagePicker.delegate =self;
    
    // 设置允许编辑
    imagePicker.allowsEditing = YES;
    
    if (buttonIndex == 0) {
        //照相
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else{
        //相册
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    // 显示图片选择器
    [self presentViewController:imagePicker animated:YES completion:nil];
    
    
}

#pragma mark 图片选择器的代理

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    // 获取图片 设置图片
    UIImage *image =(UIImage*) info[UIImagePickerControllerEditedImage];
    
    
    // 隐藏当前模态窗口
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self hideHud];
    [self showHudInView:self.view hint:@"更新中..."];
    __weak typeof(self) weakself = self;

    //更新数据库
    [[UserProfileManager sharedInstance]uploadUserHeadImageProfileInBackground:image completion:^(BOOL success, NSError *error) {
        [weakself hideHud];
        if(success)
        {
            self.headImageView.image=image;
            [self showHint:@"更新头像成功"];
        }
        else
        {
            self.headImageView.image=tempImg;
            [self showHint:@"头像更新失败"];
        }
    }];
}


@end
