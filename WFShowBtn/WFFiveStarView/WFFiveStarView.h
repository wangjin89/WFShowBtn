//
//  WFFiveStarView.h
//  WFShowBtn
//
//  Created by 王飞 on 16/10/13.
//  Copyright © 2016年 WF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WFFiveStarView : UIView
{
    NSNumber *_Score;
    BOOL _canChoose;
    
    BOOL _animation;
    
    UIImage *_starImage_Empty;
    UIImage *_starImage_Full;
}

-(NSNumber *)Score;
-(void)setScore:(NSNumber *)Score;

-(BOOL)canBeChoose;
-(void)setCanChoose:(BOOL)CanChoose;

-(BOOL)animation;
-(void)setAnimation:(BOOL)animation;

-(UIImage *)starImage_Full;
-(void)setStarImage_Full:(UIImage *)image;

-(UIImage *)starImage_Empty;
-(void)setStarImage_Empty:(UIImage *)image;


@end
