//
//  ZBMessageInputView.m
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-10.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import "ZBMessageInputView.h"
#import "NSString+Message.h"
#import "EUtility.h"
#import "ChatKeyboardData.h"

@interface ZBMessageInputView()<UITextViewDelegate>

@property (nonatomic, strong, readwrite) ZBMessageTextView *messageInputTextView;

@property (nonatomic, strong, readwrite) UIButton *voiceChangeButton;

@property (nonatomic, strong, readwrite) UIButton *multiMediaSendButton;

@property (nonatomic, strong, readwrite) UIButton *faceSendButton;

@property (nonatomic, strong, readwrite) UIButton *holdDownButton;

@property (nonatomic, copy) NSString *inputedText;


@end

@implementation ZBMessageInputView

- (void)dealloc {
    
    _messageInputTextView.delegate = nil;
    _messageInputTextView = nil;
    _voiceChangeButton = nil;
    _multiMediaSendButton = nil;
    _faceSendButton = nil;
    _holdDownButton = nil;

}

#pragma mark - Action
- (void)uex_change:(BOOL)isAudio {
    if(!isAudio) {
        return;
    }
    self.faceSendButton.selected = NO;
    self.voiceChangeButton.selected=YES;
    self.multiMediaSendButton.selected = NO;
    [self.messageInputTextView resignFirstResponder];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.holdDownButton.hidden = NO;
        self.messageInputTextView.hidden = YES;
    } completion:^(BOOL finished) {
        
    }];
    
    if ([self.delegate respondsToSelector:@selector(didChangeSendVoiceAction:)]) {
        [self.delegate didChangeSendVoiceAction:YES];
    }

}

