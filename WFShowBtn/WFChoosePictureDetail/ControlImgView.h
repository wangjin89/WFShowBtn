//
//  ModifyImgView.h
//  YJTypicalMistake
//
//  Created by edutech on 15-3-4.
//  Copyright (c) 2015年 WF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BJImageCropper.h"
@protocol RemoveModifyView

-(void) RemoveView;

@end

@interface ControlImgView : UIView
{
    UIButton *leftButton;
    UIButton *rightButton;
    UIButton *leftTurnButton;
    UIButton *rightTurnButton;
    int typeMode;
    NSString *imgPath;
    BJImageCropper *imageViewCrop;
    UIImageView *imageView;
    UIImage *imageModify;
    UIImage *topImagePic;
    UIImage *leftImagePic;
    UIImage *bottomImagePic;
    UIImage *rightImagePic;
    int picOt;
    int originalOption;
}
@property(assign,nonatomic) id<RemoveModifyView> delegate;
-(id)init:(int) type Path:(NSString *) path Rect:(CGRect)rect;
@end
