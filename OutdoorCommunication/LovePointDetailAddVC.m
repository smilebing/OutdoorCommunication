//
//  LovePointDetailAddVC.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/8.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "LovePointDetailAddVC.h"
#import "UIImage+WaterMark.h"
#import "LovePointManage.h"

@interface LovePointDetailAddVC ()<UIActionSheetDelegate,UIImagePickerControllerDelegate>
{
    CLLocationCoordinate2D location;
    UIImage * finalImg;
}
@property(nonatomic)NSInteger witchBtn;
@property(nonatomic)NSInteger btn1;

@end

@implementation LovePointDetailAddVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //添加右上角bar item
    _saveBtn= [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveDetails)];
    self.navigationItem.rightBarButtonItem=_saveBtn;
    
    
    _detailTextView.layer.borderColor=UIColor.grayColor.CGColor;
    _detailTextView.layer.borderWidth = 1;
    _detailTextView.layer.cornerRadius = 6;
    _detailTextView.layer.masksToBounds = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setLocation:(CLLocationCoordinate2D) loc
{
    location=loc;
}

//点击空白处收回键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)imgBtn1Click:(id)sender {
    _witchBtn=1;
    [self showSelectImg];
}



-(void)showSelectImg
{
    //更换头像
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"照相" otherButtonTitles:@"相册", nil];
    [sheet showInView:self.view];
}


//保存
-(void)saveDetails
{
    
    if(_btn1==1)
    {
        [self showHudInView:self.view hint:@"保存中"];
        
        NSNumber *longitude=[NSNumber numberWithDouble: location.longitude ];
        NSNumber * latitude=[NSNumber numberWithDouble: location.latitude ];
        NSDictionary * loc=@{@"longitude":longitude,
                             @"latitude":latitude};
        
        NSString * locStr= [loc JSONString];
        NSString * description=@"喜欢";
        if(![_detailTextView.text isEqualToString:@""])
        {
            description=_detailTextView.text;
        }
        
        LovePointManage * manage=[LovePointManage sharedInstance];
        [manage uploadImageInBackground:finalImg
                               location:locStr
                            description:description
                             completion:^(BOOL success, NSError *error)
         {
             if(success)
             {
                 [self hideHud];
                 [EMAlertView showAlertWithTitle:@"提示" message:@"上传成功" completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView)
                  {
                      [self.navigationController popViewControllerAnimated:YES];
                  }
                               cancelButtonTitle:@"确定" otherButtonTitles:nil];
             }
             else
             {
                 [self hideHud];
                 [self showError];
             }
         }];
        
    }
    else
    {
        //提示添加图片
        [EMAlertView showAlertWithTitle:@"提示" message:@"请选择图片" completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
            
        } cancelButtonTitle:@"确定" otherButtonTitles:nil];
    }
    
}

-(void)showError
{
    [EMAlertView showAlertWithTitle:@"提示" message:@"保存失败，稍后重试" completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
        
    } cancelButtonTitle:@"确定" otherButtonTitles:nil];
}

#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 2){//取消
        return;
    }
    
    if([_detailTextView.text isEqualToString:@""])
    {
        //必须先输入文本
        [EMAlertView showAlertWithTitle:@"提示" message:@"请先输入内容" completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
            return;
        } cancelButtonTitle:@"确定" otherButtonTitles:nil];
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
    _btn1=1;
    //合成图片
    UIImage * waterImage= [image imageWaterMarkWithString:_detailTextView.text point:CGPointMake(0, 20) attribute:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    finalImg=waterImage;
    [_imgButton1 setImage:waterImage forState:UIControlStateNormal];
    
}

@end
