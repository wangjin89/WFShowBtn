//
//  BJImageCropper.m
//  CropTest
//
//  Created by Barrett Jacobsen on 6/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BJImageCropper.h"
#import <QuartzCore/QuartzCore.h>

#ifndef CGWidth
#define CGWidth(rect)                   rect.size.width
#endif

#ifndef CGHeight
#define CGHeight(rect)                  rect.size.height
#endif

#ifndef CGOriginX
#define CGOriginX(rect)                 rect.origin.x
#endif

#ifndef CGOriginY
#define CGOriginY(rect)                 rect.origin.y
#endif

@implementation BJImageCropper
@dynamic crop;
@dynamic image;
@dynamic unscaledCrop;
@synthesize imageView;

- (UIImage*)image {
    return imageView.image;
}

- (void)setImage:(UIImage *)image {
    imageView.image = image;
}

- (void)constrainCropToImage {
    CGRect frame = cropView.frame;
    
    if (CGRectEqualToRect(frame, CGRectZero)) return;
    
    BOOL change = NO;
    
//    do {
        change = NO;
        
        if (CGOriginX(frame) < 0) {
            frame.origin.x = 0;
            change = YES;
        }
        
        if (CGWidth(frame) > CGWidth(cropView.superview.frame)) {
            frame.size.width = CGWidth(cropView.superview.frame);
            change = YES;
        }
        
        if (CGWidth(frame) < 20) {
            frame.size.width = 20;
            change = YES;
        }
        
        if (CGOriginX(frame) + CGWidth(frame) > CGWidth(cropView.superview.frame)) {
            frame.origin.x = CGWidth(cropView.superview.frame) - CGWidth(frame);
            change = YES;
        }
        
        if (CGOriginY(frame) < 0) {
            frame.origin.y = 0;
            change = YES;
        }
        
        if (CGHeight(frame) > CGHeight(cropView.superview.frame)) {
            frame.size.height = CGHeight(cropView.superview.frame);
            change = YES;
        }
        
        if (CGHeight(frame) < 20) {
            frame.size.height = 20;
            change = YES;
        }
        
        if (CGOriginY(frame) + CGHeight(frame) > CGHeight(cropView.superview.frame)) {
            frame.origin.y = CGHeight(cropView.superview.frame) - CGHeight(frame);
            change = YES;
        }
//    } while (change);
        
    cropView.frame = frame;
}

- (void)updateBounds {
    [self constrainCropToImage];
    
}

- (CGRect)crop {
    CGRect frame = cropView.frame;
    
    if (frame.origin.x <= 0)
        frame.origin.x = 0;

    if (frame.origin.y <= 0)
        frame.origin.y = 0;
    return CGRectMake(frame.origin.x / imageScale, frame.origin.y / imageScale, frame.size.width / imageScale, frame.size.height / imageScale);;
}

- (void)setCrop:(CGRect)crop {
    cropView.frame = CGRectMake(crop.origin.x * imageScale, crop.origin.y * imageScale, crop.size.width * imageScale, crop.size.height * imageScale);
    [self updateBounds];
}

- (CGRect)unscaledCrop {
    CGRect crop = self.crop;
    return CGRectMake(crop.origin.x * imageScale, crop.origin.y * imageScale, crop.size.width * imageScale, crop.size.height * imageScale);
}

- (UIView*)newEdgeView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.5;
    
    [self.imageView addSubview:view];
    
    return view;
}

- (UIView*)newCornerView {
    UIView *view = [self newEdgeView];
    view.alpha = 0.75;
    
    return view;
}

- (UIView *)initialCropViewForImageView:(UIImageView*)imageV {
    // 3/4 the size, centered
    
    CGRect max = imageView.bounds;

    CGFloat width  = CGWidth(max) / 4 * 3;
    CGFloat height = CGHeight(max) / 4 * 3;
    CGFloat x      = (CGWidth(max) - width) / 2;
    CGFloat y      = (CGHeight(max) - height) / 2;
    
    cropView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    cropView.layer.borderColor = [[UIColor colorWithRed:21/255.0 green:155/255.0 blue:185/255.0 alpha:1.0] CGColor];
    cropView.layer.borderWidth = 2.0;
    cropView.backgroundColor = [UIColor clearColor];
    cropView.alpha = 0.8;
    
#ifdef ARC
    return cropView;
#else
    return [cropView autorelease];
#endif
}

- (void)setup {
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
    self.backgroundColor = [UIColor clearColor];

    cropView = [self initialCropViewForImageView:imageView];
    [self.imageView addSubview:cropView];
//    NSLog(@"width:%f,height:%f",self.imageView.frame.size.width,self.imageView.frame.size.height);
   
#ifndef ARC
    [cropView retain];
#endif
    
    [self updateBounds];
}

