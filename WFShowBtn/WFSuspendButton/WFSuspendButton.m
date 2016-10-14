//
//  WFSuspendButton.m
//  WFShowBtn
//
//  Created by 王飞 on 16/10/13.
//  Copyright © 2016年 WF. All rights reserved.
//

#import "WFSuspendButton.h"

#define BUTTON_AVAILABLE @"BUTTONAVAILABLE"
//buttonListView 高度
#define listH 280
//按钮的个数
#define numOfButton 3
@interface WFSuspendButton ()<UITextViewDelegate>
{
    BOOL _isShowingButtonList;
    BOOL _isOnLeft;
    BOOL _isBackUp;
    BOOL _isTest;
    CGPoint _tempCenter;
    CGPoint _originalPosition;
    CGRect _windowSize;
    UIView *_baseView;//基层的View
    UIView * _myBackView;//蒙层
    UIView *_buttonListView;//按钮和打分的View
    UILabel *defLabel;//按钮和打分的View的默认提示的lable
    UIView *_askQuestionListView;//点击提问弹出的View
    CGFloat listViewWidth;//弹出视图的宽度
    UILabel *askQuestionDefLabel;//点击提问弹出的View的默认提示的lable
    UIButton * goBackBtn;//返回按钮
    UIView * askQuestionBackView;//带边框的View
    UIButton * submitBtnButtonListView;//buttonListView中的提交按钮
    UIButton * submitBtnAskQuestionListView;//_askQuestionListView中的提交按钮
    
    UIImageView * dottedImageView;//虚线
    
    BOOL _isShowingAskView;
    
}

@property (nonatomic,strong) UIView *buttonListView;
@property (nonatomic,strong) UIView *baseView;
@property (nonatomic,strong) UIView * myBackView;
@property (nonatomic,strong) UIView *askQuestionListView;
@property (nonatomic,strong) WFFiveStarView *starView;
@end


@implementation WFSuspendButton

@synthesize buttonListView = _buttonListView;
@synthesize baseView = _baseView;
@synthesize myBackView = _myBackView;
@synthesize askQuestionListView = _askQuestionListView;
@synthesize addPicBtn = _addPicBtn;
@synthesize addPicBtnDelete = _addPicBtnDelete;

static WFSuspendButton *_instance = nil;

#pragma mark - 继承方法
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _isShowingButtonList = NO;
        _isShowingAskView=NO;
        //_isBackUp = NO;
        //self.hidden = YES;
        //_isTest = NO;
        //[self httpRequest];
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"touchBegan");
    
    _originalPosition = [[touches anyObject] locationInView:self];
    _tempCenter = self.center;
    
    //    self.backgroundColor = [UIColor greenColor];//移动过程中的颜色
    
    CGAffineTransform toBig = CGAffineTransformMakeScale(1.2, 1.2);//变大
    
    [UIView animateWithDuration:0.1 animations:^{
        // Translate bigger
        self.transform = toBig;
        
    } completion:^(BOOL finished)   {}];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"touchMove");
    
    CGPoint currentPosition = [[touches anyObject] locationInView:self];
    float detaX = currentPosition.x - _originalPosition.x;
    float detaY = currentPosition.y - _originalPosition.y;
    
    CGPoint targetPositionSelf = self.center;
    CGPoint targetPositionButtonList = _buttonListView.center;
    targetPositionSelf.x += detaX;
    targetPositionSelf.y += detaY;
    targetPositionButtonList.x += detaX;
    targetPositionButtonList.y += detaY;
    
    self.center = targetPositionSelf;
    //修改，让_buttonListView.center不跟着button移动
    //    _buttonListView.center = targetPositionButtonList;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"touchCancell");
    
    // 触发touchBegan后，tap手势被识别后会将touchMove和touchEnd的事件截取掉触发自身手势回调，然后运行touchCancell。touchBegan中设置的按钮状态在touchEnd和按钮触发方法两者中分别设置还原。
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"touchEnd");
    
    CGAffineTransform toNormal = CGAffineTransformTranslate(CGAffineTransformIdentity, 1/1.2, 1/1.2);
    CGPoint newPosition = [self correctPosition:self.frame.origin];
    
    [UIView animateWithDuration:0.1 animations:^{
        
        // Translate normal
        self.transform = toNormal;
        self.backgroundColor = [UIColor redColor];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.4 animations:^{
            self.frame = CGRectMake(newPosition.x, newPosition.y, self.bounds.size.width, self.bounds.size.height);
            //            [self adjustButtonListView];
        }];
        
    }];
}

