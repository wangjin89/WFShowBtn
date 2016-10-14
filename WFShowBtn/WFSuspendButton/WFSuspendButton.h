//
//  WFSuspendButton.h
//  WFShowBtn
//
//  Created by 王飞 on 16/10/13.
//  Copyright © 2016年 WF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "WFFiveStarView.h"
//代理
@class WFSuspendedButton;

@protocol WFSuspendedButtonDelegate <NSObject>

@optional
-(void)sendResultType:(int)type result:(NSString *)result score:(int)score;
//提交 -1为buttonListView   1为askQuestionView
-(void)submitType:(int)type AndTextViewResult:(NSString *)textViewResult AndStarNum:(int)starNum;
-(void)isButtonTouched;//suspendedButton被点击了
-(void)goToChoosePicture;//跳转去选择图片

@end


@interface WFSuspendButton : UIButton

+ (WFSuspendButton *)suspendedButtonWithCGPoint:(CGPoint)pos inView:(UIView *)baseview;
@property (nonatomic,strong) UITextView *inputText;//buttonListView中的输入框
@property (nonatomic,strong) UITextView *askQuestionInPutText;//askQuestionListView中的输入框
@property (nonatomic,strong) UIButton * addPicBtn;//添加图片按钮
@property (nonatomic,strong) UIButton * addPicBtnDelete;//添加图片按钮右上角删除按钮
@property (nonatomic,strong) UILabel * addPicLable;//提示添加图片的lable
@property (nonatomic,assign) BOOL isShowingAskView;//判断是否弹出的是提问页面（用于判断textView的视图上移）
//代理
@property(nonatomic,weak)id<WFSuspendedButtonDelegate> sendDelegate;

-(void)tiggerButtonList;//suspendedButton按钮点击事件
-(void)askQuestionClicked;//提问按钮事件
-(void)removeAllViews;//点击关闭所有view



@end
