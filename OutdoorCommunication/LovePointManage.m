//
//  LovePointManage.m
//  OutdoorCommunication
//
//  Created by 朱贺 on 2017/5/8.
//  Copyright © 2017年 朱贺. All rights reserved.
//

#import "LovePointManage.h"
#define kCURRENT_USERNAME [[EMClient sharedClient] currentUsername]

@implementation UIImage (UIImageExt)

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

@end


static LovePointManage *sharedInstance = nil;



@implementation LovePointManage


+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _defaultACL=[BmobACL ACL];
        //设置所有人读权限为true
        [_defaultACL setPublicReadAccess];
        //设置所有人写权限为true
        [_defaultACL setPublicWriteAccess];
    }
    return self;
}

/*
 *  上传图片
 */
- (void)uploadImageInBackground:(UIImage*)image 
                       location:(NSString * )location
                    description:(NSString *)description
                     completion:(void (^)(BOOL success, NSError *error))completion
{
    
    BmobObject *object = [[BmobObject alloc] initWithClassName:bmob_LOVE_POINT];
    
    UIImage *img = [image imageByScalingAndCroppingForSize:CGSizeMake(800.f, 800.f)];
    
    NSData *imageData = UIImageJPEGRepresentation(img, 0.5);
    BmobFile * imageFile = [[BmobFile alloc]initWithFileName:@"image.png" withFileData:imageData];
    
    //文件上传
    [imageFile saveInBackground:^(BOOL isSuccessful, NSError *error) {
        if(isSuccessful)
        {
            [object setObject:kCURRENT_USERNAME forKey:bmob_LOVE_POINT_USERNAME];
            [object setObject:imageFile forKey:bmob_LOVE_POINT_IMG];
            [object setObject:location forKey:bmob_LOVE_POINT_LOCATION];
            [object setObject:description forKey:bmob_LOVE_POINT_DESCRIPTION];
            [object saveInBackground];
        }
        completion(isSuccessful,error);
        
    }];
}

/*
 *  获取用户标注点 by userID,时间点
 */
- (void)searchLovePointInBackground:(NSString*)userID
                           starTime:(NSString *)startTime
                            endTime:(NSString *)endTime
                         completion:(void (^)(NSArray * result, NSError *error))completion
{
    //构造条件
    BmobQuery * query=[BmobQuery queryWithClassName:bmob_LOVE_POINT];
    //[query whereKey:bmob_LOVE_POINT_USERNAME equalTo:userID];
    
    //createdAt大于或等于 2014-07-15 00:00:00
    NSDictionary *condiction1 = @{@"createdAt":@{@"$gte":@{@"__type": @"Date", @"iso": startTime}}};
    //createdAt小于 2014-10-15 00:00:00
    NSDictionary *condiction2 = @{@"createdAt":@{@"$lte":@{@"__type": @"Date", @"iso": endTime}}};
    NSArray *condictonArray = @[condiction1,condiction2];
    //作用就是查询创建时间在2014年7月15日到2014年10月15日之间的数据
    [query addTheConstraintByAndOperationWithArray:condictonArray];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        //返回结果
        completion(array,error);
    }];
}



@end
