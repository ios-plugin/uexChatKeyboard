//
//  ChatKeyboardData.h
//  EUExChatKeyboard
//
//  Created by xurigan on 15/3/9.
//  Copyright (c) 2015年 com.zywx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ChatKeyboardData : NSObject

@property (nonatomic,strong) NSArray * faceImgArray;
@property (nonatomic,strong) NSArray * shareImgArray;
@property (nonatomic,strong) NSArray * faceArray;
@property (nonatomic,strong) NSArray * shareArray;
@property (nonatomic,strong) NSString * sharePath;
@property (nonatomic,strong) NSString * facePath;
@property (nonatomic,strong) NSString * deleteImg;
@property (nonatomic,strong) NSString * pageNum;
@property (nonatomic,strong) NSString * placeHolder;

@property (nonatomic,strong) NSString * touchDownImg;
@property (nonatomic,strong) NSString * dragOutsideImg;
@property (nonatomic,strong) UIColor * textColor;
@property (nonatomic,assign) float textSize;

@property (nonatomic,strong) UIColor * sendBtnbgColorUp;
@property (nonatomic,strong) UIColor * sendBtnbgColorDown;
@property (nonatomic,copy) NSString * sendBtnText;
@property (nonatomic,assign) float sendBtnTextSize;
@property (nonatomic,strong) UIColor * sendBtnTextColor;

@property (nonatomic, copy) NSString *keyboardBtnImg;
@property (nonatomic, copy) NSString *voiceBtnImg;
@property (nonatomic, copy) NSString *emotionBtnImg;
@property (nonatomic, copy) NSString *selectorBtnImg;

@property (nonatomic, copy) NSString *recorderNormalTitle;
@property (nonatomic, copy) NSString *recorderHighlightedTitle;
@property (nonatomic, strong) UIColor *recorderNormalTitleColor;
@property (nonatomic, strong) UIColor *recorderHighlightedTitleColor;
@property (nonatomic, strong) UIColor *recorderBgColor;
@property (nonatomic) BOOL isRound;
@property (nonatomic, strong) UIColor *faceViewBgColor;
@property (nonatomic, strong) UIColor *shareViewBgColor;

@property (nonatomic, strong) UIColor *chatKeyboardBgColor;
@property (nonatomic, strong) UIColor *inputBgColor;

+(ChatKeyboardData *)sharedChatKeyboardData;

@end