#pragma mark-----提交按钮

-(void)submitBtnButtonListViewClicked
{
    NSLog(@"第一页提交按钮");
    if ([self.sendDelegate respondsToSelector:@selector(submitType:AndTextViewResult:AndStarNum:)]) {
        [self.sendDelegate submitType:-1 AndTextViewResult:_inputText.text AndStarNum:[self.starView.Score intValue]];
    }
}

-(void)submitBtnAskQuestionListViewClicked
{
    NSLog(@"第二页提交按钮");
    if ([self.sendDelegate respondsToSelector:@selector(submitType:AndTextViewResult:AndStarNum:)]) {
        [self.sendDelegate submitType:1 AndTextViewResult:_askQuestionInPutText.text AndStarNum:0];
    }
}

#pragma mark-----提问事件
-(void)askQuestionClicked
{
    //防止出现视图仍在上方的情况
    _buttonListView.center=_baseView.center;
    _buttonListView.hidden=YES;
    _isShowingAskView=YES;
    //防止可能出现的键盘仍在弹出的情况
    [_inputText resignFirstResponder];
    //创建新视图
    [_instance setupAskQuestionView];
}

-(void)setupAskQuestionView
{
    _askQuestionListView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, listViewWidth, 220)];
    _askQuestionListView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0];//按钮列表背景色
    _askQuestionListView.layer.cornerRadius = 10;
    //修改，让_buttonListView居中
    _askQuestionListView.center =_baseView.center;
    [_baseView addSubview:_askQuestionListView];
    
    [self setupAskQuestionViewSubViews];
}

