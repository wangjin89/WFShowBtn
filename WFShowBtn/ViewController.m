//
//  ViewController.m
//  WFShowBtn
//
//  Created by 王飞 on 16/10/13.
//  Copyright © 2016年 WF. All rights reserved.
//

#import "ViewController.h"
#import "WFSuspendButton.h"
#import "ControlImgView.h"

@interface ViewController ()<WFSuspendedButtonDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,RemoveModifyView,UIAlertViewDelegate,UIActionSheetDelegate>
{
    BOOL isShowBackView;//是否显示灰色背景
    WFSuspendButton *suspendedBtn;
    NSString * filePath;
    ControlImgView *modifyView;//处理拍出来的图片
    NSString * _pathtmp;
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isShowBackView=NO;
    [self addSuspendedButton];
}


-(void)addSuspendedButton
{
    suspendedBtn=[WFSuspendButton suspendedButtonWithCGPoint:CGPointMake(self.view.frame.size.width-80, 200) inView:self.view];
    suspendedBtn.sendDelegate=self;
    suspendedBtn.backgroundColor=[UIColor redColor];
    [self.view addSubview:suspendedBtn];
}
//实现代理（举手讲快了等按钮的回调）
-(void)sendResultType:(int)type result:(NSString *)result score:(int)score
{
    NSLog(@"type : %d  result : %@",type,result);
    NSLog(@"starView : %d",score);
    if (type==2) {
        //提问按钮
        [suspendedBtn askQuestionClicked];
        //每次进来的时候都会清空filePath
        filePath=@"";
    }else if (type==1)
    {
        //讲快了
        
    }else if (type==0)
    {
        //举手
    }
}
#pragma mark------------提交按钮的回调
-(void)submitType:(int)type AndTextViewResult:(NSString *)textViewResult AndStarNum:(int)starNum
{
    NSLog(@"进来提交");
    NSString * message;
    if (type==-1) {
        message =[NSString stringWithFormat:@"结果： %@ 评价： %d星",textViewResult,starNum];
    }else if(type==1)
    {
        message =[NSString stringWithFormat:@"结果： %@    图片： %@",textViewResult,filePath];
    }
    [self showAlertViewWithMessage:message];
}

//弹出提示框
-(void)showAlertViewWithMessage:(NSString *)message
{
    if ([[UIDevice currentDevice].systemVersion floatValue]>=8.0) {
        UIAlertController * alert =[UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            //取消所需要做的操作
            NSLog(@"取消");
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //确定所需要做的操作
            NSLog(@"确定");
        }]];
        
        [self presentViewController:alert animated:YES completion:^{
            
        }];
        
    }else
    {
        UIAlertView * alert =[[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
}
//alert代理事件
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"取消1");
        }
            break;
        case 1:
        {
            NSLog(@"确定1");
        }
            break;
            
        default:
            break;
    }
}

//suspendedBtn按钮的回调
-(void)isButtonTouched
{
    isShowBackView=!isShowBackView;
}

#pragma mark-------系统点击事件的隐藏view
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    //判断点击的位置
    CGPoint center =self.view.center;
    if (isShowBackView) {
        //250和280是中间显示view的宽和高
        if ((touchPoint.x>(center.x-250/2))&&(touchPoint.x<(center.x+250/2))&&(touchPoint.y>(center.y-280/2))&&(touchPoint.y<(center.y+280/2))) {
            
        }else
        {
            [suspendedBtn removeAllViews];
            filePath=@"";
            isShowBackView =NO;
        }
        if (suspendedBtn.inputText) {
            [suspendedBtn.inputText resignFirstResponder];
        }
        if (suspendedBtn.askQuestionInPutText) {
            [suspendedBtn.askQuestionInPutText resignFirstResponder];
        }
    }
    
}

#pragma mark---------跳转相机
-(void)goToChoosePicture
{
//    [self GetPhotos];
    [self TakeCamera];
}

