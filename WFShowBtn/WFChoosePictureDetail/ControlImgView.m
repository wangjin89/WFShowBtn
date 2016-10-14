//
//  ModifyImgView.m
//  YJTypicalMistake
//
//  Created by edutech on 15-3-4.
//  Copyright (c) 2015年 WF. All rights reserved.
//

#import "ControlImgView.h"

@implementation ControlImgView
@synthesize delegate;
-(id)init:(int)type Path:(NSString *)path Rect:(CGRect )rect
{
    self = [super init];
    if(self)
    {
        typeMode = type;
        imgPath = path;
        self.frame = rect;
        self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0];
        [self initView];
        picOt = 0;
    }
    return self;
}
//typeMode:0 图片选择;1 包括图片删除.
-(void) initView
{
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor colorWithRed:42/255.0 green:41/255.0 blue:37/255.0 alpha:1.0];
    bottomView.frame = CGRectMake(0, self.frame.size.height-60, self.frame.size.width, 60);
    leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if(typeMode==0)
    {
        leftButton.frame = CGRectMake(8, 12, 45, 45);
        [leftButton  setTitle:NSLocalizedString(@"local_cancle", nil) forState:UIControlStateNormal];
        [leftButton setTitleColor:[UIColor colorWithRed:40/255.0 green:86/255.0 blue:180.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [leftButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [leftButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [leftButton addTarget:self action:@selector(DeleteAndBack:) forControlEvents:UIControlEventTouchUpInside];
    }else
    {
        leftButton.frame = CGRectMake((self.frame.size.width-30)/2, 13, 30, 32);
        [leftButton setBackgroundImage:[UIImage imageNamed:@"btn_hui_bai.png"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(Back:) forControlEvents:UIControlEventTouchDown];
    }
    rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if(typeMode==0)
    {
        [rightButton setTitle:NSLocalizedString(@"local_end", nil) forState:UIControlStateNormal];
        [rightButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        rightButton.frame = CGRectMake(self.frame.size.width-50, 12, 45, 45);
        [rightButton setTitleColor:[UIColor colorWithRed:40/255.0 green:86/255.0 blue:180.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [rightButton addTarget:self action:@selector(SaveAndBack:) forControlEvents:UIControlEventTouchUpInside];

    }else
    {
        rightButton.frame = CGRectMake(self.frame.size.width-47, 13, 25, 32);
        [rightButton setBackgroundImage:[UIImage imageNamed:@"btn_pic_del"] forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(DeleteAndBack:) forControlEvents:UIControlEventTouchDown];
        rightButton.hidden = YES;
    }
    
    leftTurnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImageView *leftImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 25, 22)];
    leftImage.image = [UIImage imageNamed:@"btn_turn_left.png"];
    leftImage.tag = 10001;
    [leftTurnButton addSubview:leftImage];
//    leftTurnButton.frame = CGRectMake((self.frame.size.width-100-100)/3+55, 7, 40, 50);
    [leftTurnButton setTitle:NSLocalizedString(@"local_left", nil) forState:UIControlStateNormal];
    leftTurnButton.titleLabel.font = [UIFont systemFontOfSize:12];
    leftTurnButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [leftTurnButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftTurnButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    UIEdgeInsets titleInsert = UIEdgeInsetsMake(27, -2, 0, 0);
    [leftTurnButton setTitleEdgeInsets:titleInsert];
    [leftTurnButton addTarget: self action:@selector(TurnLeft) forControlEvents:UIControlEventTouchDown];
    
    rightTurnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImageView *rightImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 25, 22)];
    rightImage.image = [UIImage imageNamed:@"btn_turn_right.png"];
    rightImage.tag = 10002;
    [rightTurnButton addSubview:rightImage];
//    rightTurnButton.frame = CGRectMake((self.frame.size.width-100-100)/3*2+50+45, 7, 40, 50);
    [rightTurnButton setTitle:NSLocalizedString(@"local_right", nil) forState:UIControlStateNormal];
    rightTurnButton.titleLabel.font = [UIFont systemFontOfSize:12];
    rightTurnButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [rightTurnButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightTurnButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    UIEdgeInsets titlerightInsert = UIEdgeInsetsMake(27, -2, 0, 0);
    [rightTurnButton setTitleEdgeInsets:titlerightInsert];
    [rightTurnButton addTarget: self action:@selector(TurnRight) forControlEvents:UIControlEventTouchDown];
    if(typeMode==0)
    {
        leftTurnButton.frame = CGRectMake((self.frame.size.width-100-100)/3+55, 7, 40, 50);
        rightTurnButton.frame = CGRectMake((self.frame.size.width-100-100)/3*2+50+45, 7, 40, 50);
    }else
    {
        leftTurnButton.frame = CGRectMake(30, 7, 40, 50);
        rightTurnButton.frame = CGRectMake(self.frame.size.width-70, 7, 40, 50);
    }
    imageModify = [UIImage imageWithContentsOfFile:imgPath];
    if(imageModify)
    {
        topImagePic = imageModify;
//        leftImagePic = [self image:imageModify rotation:UIImageOrientationLeft];
//        bottomImagePic = [self image:imageModify rotation:UIImageOrientationDown];
//        rightImagePic = [self image:imageModify rotation:UIImageOrientationRight];
        [self setImageView];

    }
    [bottomView addSubview:rightTurnButton];
    [bottomView addSubview:leftTurnButton];
    [bottomView addSubview:leftButton];
    [bottomView addSubview:rightButton];
    [self addSubview:bottomView];
}
-(UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.
                                           size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newPic;
}
//更新显示的图片
-(void)setImageView
{
    UIImage *newImage = nil;
    switch (picOt) {
        case 0:
            newImage = topImagePic;
            break;
        case 1:
            if(leftImagePic==nil)
            {
                leftImagePic = [self image:imageModify rotation:UIImageOrientationLeft];
            
            }
            newImage = leftImagePic;
            break;
        case 2:
            if(bottomImagePic==nil)
            {
                bottomImagePic = [self image:imageModify rotation:UIImageOrientationDown];
            }
            newImage = bottomImagePic;
            break;
        case 3:
            if(rightImagePic==nil)
            {
                rightImagePic = [self image:imageModify rotation:UIImageOrientationRight];
            }
            newImage = rightImagePic;
            break;
        default:
            newImage = imageModify;
            break;
    }
    float width = newImage.size.width;
    float height = newImage.size.height;
    float widthScale = width*1.0/self.frame.size.width;
    float heightScale = height*1.0/(self.frame.size.height-60);
    float scale = (widthScale>heightScale)?widthScale:heightScale;
    scale = (scale==0)?1:scale;
    width = width/scale;
    height = height/scale;
    
    
    if(typeMode==0)
    {
        imageViewCrop = [[BJImageCropper alloc] initWithFrame:CGRectMake((self.frame.size.width-width)/2, (self.frame.size.height-60-height)/2, width, height)];
        imageViewCrop.imageView.layer.shadowColor = [[UIColor blackColor] CGColor];
        imageViewCrop.imageView.layer.shadowRadius = 3.0f;
        imageViewCrop.imageView.layer.shadowOpacity = 0.8f;
        imageViewCrop.imageView.layer.shadowOffset = CGSizeMake(1, 1);
        [imageViewCrop setImage:newImage];
        [self addSubview:imageViewCrop];
    }else
    {
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-width)/2, (self.frame.size.height-60-height)/2, width, height)];
        
        [imageView setImage:newImage];
        [self addSubview:imageView];
    }

}

//向左旋转事件
-(void)TurnLeft
{
    if(!imageModify)
    {
        return ;
    }
    picOt ++;
    if(picOt>=4)
    {
        picOt = 0;
    }
    if(typeMode==0)
    {
        [imageViewCrop removeFromSuperview];
    }else
    {
        [imageView removeFromSuperview];
    }
    [self setImageView];
        
    
}

//向右旋转事件
-(void)TurnRight
{
    if(!imageModify)
    {
        return ;
    }
    picOt --;
    if(picOt<0)
    {
        picOt = 3;
    }
    if(typeMode==0)
    {
        [imageViewCrop removeFromSuperview];
    }else
    {
        [imageView removeFromSuperview];
    }
    [self setImageView];
        
    
}

//保存旋转后的图片到Image文件夹
-(void)SaveImageToFile:(UIImage *)image
{
    if(!image)
    {
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dic = [NSHomeDirectory() stringByAppendingString:@"/Documents/picture/"];
    
    BOOL isDic;
    if(![fileManager fileExistsAtPath:dic isDirectory:&isDic]||(!isDic))
    {
        [fileManager createDirectoryAtPath:dic withIntermediateDirectories:YES attributes:nil error:nil];
    }
//    NSLog(@"path:%@",imgPath);
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
//    if([fileManager fileExistsAtPath:imgPath])
//    {
//        [fileManager removeItemAtPath:imgPath error:nil];
//    }
    if(imageData)
    {
        [fileManager createFileAtPath:imgPath contents:imageData attributes:nil];
        NSLog(@"imgPath: %@",imgPath);
        imageData = nil;
    }
}

//直接返回
-(void)Back:(UIButton*) sender
{
    UIImage *newImage = nil;
    switch (picOt) {
        case 0:
            newImage = topImagePic;
            break;
        case 1:
            newImage = leftImagePic;
            break;
        case 2:
            newImage = bottomImagePic;
            break;
        case 3:
            newImage = rightImagePic;
            break;
        default:
            break;
    }
    if(typeMode==0)
    {
        newImage = [imageViewCrop getCroppedImage];
    }else if(newImage)
    {
        if(picOt!=0)
        {
            [self SaveImageToFile:newImage];
        }
    }
    if(imageViewCrop)
    {
        [imageViewCrop releaseAll];
        [imageViewCrop removeFromSuperview];
        imageViewCrop = nil;
    }
    if(imageView)
    {
        [imageView removeFromSuperview];
        imageView = nil;
    }
    if(delegate)
        [delegate RemoveView];
}

//保存当前的图片，返回
-(void)SaveAndBack:(UIButton*) sender
{
    sender.enabled=NO;
    UIImage *newImage = nil;
    switch (picOt) {
        case 0:
            newImage = topImagePic;
            break;
        case 1:
            newImage = leftImagePic;
            break;
        case 2:
            newImage = bottomImagePic;
            break;
        case 3:
            newImage = rightImagePic;
            break;
        default:
            break;
    }
    if(typeMode==0)
    {
        newImage = [imageViewCrop getCroppedImage];
    }
    if(newImage)
    {
        [self SaveImageToFile:newImage];
    }
    if(imageViewCrop)
    {
        [imageViewCrop releaseAll];
        [imageViewCrop removeFromSuperview];
        imageViewCrop = nil;
    }
    if(imageView)
    {
        [imageView removeFromSuperview];
        imageView = nil;
    }
    [delegate RemoveView];
}
//删除图片，返回
-(void)DeleteAndBack:(UIButton*) sender
{
    sender.enabled=NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:imgPath])
    {
        [fileManager removeItemAtPath:imgPath error:nil];
    }
    if(imageViewCrop)
    {
        [imageViewCrop releaseAll];
        [imageViewCrop removeFromSuperview];
        imageViewCrop = nil;
    }
    if(imageView)
    {
        [imageView removeFromSuperview];
        imageView = nil;
    }
    [delegate RemoveView];
}

@end