//子视图
-(void)setupAskQuestionViewSubViews
{
    //带边框的View
    askQuestionBackView =[[UIView alloc]initWithFrame:CGRectMake(10, 10, listViewWidth-20, 150)];
    askQuestionBackView.backgroundColor=[UIColor whiteColor];
    askQuestionBackView.layer.cornerRadius=5;
    askQuestionBackView.layer.borderWidth=1;
    askQuestionBackView.layer.borderColor=[[UIColor blackColor] CGColor];
    [_askQuestionListView addSubview:askQuestionBackView];
    
    //输入框
    UITextView *askQuestionInPut=[[UITextView alloc]initWithFrame:CGRectMake(15, 15, listViewWidth-30, 200-10-60-60)];
    askQuestionInPut.delegate=self;
    if (askQuestionDefLabel) {
        [askQuestionDefLabel removeFromSuperview];
        askQuestionDefLabel=nil;
    }
    askQuestionDefLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 100, 20)];
    askQuestionDefLabel.enabled = NO;
    askQuestionDefLabel.text = @"请输入提问内容";
    askQuestionDefLabel.font =  [UIFont systemFontOfSize:13];
    askQuestionDefLabel.textColor=[UIColor colorWithRed:199/255.0 green:199/255.0 blue:205/255.0 alpha:1.0];
    [askQuestionInPut addSubview:askQuestionDefLabel];
    [_askQuestionListView addSubview:askQuestionInPut];
    self.askQuestionInPutText=askQuestionInPut;
    
    //添加照片按钮
    _addPicBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    _addPicBtn.frame=CGRectMake(20, CGRectGetMaxY(askQuestionInPut.frame)+10, 50, 50);
    [_addPicBtn setImage:[UIImage imageNamed:@"addPicture"] forState:UIControlStateNormal];
    _addPicBtn.layer.cornerRadius=5;
    [_addPicBtn addTarget:self action:@selector(addPicture) forControlEvents:UIControlEventTouchUpInside];
    _addPicBtn.adjustsImageWhenHighlighted = NO;
    [_askQuestionListView addSubview:_addPicBtn];
    
    //添加照片按钮右上角的红色按钮
    _addPicBtnDelete=[UIButton buttonWithType:UIButtonTypeCustom];
    _addPicBtnDelete.frame=CGRectMake(CGRectGetMaxX(_addPicBtn.frame)-10, CGRectGetMaxY(askQuestionInPut.frame), 20, 20);
    [_addPicBtnDelete setImage:[UIImage imageNamed:@"addpicDelete"] forState:UIControlStateNormal];
    [_addPicBtnDelete addTarget:self action:@selector(addPictureDelete) forControlEvents:UIControlEventTouchUpInside];
    _addPicBtnDelete.adjustsImageWhenHighlighted = NO;
    _addPicBtnDelete.hidden =YES;
    [_askQuestionListView addSubview:_addPicBtnDelete];
    
    //添加图片的提示lable
    _addPicLable=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_addPicBtn.frame)+5, CGRectGetMaxY(askQuestionInPut.frame)+5+20, 100, 20)];
    _addPicLable.enabled = NO;
    _addPicLable.text = @"添加图片";
    _addPicLable.font =  [UIFont systemFontOfSize:13];
    _addPicLable.textColor=[UIColor colorWithRed:199/255.0 green:199/255.0 blue:205/255.0 alpha:1.0];
    [_askQuestionListView addSubview:_addPicLable];
    
    
    //返回按钮
    goBackBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    goBackBtn.frame=CGRectMake(20, CGRectGetMaxY(askQuestionBackView.frame)+15, 30, 30);
    [goBackBtn setImage:[UIImage imageNamed:@"gobackToList"] forState:UIControlStateNormal];
    goBackBtn.layer.cornerRadius=5;
    [goBackBtn addTarget:self action:@selector(gobackToListBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    goBackBtn.adjustsImageWhenHighlighted = NO;
    [_askQuestionListView addSubview:goBackBtn];
    
    //提交按钮
    submitBtnAskQuestionListView =[UIButton buttonWithType:UIButtonTypeCustom];
    submitBtnAskQuestionListView.frame=CGRectMake(_buttonListView.frame.size.width-60-10, CGRectGetMaxY(askQuestionBackView.frame)+10, 60, 40);
    [submitBtnAskQuestionListView addTarget:self action:@selector(submitBtnAskQuestionListViewClicked) forControlEvents:UIControlEventTouchUpInside];
    [submitBtnAskQuestionListView setTitle:@"提交" forState:UIControlStateNormal];
    submitBtnAskQuestionListView.titleLabel.font=[UIFont systemFontOfSize:15];
    submitBtnAskQuestionListView.layer.cornerRadius=20;
    //设置背景色
    [submitBtnAskQuestionListView setBackgroundColor:[UIColor redColor]];
    //    [submitBtnAskQuestionListView setBackgroundColor:<#(UIColor * _Nullable)#>];
    [_askQuestionListView addSubview:submitBtnAskQuestionListView];
    
    
}
#pragma mark-------返回按钮
-(void)gobackToListBtnClicked
{
    if (_askQuestionListView) {
        [_askQuestionListView removeFromSuperview];
        _askQuestionListView=nil;
    }
    _buttonListView.hidden=NO;
    _isShowingAskView=NO;
    
    
}

//跳转相机
-(void)addPicture
{
    //通知去跳转
    NSLog(@"去跳转");
    if ([self.sendDelegate respondsToSelector:@selector(goToChoosePicture)]) {
        [self.sendDelegate goToChoosePicture];
    }
}

//图片删除事件
-(void)addPictureDelete
{
    [_addPicBtn setImage:[UIImage imageNamed:@"addPicture"] forState:UIControlStateNormal];
    _addPicBtnDelete.hidden=YES;
    _addPicLable.hidden=NO;
}

#pragma mark - 类方法
+ (WFSuspendButton *)suspendedButtonWithCGPoint:(CGPoint)pos inView:(UIView *)baseview
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[WFSuspendButton alloc] initWithCGPoint:pos];
        _instance.baseView = baseview;
        //背景view
        [_instance configBackView];
        
        [_instance constructUI];
        [baseview addSubview:_instance];
    });
    
    return _instance;
}