- (CGRect)calcFrameWithImage:(UIImage*)image andMaxSize:(CGSize)maxSize {
    CGFloat increase = IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE * 2;
    
    // if it already fits, return that
    CGRect noScale = CGRectMake(0.0, 0.0, image.size.width + increase, image.size.height + increase);
    if (CGWidth(noScale) <= maxSize.width && CGHeight(noScale) <= maxSize.height) {
        imageScale = 1.0;
        return noScale;
    }
    
    CGRect scaled;
    
    // first, try scaling the height to fit
    imageScale = (maxSize.height - increase) / image.size.height;
    scaled = CGRectMake(0.0, 0.0, image.size.width * imageScale + increase, image.size.height * imageScale + increase);
    if (CGWidth(scaled) <= maxSize.width && CGHeight(scaled) <= maxSize.height) {
        return scaled;
    }
    
    // scale with width if that failed
    imageScale = (maxSize.width - increase) / image.size.width;
    scaled = CGRectMake(0.0, 0.0, image.size.width * imageScale + increase, image.size.height * imageScale + increase);
    return scaled;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        imageScale = 1.0;
        imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE, IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE)];
        [self addSubview:imageView];
        [self setup];
    }
    
    return self;   
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        imageScale = 1.0;
        imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE, IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE)];
        [self addSubview:imageView];
        [self setup];
    }
    
    return self;   
}

- (id)initWithImage:(UIImage*)newImage {
    self = [super init];
    if (self) {
        imageScale = 1.0;
        imageView = [[UIImageView alloc] initWithImage:newImage];
        self.frame = CGRectInset(imageView.frame, -IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE, -IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE);
        [self addSubview:imageView];
        [self setup];
    }
    
    return self;   
}