-(void)GetPhotos
{
    UIActionSheet *actionSheet = nil;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        actionSheet = [[UIActionSheet alloc] init];
        actionSheet.delegate = self;
        [actionSheet addButtonWithTitle:NSLocalizedString(@"local_takePhoto", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"local_photoChoose", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"local_cancle", nil)];
        [actionSheet setCancelButtonIndex:2];
    }else
    {
        actionSheet = [[UIActionSheet alloc] init];
        actionSheet.delegate = self;
        [actionSheet addButtonWithTitle:NSLocalizedString(@"local_photoChoose", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"local_cancle", nil)];
        [actionSheet setCancelButtonIndex:1];
    }
    [actionSheet showInView:self.view];
}
#pragma mark----- actiondelegate选择系统图片
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        switch (buttonIndex)
        {
            case 0:
                [self TakeCamera];
                break;
            case 1:
                [self TakePhoto];
                break;
            default:
                break;
        }
    }else
    {
        switch (buttonIndex)
        {
            case 0:
                [self TakePhoto];
                break;
            default:
                break;
        }
    }
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
}
-(void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    
}

//相册
-(void)TakePhoto
{
    self.hidesBottomBarWhenPushed = YES;
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.allowsEditing = NO;
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:controller animated:YES completion:nil];
    });
}

//相机
-(void)TakeCamera
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.allowsEditing = NO;
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:controller animated:YES completion:nil];
    });
}

#pragma mark---------系统相册方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *image = [self scaleImage:img toScale:0.5];
    [self SaveImageToFile:image];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    modifyView = [[ControlImgView alloc] init:0 Path:filePath Rect:CGRectMake(0, 0, window.frame.size.width, window.frame.size.height)];
    modifyView.delegate = self;
    if(picker.sourceType==UIImagePickerControllerSourceTypeCamera)
    {
        if(image)
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    }
    [window addSubview:modifyView];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark---------保存图片
-(void)SaveImageToFile:(UIImage *)image
{
    if(!image)
    {
        return;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHMMss"];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg",[formatter stringFromDate:[NSDate date]]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dic = [NSHomeDirectory() stringByAppendingString:@"/Documents/pictureMy/"];
    BOOL isDic1;
    if(![fileManager fileExistsAtPath:dic isDirectory:&isDic1]||(!isDic1))
    {
        [fileManager createDirectoryAtPath:dic withIntermediateDirectories:YES attributes:nil error:nil];
    }
    int currentpage;
    currentpage=5555;
    //    int studentNumber=[[[NSUserDefaults standardUserDefaults]valueForKey:myInputNameEasyAnswer] intValue];
    int studentNumber=5555;
    fileName =[NSString stringWithFormat:@"%d.jpg",currentpage];
    NSString * fileWithstudentNumber =[dic stringByAppendingString:[NSString stringWithFormat:@"%d",studentNumber]];
    BOOL isDic;
    if(![fileManager fileExistsAtPath:fileWithstudentNumber isDirectory:&isDic]||(!isDic))
    {
        [fileManager createDirectoryAtPath:fileWithstudentNumber withIntermediateDirectories:YES attributes:nil error:nil];
    }
    filePath = [NSString stringWithFormat:@"%@/%@",fileWithstudentNumber,fileName];
    NSLog(@"filePath-->12 %@",filePath);
    if ([fileManager fileExistsAtPath:filePath]) {
        //        NSLog(@"filePath--> %@",filePath);
        [fileManager removeItemAtPath:filePath error:nil];
    }
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    if(imageData)
    {
        [fileManager createFileAtPath:filePath contents:imageData attributes:nil];
    }
}
-(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

#pragma mark---------RemoviewDelegate的回调
-(void)RemoveView
{
    if(modifyView)
    {
        [modifyView removeFromSuperview];
        modifyView = nil;
        UIImage *img = [UIImage imageWithContentsOfFile:filePath];
        if(!img)
        {
            return;
        }
        //显示结果
        if (suspendedBtn.addPicBtn) {
            [suspendedBtn.addPicBtn setImage:[UIImage imageWithContentsOfFile:filePath] forState:UIControlStateNormal];
            suspendedBtn.addPicBtnDelete.hidden=NO;
            suspendedBtn.addPicLable.hidden=YES;
        }
    }
}




@end