-(void)configBackView
{
    _myBackView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
    _myBackView.backgroundColor=[UIColor blackColor];
    _myBackView.alpha=0.4;
    _myBackView.userInteractionEnabled=YES;
    _myBackView.hidden=YES;
    [_baseView addSubview:_myBackView];
}

+ (void)deleteSuspendedButton
{
    [_instance removeFromSuperview];
}

#pragma mark - 辅助方法
- (id)initWithCGPoint:(CGPoint)pos
{
    AppDelegate *appdel=[UIApplication sharedApplication].delegate;
    _windowSize = appdel.window.frame; //封装了获取屏幕Size的方法
    
    CGPoint newPosition = [self correctPosition:pos];
    
    return [self initWithFrame:CGRectMake(newPosition.x, newPosition.y, 60, 60)];
}

- (CGPoint)correctPosition:(CGPoint)pos
{
    CGPoint newPosition;
    
    if ((pos.x + 60 > _windowSize.size.width) || (pos.x > _windowSize.size.width/2-30)) {
        newPosition.x = _windowSize.size.width - 60 -10;
        _isOnLeft = NO;
    } else {
        newPosition.x = 10;
        _isOnLeft = YES;
    }
    
    (pos.y + 60 > _windowSize.size.height)?(newPosition.y = _windowSize.size.height - 60 -10):((pos.y < 0)?newPosition.y = 10:(newPosition.y = pos.y));
    
    return newPosition;
}

#pragma mark-------初始的视图创建
- (void)constructUI
{
    self.backgroundColor = [UIColor redColor];
    self.alpha = 1.0;
    self.layer.cornerRadius = 30;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tiggerButtonList)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tap];
    
    //按钮的个数
    listViewWidth =numOfButton*(60+20)+10;
    self.buttonListView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, numOfButton*(60+20)+10, listH)];
    _buttonListView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0];//按钮列表背景色
    _buttonListView.alpha = 0;
    _buttonListView.layer.cornerRadius = 10;
    
    [self createButtonByNumber:numOfButton withSize:CGSizeMake(60, 60) inView:(UIView *)_buttonListView];
    _buttonListView.hidden = YES;
    //修改，让_buttonListView居中
    _buttonListView.center =_baseView.center;
    
    [_baseView addSubview:_buttonListView];
    
}