- (void)messageStyleButtonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
        {
            self.faceSendButton.selected = NO;
            self.multiMediaSendButton.selected = NO;
            sender.selected = !sender.selected;
            
            if (sender.selected) {
                
                [self.messageInputTextView resignFirstResponder];
                
            } else {
                
                [self.messageInputTextView becomeFirstResponder];
            }
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.holdDownButton.hidden = !sender.selected;
                self.messageInputTextView.hidden = sender.selected;
            } completion:^(BOOL finished) {
                
            }];
            
            if ([self.delegate respondsToSelector:@selector(didChangeSendVoiceAction:)]) {
                [self.delegate didChangeSendVoiceAction:sender.selected];
            }
        }
            break;
        case 1:
        {
            self.multiMediaSendButton.selected = NO;
            self.voiceChangeButton.selected = NO;
            
            if(self.isKeyBoardShow){
                sender.selected = !sender.selected;
            } else {
                sender.selected=YES;
                
            }
            if (sender.selected) {
                
                [self.messageInputTextView resignFirstResponder];
            } else {
                
                [self.messageInputTextView becomeFirstResponder];
            }
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.holdDownButton.hidden = YES;
                self.messageInputTextView.hidden = NO;
            } completion:^(BOOL finished) {
                
            }];
            
            if ([self.delegate respondsToSelector:@selector(didSendFaceAction:)]) {
                [self.delegate didSendFaceAction:sender.selected];
            }
        }
            break;
        case 2:
        {
            self.voiceChangeButton.selected = NO;
            self.faceSendButton.selected = NO;
            
            if(self.isKeyBoardShow) {
                sender.selected = !sender.selected;
            } else {
                sender.selected=YES;
                
            }
            
            if (sender.selected) {
                
                [self.messageInputTextView resignFirstResponder];
            } else {
                
                [self.messageInputTextView becomeFirstResponder];
            }

            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.holdDownButton.hidden = YES;
                self.messageInputTextView.hidden = NO;
            } completion:^(BOOL finished) {
                
            }];
            
            if ([self.delegate respondsToSelector:@selector(didSelectedMultipleMediaAction:)]) {
                [self.delegate didSelectedMultipleMediaAction:sender.selected];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark -语音功能
- (void)holdDownButtonTouchDown {
    if ([self.delegate respondsToSelector:@selector(didStartRecordingVoiceAction)]) {
        [self.delegate didStartRecordingVoiceAction];
    }
}

- (void)holdDownButtonTouchUpOutside {
    if ([self.delegate respondsToSelector:@selector(didCancelRecordingVoiceAction)]) {
        [self.delegate didCancelRecordingVoiceAction];
    }
}

- (void)holdDownButtonTouchUpInside {
    if ([self.delegate respondsToSelector:@selector(didFinishRecoingVoiceAction)]) {
        [self.delegate didFinishRecoingVoiceAction];
    }
}

- (void)holdDownButtonTouchDragOutside {
    if ([self.delegate respondsToSelector:@selector(willCancelRecordingVoiceAction)]) {
        [self.delegate willCancelRecordingVoiceAction];
    }
}

- (void)holdDownButtonTouchDragInside {
    if ([self.delegate respondsToSelector:@selector(stopCancelRecordingVoiceAction)]) {
        [self.delegate stopCancelRecordingVoiceAction];
    }
}

#pragma end

#pragma mark - 添加控件
- (void)setupMessageInputViewBarWithStyle:(ZBMessageInputViewStyle )style {
    
    ChatKeyboardData *chatKeyboardData = [ChatKeyboardData sharedChatKeyboardData];
    
    UIImage *keyboardButtonImg;
    if (chatKeyboardData.keyboardBtnImg && [chatKeyboardData.keyboardBtnImg length] > 0) {
        keyboardButtonImg = [UIImage imageWithContentsOfFile:chatKeyboardData.keyboardBtnImg];
    } else {
        keyboardButtonImg = [UIImage imageWithContentsOfFile:[UEX_PLUGIN_BUNDLE pathForResource:@"messageInputViewResource/ToolViewKeyboard_ios7@2x" ofType:@"png"]];
    }
    
    
    // 配置输入工具条的样式和布局
    
    // 水平间隔
    CGFloat horizontalPadding = 8;
    
    // 垂直间隔
    CGFloat verticalPadding = 5;
    
    // 按钮长,宽
    CGFloat buttonSize = [ZBMessageInputView textViewLineHeight];
    
    //语音按钮 tag = 0
    UIImage *voiceChangeButtonImg;
    if (chatKeyboardData.voiceBtnImg && [chatKeyboardData.voiceBtnImg length] > 0) {
        voiceChangeButtonImg = [UIImage imageWithContentsOfFile:chatKeyboardData.voiceBtnImg];
    } else {
        voiceChangeButtonImg = [UIImage imageWithContentsOfFile:[UEX_PLUGIN_BUNDLE pathForResource:@"messageInputViewResource/ToolViewInputVoice_ios7@2x" ofType:@"png"]];
    }
    
    
    self.voiceChangeButton = [self createButtonWithImage:voiceChangeButtonImg HLImage:nil];
    [self.voiceChangeButton setImage:keyboardButtonImg forState:UIControlStateSelected];
    
    [self.voiceChangeButton addTarget:self
                               action:@selector(messageStyleButtonClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
    self.voiceChangeButton.tag = 0;
    
    [self addSubview:self.voiceChangeButton];
    self.voiceChangeButton.frame = CGRectMake(horizontalPadding,verticalPadding,buttonSize,buttonSize);
    
    
    //更多按钮 tag = 2
    UIImage *multiMediaSendButtonImg;
    if (chatKeyboardData.selectorBtnImg && [chatKeyboardData.selectorBtnImg length] > 0) {
        multiMediaSendButtonImg = [UIImage imageWithContentsOfFile:chatKeyboardData.selectorBtnImg];
    } else {
        multiMediaSendButtonImg = [UIImage imageWithContentsOfFile:[UEX_PLUGIN_BUNDLE pathForResource:@"messageInputViewResource/TypeSelectorBtn_Black_ios7@2x" ofType:@"png"]];
    }
    
    
    self.multiMediaSendButton = [self createButtonWithImage:multiMediaSendButtonImg HLImage:nil];
    
    [self.multiMediaSendButton addTarget:self
                                  action:@selector(messageStyleButtonClicked:)
                        forControlEvents:UIControlEventTouchUpInside];
    self.multiMediaSendButton.tag = 2;
    [self addSubview:self.multiMediaSendButton];
    self.multiMediaSendButton.frame = CGRectMake(self.frame.size.width - horizontalPadding - buttonSize,
                                                 verticalPadding,
                                                 buttonSize,
                                                 buttonSize);
    
    //表情按钮 tag = 1
    UIImage *faceSendButtonImg;
    if (chatKeyboardData.emotionBtnImg && [chatKeyboardData.emotionBtnImg length] > 0) {
        faceSendButtonImg = [UIImage imageWithContentsOfFile:chatKeyboardData.emotionBtnImg];
    } else {
        faceSendButtonImg = [UIImage imageWithContentsOfFile:[UEX_PLUGIN_BUNDLE pathForResource:@"messageInputViewResource/ToolViewEmotion_ios7@2x" ofType:@"png"]];
    }
    
    self.faceSendButton = [self createButtonWithImage:faceSendButtonImg HLImage:nil];
    [self.faceSendButton setImage:keyboardButtonImg forState:UIControlStateSelected];
    
    [self.faceSendButton addTarget:self
                            action:@selector(messageStyleButtonClicked:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    self.faceSendButton.tag = 1;
    [self addSubview:self.faceSendButton];
    self.faceSendButton.frame = CGRectMake(self.frame.size.width - 2*buttonSize- horizontalPadding -5,verticalPadding,buttonSize,buttonSize);
    
    
    // 如果是可以发送语言的，那就需要一个按钮录音的按钮，事件可以在外部添加
    UIImage * normalImg = [UIImage imageWithContentsOfFile:[UEX_PLUGIN_BUNDLE pathForResource:@"voiceResource/holdDownButton@2x" ofType:@"png"]];
    //UIImage * hightLightImg = [UIImage imageNamed:@"uexChatKeyboard/voiceResource/holdupButton"];

    if (chatKeyboardData.recorderBgColor) {
        self.holdDownButton = [self createButtonWithColor:chatKeyboardData.recorderBgColor];
    } else {
        self.holdDownButton = [self createButtonWithImage:normalImg HLImage:normalImg];
    }
    
    
    [self.holdDownButton setTitle:chatKeyboardData.recorderNormalTitle forState:UIControlStateNormal];
    [self.holdDownButton setTitle:chatKeyboardData.recorderHighlightedTitle forState:UIControlStateHighlighted];
    [self.holdDownButton setTitleColor:chatKeyboardData.recorderNormalTitleColor forState:UIControlStateNormal];
    [self.holdDownButton setTitleColor:chatKeyboardData.recorderHighlightedTitleColor forState:UIControlStateHighlighted];
    [self.holdDownButton addTarget:self action:@selector(holdDownButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.holdDownButton addTarget:self action:@selector(holdDownButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self.holdDownButton addTarget:self action:@selector(holdDownButtonTouchUpOutside) forControlEvents:UIControlEventTouchCancel];
    [self.holdDownButton addTarget:self action:@selector(holdDownButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self.holdDownButton addTarget:self action:@selector(holdDownButtonTouchDragOutside) forControlEvents:UIControlEventTouchDragOutside];
    [self.holdDownButton addTarget:self action:@selector(holdDownButtonTouchDragInside) forControlEvents:UIControlEventTouchDragInside];
    [self addSubview:self.holdDownButton];
    self.holdDownButton.hidden = !self.voiceChangeButton.selected;
    
    
    // 初始化输入框
    ZBMessageTextView *textView = [[ZBMessageTextView alloc] initWithFrame:CGRectZero];
    textView.returnKeyType = UIReturnKeySend;
    textView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    textView.placeHolder = [ChatKeyboardData sharedChatKeyboardData].placeHolder;
    textView.delegate = self;
    
    [self addSubview:textView];
	self.messageInputTextView = textView;
    
    // 配置不同iOS SDK版本的样式
    switch (style)
    {
        case ZBMessageInputViewStyleQuasiphysical:
        {
            self.holdDownButton.frame = CGRectMake(horizontalPadding + buttonSize +5.0f,
                                                     3.0f,
                                                     CGRectGetWidth(self.bounds)- 3*buttonSize -2*horizontalPadding- 15.0f,
                                                     buttonSize);
            
            if (chatKeyboardData.inputBgColor) {
                _messageInputTextView.backgroundColor = chatKeyboardData.inputBgColor;
            } else {
                _messageInputTextView.backgroundColor = [UIColor whiteColor];
            }
            break;
        }
        case ZBMessageInputViewStyleDefault:
        {
            self.holdDownButton.frame = CGRectMake(horizontalPadding + buttonSize +5.0f,4.5f,CGRectGetWidth(self.bounds)- 3*buttonSize -2*horizontalPadding- 15.0f,buttonSize);
            
            if (chatKeyboardData.inputBgColor) {
                _messageInputTextView.backgroundColor = chatKeyboardData.inputBgColor;
            } else {
                _messageInputTextView.backgroundColor = [UIColor clearColor];
            }
            break;
        }
        default:
            break;
    }
    
    if (chatKeyboardData.isRound) {
        self.messageInputTextView.layer.cornerRadius = 6.0f;
        self.holdDownButton.layer.cornerRadius = 6.0f;
    }
    
    
    self.messageInputTextView.frame = self.holdDownButton.frame;

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - layout subViews UI
- (UIButton *)createButtonWithImage:(UIImage *)image HLImage:(UIImage *)hlImage {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [ZBMessageInputView textViewLineHeight], [ZBMessageInputView textViewLineHeight])];
    if (image) {
        [button setBackgroundImage:image forState:UIControlStateNormal];
    }
    if (hlImage) {
        [button setBackgroundImage:hlImage forState:UIControlStateHighlighted];
    }
    return button;
}
- (UIButton *)createButtonWithColor:(UIColor *)color {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [ZBMessageInputView textViewLineHeight], [ZBMessageInputView textViewLineHeight])];
    if (color) {
        [button setBackgroundColor:color];
    }
    return button;
}
#pragma end

#pragma mark - Message input view

- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight {
    // 动态改变自身的高度和输入框的高度
    
    CGRect prevFrame = self.messageInputTextView.frame;
    
    NSUInteger numLines = MAX([self.messageInputTextView numberOfLinesOfText],
                              [self.messageInputTextView.text numberOfLines]);//
    
    self.messageInputTextView.frame = CGRectMake(prevFrame.origin.x,
                                          prevFrame.origin.y,
                                          prevFrame.size.width,
                                          prevFrame.size.height + changeInHeight);
    

    self.messageInputTextView.contentInset = UIEdgeInsetsMake((numLines >= 6 ? 4.0f : 0.0f), 0.0f, (numLines >= 6 ? 4.0f : 0.0f), 0.0f);
    
    // from iOS 7, the content size will be accurate only if the scrolling is enabled.
    self.messageInputTextView.scrollEnabled = YES;
    CGPoint bottomOffset = CGPointZero;
    if (numLines >= 6) {
        bottomOffset = CGPointMake(0.0f, self.messageInputTextView.contentSize.height - self.messageInputTextView.bounds.size.height);
        [self.messageInputTextView scrollRangeToVisible:NSMakeRange(self.messageInputTextView.text.length - 2, 1)];
    }
    [self.messageInputTextView setContentOffset:bottomOffset animated:YES];
}

+ (CGFloat)textViewLineHeight {
    return 36.0f ;// 字体大小为16
}

+ (CGFloat)maxHeight {
    return ([ZBMessageInputView maxLines] + 1.0f) * [ZBMessageInputView textViewLineHeight];
}

+ (CGFloat)maxLines {
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 3.0f : 8.0f;
}
#pragma end

- (void)setup {
    ChatKeyboardData *chatKeyboardData = [ChatKeyboardData sharedChatKeyboardData];
    // 配置自适应
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    // 由于继承UIImageView，所以需要这个属性设置
    self.userInteractionEnabled = YES;
    
    if ([[[UIDevice currentDevice]systemVersion]floatValue]>=7 ) {
        _messageInputViewStyle = ZBMessageInputViewStyleDefault;
        
        
        if (chatKeyboardData.chatKeyboardBgColor) {
            self.backgroundColor = chatKeyboardData.chatKeyboardBgColor;
        } else {
            self.image = [[UIImage imageWithContentsOfFile:[UEX_PLUGIN_BUNDLE pathForResource:@"messageInputViewResource/input-bar-flat@2x" ofType:@"png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f) resizingMode:UIImageResizingModeStretch];
        }
        
        
        
    } else {
        
        _messageInputViewStyle = ZBMessageInputViewStyleQuasiphysical;
        if ([[[UIDevice currentDevice]systemVersion]floatValue]>=6 ) {
        self.image = [[UIImage imageWithContentsOfFile:[UEX_PLUGIN_BUNDLE pathForResource:@"messageInputViewResource/input-bar-background@2x" ofType:@"png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(19.0f, 3.0f, 19.0f, 3.0f) resizingMode:UIImageResizingModeStretch];
        } else {
            self.image = [[UIImage imageWithContentsOfFile:[UEX_PLUGIN_BUNDLE pathForResource:@"messageInputViewResource/input-bar-background@2x" ofType:@"png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(19.0f, 3.0f, 19.0f, 3.0f)];
        }
        
    }
    [self setupMessageInputViewBarWithStyle:_messageInputViewStyle];
}

#pragma mark - textViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
   
    if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)]) {
        [self.delegate inputTextViewWillBeginEditing:self.messageInputTextView];
    }
    self.faceSendButton.selected = NO;
    self.multiMediaSendButton.selected = NO;
   
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidChange:)]) {
        [self.delegate inputTextViewDidChange:self.messageInputTextView];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [textView becomeFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidBeginEditing:)]) {
        [self.delegate inputTextViewDidBeginEditing:self.messageInputTextView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {

    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didSendTextAction:)]) {
            [self.delegate didSendTextAction:self.messageInputTextView];
        }
        return NO;
    }
    return YES;
}
#pragma end

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
