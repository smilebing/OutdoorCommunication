//
//  QRSearchInputView.m
//  News
//
//  Created by Alfa on 17/5/28.
//  Copyright © 2017年 Alfa. All rights reserved.
//

#import "QRSearchInputView.h"

@interface QRSearchInputView()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;


@end


@implementation QRSearchInputView{
    
    NSString *_keyWord;
}

#pragma mark - LifeCycle

#pragma mark - View lifeCycle
- (void)awakeFromNib{
    
    [super awakeFromNib];
    
    self.textField.tintColor = [UIColor blackColor];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
    imageView.frame = CGRectMake(0, 0, 20,20);
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    self.textField.leftView = imageView;
    self.textField.delegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChanged:)
                                                name:@"UITextFieldTextDidChangeNotification" object:self.textField];
}

#pragma mark - Layout
#pragma mark - User interaction

- (IBAction)cancelButtonDidClicked:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchInputView:didClickedCacelButton:)]) {
        
        [self.delegate searchInputView:self didClickedCacelButton:sender];
    }
}

#pragma mark - Delegate

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchInputViewEndInput:)]) {
        
        [self.delegate searchInputViewEndInput:self];
    }
    
    return YES;
}

#pragma mark - Public interface

- (void)beginInput{
    
    [self.textField becomeFirstResponder];
}

- (void)removeObserver{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private

- (void)textFieldDidChanged:(NSNotification *)noti{
    
    UITextField *textField= (UITextField *)noti.object;
    
    if (0 == textField.text.length && self.delegate && [self.delegate respondsToSelector:@selector(searchInputViewClearContent:)]) {
        
        [self.delegate searchInputViewClearContent:self];
    }
    
}

#pragma mark - Getter or Setter

- (NSString *)keyWord{
    
    return self.textField.text;
}

- (void)setKeyWord:(NSString *)keyWord{
    
    _keyWord= keyWord;
    _textField.text = keyWord;
}


@end
