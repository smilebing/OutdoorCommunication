//
//  QRSearchInputView.h
//  News
//
//  Created by Alfa on 17/5/28.
//  Copyright © 2017年 Alfa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QRSearchInputView;

@protocol  QRSearchInputViewDelegate<NSObject>

- (void)searchInputView:(QRSearchInputView *)searchInputView didClickedCacelButton:(UIButton *)button;

- (void)searchInputViewEndInput:(QRSearchInputView *)searchInputView;

- (void)searchInputViewClearContent:(QRSearchInputView *)searchInputView;
@end

@interface QRSearchInputView : UIView

@property (nonatomic, copy) NSString *keyWord;

@property (nonatomic, weak) id<QRSearchInputViewDelegate>delegate;

- (void)beginInput;

- (void)removeObserver;

@end