- (id)initWithImage:(UIImage*)newImage andMaxSize:(CGSize)maxSize {
    self = [super init];
    if (self) {
        self.frame = [self calcFrameWithImage:newImage andMaxSize:maxSize];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE, IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE)];
        imageView.image = newImage;
        [self addSubview:imageView];
        [self setup];
    }
    
    return self;   
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (CGFloat)distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
    float x = toPoint.x - fromPoint.x;
    float y = toPoint.y - fromPoint.y;
    
    return sqrt(x * x + y * y);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self willChangeValueForKey:@"crop"];
    NSSet *allTouches = [event allTouches];
    
    switch ([allTouches count]) {
        case 1: {            
            currentTouches = 1;
            isPanning = NO;
            CGFloat insetAmount = IMAGE_CROPPER_INSIDE_STILL_EDGE;
            
            CGPoint touch = [[allTouches anyObject] locationInView:self.imageView];
            if (CGRectContainsPoint(CGRectInset(cropView.frame, insetAmount, insetAmount), touch)) {
                isPanning = YES;
                panTouch = touch;
                return;
            }
            FirstTouch = touch;
            CGRect frame = cropView.frame;

            
            currentDragView = nil;

            
            cropView.frame = frame;
            
            [self updateBounds];
            
            break;
        }
//        case 2: {
//            CGPoint touch1 = [[[allTouches allObjects] objectAtIndex:0] locationInView:self.imageView];
//            CGPoint touch2 = [[[allTouches allObjects] objectAtIndex:1] locationInView:self.imageView];
//
//            if (currentTouches == 0 && CGRectContainsPoint(cropView.frame, touch1) && CGRectContainsPoint(cropView.frame, touch2)) {
//                isPanning = YES;
//            }
//            
//            currentTouches = [allTouches count];
//            break;
//        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self willChangeValueForKey:@"crop"];
    NSSet *allTouches = [event allTouches];
    
    switch ([allTouches count])
    {
        case 1: {
            CGPoint touch = [[allTouches anyObject] locationInView:self.imageView];

            if (isPanning) {
                CGPoint touchCurrent = [[allTouches anyObject] locationInView:self.imageView];
                CGFloat x = touchCurrent.x - panTouch.x;
                CGFloat y = touchCurrent.y - panTouch.y;
                
                cropView.center = CGPointMake(cropView.center.x + x, cropView.center.y + y);
                                
                panTouch = touchCurrent;
            }
            else if ((CGRectContainsPoint(self.bounds, touch))) {
                CGRect frame = cropView.frame;
                CGFloat x = touch.x;
                CGFloat y = touch.y;
                BOOL moved = false;
                if (x > self.imageView.frame.size.width-IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE)
                    x = self.imageView.frame.size.width-IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE;

                if (y > self.imageView.frame.size.height-IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE)
                    y = self.imageView.frame.size.height-IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE;
                CGFloat fx = FirstTouch.x;
                CGFloat fy = FirstTouch.y;
                
                if(y<frame.origin.y)
                {
                    frame.size.height +=  fy - y ;
                    frame.origin.y += y - fy;
                    if(frame.origin.y<=0)
                    {
                        frame.origin.y = 0;
                    }
                    moved = true;
//                    NSLog(@"originY:%f,%f,%f,%f",frame.origin.y,fy,y,frame.size.height);
                }else if((y>frame.origin.y)&&(y<(frame.origin.y+frame.size.height/2)))
                {
                    frame.size.height +=  fy - y ;
                    frame.origin.y += y - fy;
                    if(frame.origin.y>=self.imageView.frame.size.height-10)
                    {
                        frame.origin.y = self.imageView.frame.size.height-10;
                    }
//                    NSLog(@"fY:%f,%f,%f,%f",frame.origin.y,fy,y,frame.size.height);
                }else
                {
                    if(fy>=self.imageView.frame.size.height-10)
                    {
                        frame.size.height += fy - y;
                    }else
                    {
                        frame.size.height += y - fy;
                    }
                    if(frame.size.height>self.imageView.frame.size.height-frame.origin.y)
                    {
                        frame.size.height = self.imageView.frame.size.height-frame.origin.y;
                    }
//                    NSLog(@"Y:%f,%f,%f,%f",frame.origin.y,fy,y,frame.size.height);

                }
                if(x<frame.origin.x)
                {
                    frame.size.width +=  fx - x ;
                    frame.origin.x += x -fx;
//                    NSLog(@"originX:%f,%f,%f,%f",frame.origin.x,fx,x,frame.size.width);
                    if(frame.origin.y<=0)
                    {
                        frame.origin.y = 0;
                    }

                }else if((x>frame.origin.x)&&(x<(frame.origin.x+frame.size.width/2)))
                {
                    frame.size.width +=  fx - x ;
                    frame.origin.x += x - fx;
                    if(frame.origin.x>self.imageView.frame.size.width-10)
                    {
                        frame.origin.x = self.imageView.frame.size.width-10;
                    }
//                    NSLog(@"fx:%f,%f,%f,%f",frame.origin.x,fx,x,frame.size.width);

                }else
                {
                    if(fx>self.imageView.frame.size.width-10)
                    {
                        frame.size.width += fx - x;
                    }else
                    {
                        frame.size.width += x - fx;
                    }
                    if(frame.size.width>self.imageView.frame.size.width-frame.origin.x)
                    {
                        frame.size.width = self.imageView.frame.size.width-frame.origin.x;
                    }
//                    NSLog(@"x:%f,%f,%f,%f",frame.origin.x,fx,x,frame.size.width);

                }
                if (x > self.imageView.frame.size.width-IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE)
                    x = self.imageView.frame.size.width-IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE;
                
                if (y > self.imageView.frame.size.height-IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE)
                    y = self.imageView.frame.size.height-IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE;
                FirstTouch = touch;
                cropView.frame = frame;
            }
        } break;
//        case 2: {
//            CGPoint touch1 = [[[allTouches allObjects] objectAtIndex:0] locationInView:self.imageView];
//            CGPoint touch2 = [[[allTouches allObjects] objectAtIndex:1] locationInView:self.imageView];
//            
//            if (isPanning) {
//                CGFloat distance = [self distanceBetweenTwoPoints:touch1 toPoint:touch2];
//                
//                if (scaleDistance != 0) {
//                    CGFloat scale = 1.0f + ((distance-scaleDistance)/scaleDistance);
//                    
//                    CGPoint originalCenter = cropView.center;
//                    CGSize originalSize = cropView.frame.size;
//                    
//                    CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
//
//                    if (newSize.width >= 50 && newSize.height >= 50 && newSize.width <= CGWidth(cropView.superview.frame) && newSize.height <= CGHeight(cropView.superview.frame)) {
//                        cropView.frame = CGRectMake(0, 0, newSize.width, newSize.height);
//                        cropView.center = originalCenter;
//                    }
//                }
//                
//                scaleDistance = distance;
//            }
//
//        } break;
    }
    
    [self updateBounds];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    scaleDistance = 0;
    currentTouches = [[event allTouches] count];
}

- (UIImage*) getCroppedImage {
    CGRect rect = self.crop;
    float scaleX = self.image.size.width*1.0/self.imageView.frame.size.width;
    float scaleY = self.image.size.height*1.0/self.imageView.frame.size.height;
    float scale = (scaleX>scaleY)?scaleY:scaleX;
    rect = CGRectMake(rect.origin.x*scale, rect.origin.y*scale, rect.size.width*scale, rect.size.height*scale);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, self.image.size.width, self.image.size.height);
    
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // draw image
    [self.image drawInRect:drawRect];
//    CGContextDrawImage(context, rect, self.image.CGImage);
    
    // grab image
    UIImage* croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return croppedImage;
}
-(void)releaseAll
{
    if(imageView)
    {
        [imageView removeFromSuperview];
        imageView = nil;
    }
    if(cropView)
    {
        [cropView removeFromSuperview];
        cropView = nil;
    }

}
@end