- (void)createButtonByNumber:(NSUInteger)number withSize:(CGSize)size inView:(UIView *)view
{
    NSArray * picArray=@[@"pushHand",@"speakFast",@"askQuestionPic"];
    NSArray * titleArray=@[@"举手",@"讲快了",@"提问"];
    
    //子按钮的UI效果自定义
    for (NSUInteger i = 0; i < number; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        //        button.backgroundColor=[UIColor redColor];
        CALayer *layer=[button layer];
        layer.cornerRadius=20;
        layer.masksToBounds=YES;
        [button setImage:[UIImage imageNamed:picArray[i]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(optionsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i + 2000;
        button.frame = CGRectMake(15 + i*(size.width+20), 15, size.width, size.height);
        //        button.tintColor = [UIColor redColor];
        [view addSubview:button];
        
        UILabel * lable=[[UILabel alloc]initWithFrame:CGRectMake(15 + i*(size.width+20), 60+2, size.width, size.height)];
        lable.textAlignment=NSTextAlignmentCenter;
        lable.text=titleArray[i];
        lable.font=[UIFont systemFontOfSize:13];
        [view addSubview:lable];
        
    }
    //虚线
    [self layoutLines];
    
    WFFiveStarView *starView = [[WFFiveStarView alloc]initWithFrame:CGRectMake(10,CGRectGetMaxY(dottedImageView.frame)+5, _buttonListView.frame.size.width-20,30)];
    starView.Score=@0.0;
    starView.canChoose = YES;
    //    starView.starImage_Full = [UIImage imageNamed:@"img1.png"];
    //    starView.starImage_Empty = [UIImage imageNamed:@"img2.png"];
    //    starView.animation = YES;
    [_buttonListView addSubview:starView];
    self.starView=starView;
    
    UITextView *input=[[UITextView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(starView.frame)+15, _buttonListView.frame.size.width-20, _buttonListView.frame.size.height-10-60-70-60)];
    input.delegate=self;
    if (defLabel) {
        [defLabel removeFromSuperview];
        defLabel=nil;
    }
    defLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 100, 20)];
    defLabel.enabled = NO;
    defLabel.text = @"请输入建议内容";
    defLabel.font =  [UIFont systemFontOfSize:13];
    defLabel.textColor=[UIColor colorWithRed:199/255.0 green:199/255.0 blue:205/255.0 alpha:1.0];
    [input addSubview:defLabel];
    [_buttonListView addSubview:input];
    self.inputText=input;
    
    //提交按钮
    submitBtnButtonListView =[UIButton buttonWithType:UIButtonTypeCustom];
    submitBtnButtonListView.frame=CGRectMake(_buttonListView.frame.size.width-60-10, CGRectGetMaxY(input.frame)+8, 60, 40);
    [submitBtnButtonListView addTarget:self action:@selector(submitBtnButtonListViewClicked) forControlEvents:UIControlEventTouchUpInside];
    [submitBtnButtonListView setTitle:@"提交" forState:UIControlStateNormal];
    submitBtnButtonListView.titleLabel.font=[UIFont systemFontOfSize:15];
    submitBtnButtonListView.layer.cornerRadius=20;
    //设置背景色
    [submitBtnButtonListView setBackgroundColor:[UIColor redColor]];
    //    [submitBtn setBackgroundColor:<#(UIColor * _Nullable)#>];
    [_buttonListView addSubview:submitBtnButtonListView];
    
    
    self.buttonListView.frame=CGRectMake(0, 0, numOfButton*(60+20)+10, CGRectGetMaxY(submitBtnButtonListView.frame)+5);
    
}

//虚线
-(void)layoutLines
{
    dottedImageView=[[UIImageView alloc] initWithFrame:CGRectMake(10, 90+15,  _buttonListView.frame.size.width-20, 2)];
    dottedImageView.image = [self drawLineByImageView:dottedImageView];
    [_buttonListView addSubview:dottedImageView];
    
    
}

// 返回虚线image的方法
- (UIImage *)drawLineByImageView:(UIImageView *)imageView
{
    UIGraphicsBeginImageContext(imageView.frame.size);   //开始画线 划线的frame
    [imageView.image drawInRect:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    //设置线条终点形状
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    // 5是每个虚线的长度  1是高度
    CGFloat lengths[] = {5,1};
    CGContextRef line = UIGraphicsGetCurrentContext();
    // 设置颜色
    CGContextSetStrokeColorWithColor(line, [UIColor colorWithWhite:0.408 alpha:1.000].CGColor);
    
    CGContextSetLineDash(line, 0, lengths, 2);  //画虚线
    CGContextMoveToPoint(line, 0.0, 2.0);    //开始画线
    CGContextAddLineToPoint(line, imageView.frame.size.width, 2.0);
    CGContextStrokePath(line);
    // UIGraphicsGetImageFromCurrentImageContext()返回的就是image
    return UIGraphicsGetImageFromCurrentImageContext();
}

- (void)adjustButtonListView
{
    CGFloat viewY;
    if (self.frame.origin.y+self.frame.size.height/2>self.baseView.frame.size.height/2) {
        viewY=self.center.y - listH;
    }else{
        viewY=self.center.y;
    }
    if (_isOnLeft) {
        _buttonListView.frame = CGRectMake(60 +15, viewY, _buttonListView.bounds.size.width, _buttonListView.bounds.size.height);
    } else {
        _buttonListView.frame = CGRectMake((_windowSize.size.width - 60 -15 - _buttonListView.bounds.size.width), viewY, _buttonListView.bounds.size.width, _buttonListView.bounds.size.height);
    }
}

#pragma mark - 按钮回调
- (void)tiggerButtonList
{
    NSLog(@"tiggerTap");
    
    _isShowingButtonList = !_isShowingButtonList;
    
    CGAffineTransform toNormal = CGAffineTransformTranslate(CGAffineTransformIdentity, 1/1.2, 1/1.2);
    [UIView animateWithDuration:0.1 animations:^{
        // Translate normal
        self.transform = toNormal;
        self.backgroundColor = [UIColor redColor];
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.1 animations:^{
            self.center = _tempCenter;
            //            [self adjustButtonListView];
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.3 animations:^{
                _buttonListView.hidden = !_isShowingButtonList;
                _isShowingButtonList ? (_buttonListView.alpha = 1.0) : (_buttonListView.alpha = 0);
                _isShowingButtonList ? (_myBackView.hidden = NO) : (_myBackView.hidden = YES);
                _isShowingButtonList ? (_instance.hidden = YES) : (_instance.hidden = NO);
                
            }];
        }];
    }];
    
    
    if ([self.sendDelegate respondsToSelector:@selector(isButtonTouched)]) {
        [self.sendDelegate isButtonTouched];
    }
    
}

