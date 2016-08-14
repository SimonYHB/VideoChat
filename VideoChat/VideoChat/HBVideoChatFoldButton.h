//
//  HBVideoChatFoldButton.h
//  SuperFastDoctor
//
//  Created by apple on 16/8/10.
//  Copyright © 2016年 LouisHors. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^buttonClickBlock)(UIButton*button);
@interface HBVideoChatFoldButton : UIView

@property(strong,nonatomic)NSMutableArray *otherButtons;


@property(strong ,nonatomic)UIButton*mainButton;
@property(strong,nonatomic)NSString *image;
@property(strong,nonatomic)NSString*selectBGImage;
@property(strong,nonatomic)NSArray<NSString*>*otherButtonsBGimages_Array;
@property(assign,nonatomic)CGFloat SpaceDistance;

@property(copy,nonatomic)buttonClickBlock ButtonClickBlock;

-(instancetype)initWithFrame:(CGRect)frame mainButtonBGImage:(NSString*)imag selectBGImage:(NSString*)selectBGImageStr otherButtonsBGimages:(NSArray<NSString*>*)otherButtonsBGimages;

@end

