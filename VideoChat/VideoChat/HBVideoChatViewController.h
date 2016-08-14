//
//  HBVideoChatViewController.h
//  视频聊天
//
//  Created by apple on 16/8/9.
//  Copyright © 2016年 yhb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBVideoChatViewController : UIViewController
/**
 *  创建视频聊天播放器
 *
 *  @param IPAddress  两个人共同所在的区域网
 *  @param myRoom     我的推流后缀地址(随便写,只要与别人的othersRoom相同即可)
 *  @param othersRoom 别人的推流地址
 *
 */
- (instancetype)initWithIPAddress:(NSString *)ipAddress MyRoom:(NSString *)myRoom othersRoom:(NSString *)othersRoom;
@end