- (void)optionsButtonPressed:(UIButton *)button
{
    //NSLog(@"buttonNumberPressed:%d",button.tag);
    if ([self.sendDelegate respondsToSelector:@selector(sendResultType:result:score:)]) {
        [self.sendDelegate sendResultType:(int)button.tag-2000 result:_inputText.text score:[self.starView.Score intValue]];
    }
    //    switch (button.tag-2000) {
    //        case 0:
    //            NSLog(@"button0: %@",_inputText.text);
    //
    //            break;
    //        case 1:
    //            NSLog(@"button1: %@",_inputText.text);
    //            break;
    //        case 2:
    //            NSLog(@"button2: %@",_inputText.text);
    //            break;
    //        case 3:
    //            NSLog(@"button3: %@",_inputText.text);
    //            break;
    //        default:
    //            NSLog(@"button4: %@",_inputText.text);
    //            break;
    //    }
}

#pragma mark------------textView代理方法
//默认文字效果
- (void) textViewDidChange:(UITextView *)textView{
    if ([textView.text length] == 0) {
        [defLabel setHidden:NO];
        [askQuestionDefLabel setHidden:NO];
    }else{
        [defLabel setHidden:YES];
        [askQuestionDefLabel setHidden:YES];
    }
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (_isShowingAskView) {
        _askQuestionListView.center =CGPointMake(_baseView.center.x, _baseView.center.y-50);
    }else
    {
        _buttonListView.center= CGPointMake(_baseView.center.x, _baseView.center.y-50);
    }
    
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if (_isShowingAskView) {
        _askQuestionListView.center = _baseView.center;
    }else
    {
        _buttonListView.center=_baseView.center;
    }
}

#pragma mark--------移除所有视图
-(void)removeAllViews
{
    if (_buttonListView) {
        _buttonListView.hidden=YES;
    }
    if (_askQuestionListView) {
        [_askQuestionListView removeFromSuperview];
        _askQuestionListView=nil;
    }
    if (_myBackView) {
        _myBackView.hidden=YES;
        
    }
    _isShowingButtonList=NO;
    _isShowingAskView=NO;
    _instance.hidden=NO;
}




@end
