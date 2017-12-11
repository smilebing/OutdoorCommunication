/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "SearchMessageViewController.h"

#import "UIImageView+HeadImage.h"
#import "SearchChatViewController.h"

#define SEARCHMESSAGE_PAGE_SIZE 30

@interface SearchMessageViewController () <UISearchBarDelegate, UITextFieldDelegate>
{
    dispatch_queue_t _searchQueue;
    void* _queueTag;
}

@property (strong, nonatomic) EMConversation *conversation;

@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIDatePicker *datePicker;

@property (strong, nonatomic) UILabel *fromLabel;
@property (strong, nonatomic) UITextField *textField;

@property (assign, nonatomic) BOOL hasMore;

@end

@implementation SearchMessageViewController

- (instancetype)initWithConversationId:(NSString *)conversationId
                      conversationType:(EMConversationType)conversationType
{
    self = [super init];
    if (self) {
        _conversation = [[EMClient sharedClient].chatManager getConversation:conversationId type:conversationType createIfNotExist:NO];
        _searchQueue = dispatch_queue_create("com.easemob.search.message", DISPATCH_QUEUE_SERIAL);
        _queueTag = &_queueTag;
        dispatch_queue_set_specific(_searchQueue, _queueTag, _queueTag, NULL);
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    
    self.title = NSLocalizedString(@"title.groupSearchMessage", @"Search Message from History");
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    backButton.accessibilityIdentifier = @"back";
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    
//    UIButton *timeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//    [timeButton setTitle:@"筛选" forState:UIControlStateNormal];
//    [timeButton addTarget:self action:@selector(timeAction) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *timeItem = [[UIBarButtonItem alloc] initWithCustomView:timeButton];
//    [self.navigationItem setRightBarButtonItem:timeItem];
}

- (UILabel*)fromLabel
{
    if (_fromLabel == nil) {
        _fromLabel = [[UILabel alloc] init];
     
        _fromLabel.text = @"筛选发送者:";
        _fromLabel.textColor = [UIColor blackColor];
        _fromLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _fromLabel;
}

- (UILabel*)timeLabel
{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame) + 5, CGRectGetWidth([UIScreen mainScreen].bounds), 20);
        _timeLabel.text = @"筛选发送时间:";
        _timeLabel.textColor = [UIColor blackColor];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _timeLabel;
}

- (UIDatePicker*)datePicker
{
    if(_datePicker == nil){
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.frame = CGRectMake(0, CGRectGetMaxY(self.timeLabel.frame), CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight(_datePicker.frame));
        _datePicker.backgroundColor = [UIColor whiteColor];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        NSDate *minDate = [formatter dateFromString:@"2012-01-01"];
        _datePicker.minimumDate = minDate;
        _datePicker.date = [NSDate date];
    }
    return _datePicker;
}

- (UITextField*)textField
{
    if (_textField == nil) {
        _textField = [[UITextField alloc] init];
        _textField.frame = CGRectMake(0, CGRectGetMaxY(self.fromLabel.frame), CGRectGetWidth([UIScreen mainScreen].bounds), 50.f);
        _textField.textColor = [UIColor blackColor];
        _textField.placeholder = @"填写发送者";
        _textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _textField.layer.borderWidth = 0.5f;
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.delegate = self;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _textField;
}


- (NSString*)getContentFromMessage:(EMMessage*)message
{
    NSString *content = @"";
    if (message) {
        EMMessageBody *messageBody = message.body;
        switch (messageBody.type) {
            case EMMessageBodyTypeImage:{
                content = NSLocalizedString(@"message.image1", @"[image]");
            } break;
            case EMMessageBodyTypeText:{
                // 表情映射。
                NSString *didReceiveText = [EaseConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                content = didReceiveText;
                if ([message.ext objectForKey:MESSAGE_ATTR_IS_BIG_EXPRESSION]) {
                    content = @"[动画表情]";
                }
            } break;
            case EMMessageBodyTypeVoice:{
                content = NSLocalizedString(@"message.voice1", @"[voice]");
            } break;
            case EMMessageBodyTypeLocation: {
                content = NSLocalizedString(@"message.location1", @"[location]");
            } break;
            case EMMessageBodyTypeVideo: {
                content = NSLocalizedString(@"message.video1", @"[video]");
            } break;
            case EMMessageBodyTypeFile: {
                content = NSLocalizedString(@"message.file1", @"[file]");
            } break;
            default: {
            } break;
        }
    }
    return content;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - action

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)timeAction
{
    if (![self.datePicker superview]) {
        [self.view addSubview:self.timeLabel];
        [self.view addSubview:self.fromLabel];
        [self.view addSubview:self.datePicker];
        [self.view addSubview:self.textField];
    } else {
        [self.timeLabel removeFromSuperview];
        [self.fromLabel removeFromSuperview];
        [self.datePicker removeFromSuperview];
        [self.textField removeFromSuperview];
    }
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
