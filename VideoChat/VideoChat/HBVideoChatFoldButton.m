//
//  HBVideoChatFoldButton.m
//  SuperFastDoctor
//
//  Created by apple on 16/8/10.
//  Copyright © 2016年 LouisHors. All rights reserved.
//

#import "HBVideoChatFoldButton.h"

@implementation HBVideoChatFoldButton

@synthesize otherButtons;
BOOL isOK;
CGRect rectFrame;
//buttonClickBlock ButtonBlock;
-(instancetype)initWithFrame:(CGRect)frame mainButtonBGImage:(NSString*)imag selectBGImage:(NSString*)selectBGImageStr otherButtonsBGimages:(NSArray<NSString*>*)otherButtonsBGimages
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame =frame;
        rectFrame =frame;
        //        self.backgroundColor = [UIColor redColor];
        
        self.image =imag;
        self.selectBGImage = selectBGImageStr;
        self.otherButtonsBGimages_Array = otherButtonsBGimages;
        self.SpaceDistance = 10;
        [self layoutAddViewBy:self];
        UIButton *mainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        mainBtn.frame = self.bounds;
        mainBtn.tag =0;
        [mainBtn setBackgroundImage:[UIImage imageNamed:imag] forState:0];
        mainBtn.layer.cornerRadius = CGRectGetWidth(frame)/2;
        self.layer.cornerRadius = CGRectGetWidth(frame)/2;
        //        self.clipsToBounds = YES;
        [mainBtn addTarget:self action:@selector(buttonClick:) forControlEvents:5];
        
        
        mainBtn.selected =0;
        [self addSubview:mainBtn];
        self.mainButton =mainBtn;
    }
    return self;
}
-(void)buttonClick:(UIButton*)button
{
    [self setAnimation];
    if (button.tag==0) {
        NSString *string = button.selected==0 ? self.image : self.selectBGImage;
        [button setBackgroundImage:[UIImage imageNamed:string] forState:0];
    }
    
    if (self.ButtonClickBlock) {
        self.ButtonClickBlock(button);
    }
    
    
}


-(void)setAnimation
{
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:10 options:UIViewAnimationOptionLayoutSubviews animations:^{
        
        self.mainButton.selected ==1 ? [self back]:[self move];
    } completion:^(BOOL finished) {
        
    }];
    self.mainButton.selected =!self.mainButton.selected;
}
-(void)move
{
    for (int i=0; i<otherButtons.count; i++)
    {
        UIButton *button = otherButtons[i];
        CGRect rect = button.frame;
        CGRect bounds = self.frame;
        rect.origin.y = self.SpaceDistance+CGRectGetHeight(rect)+rect.origin.y+i*(CGRectGetHeight(rect)+self.SpaceDistance);
        bounds.size.height = (otherButtons.count+1)*CGRectGetHeight(self.mainButton.frame)+self.SpaceDistance*otherButtons.count;
        button.frame = rect;
        self.frame = bounds;
    }
}

-(void)back
{
    for (int i=0; i<otherButtons.count; i++) {
        UIButton *button = otherButtons[i];
        button.frame =self.mainButton.bounds;
        self.frame = rectFrame;
    }
}

-(void)layoutAddViewBy:(UIView*)view
{
    self.otherButtons = [[NSMutableArray alloc] init];
    for (int i=0; i<self.otherButtonsBGimages_Array.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame =self.bounds;
        button.tag = 1+i;
        [button setBackgroundImage:[UIImage imageNamed:self.otherButtonsBGimages_Array[i]] forState:0];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:5];
        [view addSubview:button];
        [self.otherButtons addObject:button];
    }
}


@end
