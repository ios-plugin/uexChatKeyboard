//
//  EUExChatKeyboard.m
//  EUExChatKeyboard
//
//  Created by xurigan on 14/12/12.
//  Copyright (c) 2014年 com.zywx. All rights reserved.
//

#import "EUExChatKeyboard.h"
#import "ChatKeyboard.h"
#import "XMLReader.h"
#import "ChatKeyboardData.h"


@interface EUExChatKeyboard()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) ChatKeyboard *chatKeyboard;
@property (nonatomic, strong) NSString *delete;
@property (nonatomic, strong) NSString *pageNum;
@property (nonatomic, strong) UITapGestureRecognizer *tapGR;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressRecognizer;

@end

@implementation EUExChatKeyboard

- (id)initWithBrwView:(EBrowserView *)eInBrwView {
    
    if (self = [super initWithBrwView:eInBrwView]) {
        //
    }
    
    return self;
    
}

- (void)clean {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_tapGR) {
        
        _tapGR.delegate = nil;
        _tapGR = nil;
    }
    
    if (_panRecognizer) {
        
        _panRecognizer.delegate = nil;
        _panRecognizer = nil;
    }
    
    if (_longPressRecognizer) {
        
        _longPressRecognizer.delegate = nil;
        _longPressRecognizer = nil;
    }
    
    if (_chatKeyboard) {
        
        [_chatKeyboard close];
        _chatKeyboard = nil;
        
    }
    
}

- (void)open:(NSMutableArray *)array {
    
    NSLog(@"AppCan --> uexChatKeyboard --> open --> inArguments = %@",array);
    
    if ([array count] < 1) {
        return;
    }
    
    NSDictionary *chatKeyboardDataDict = [[array objectAtIndex:0] JSONValue];
    
    [self setChatKeyboardDataWithDict:chatKeyboardDataDict];
    
    BOOL isAudio=NO;
    if([chatKeyboardDataDict objectForKey:@"inputMode"] && [[chatKeyboardDataDict objectForKey:@"inputMode"] integerValue] == 1){
        isAudio=YES;
    }
    
    if (!_chatKeyboard) {
        
        _chatKeyboard = [[ChatKeyboard alloc]initWithUexobj:self];
        if([chatKeyboardDataDict objectForKey:@"bottom"]) {
            _chatKeyboard.bottomOffset=[[chatKeyboardDataDict objectForKey:@"bottom"] floatValue];
        }
        id keywords = chatKeyboardDataDict[@"keywords"];
        if (keywords && [keywords isKindOfClass:[NSArray class]]) {
            _chatKeyboard.keywords = keywords;
        }
        
        [_chatKeyboard open];
        
        _tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard:)];
        
        [self.meBrwView addGestureRecognizer:_tapGR];
        
        _tapGR.delegate = self;
        
        _panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard:)];
        
        [self.meBrwView addGestureRecognizer:_panRecognizer];
        
        _panRecognizer.delegate = self;
        
        _longPressRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard:)];
        
        [self.meBrwView addGestureRecognizer:_longPressRecognizer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIApplicationWillResignActiveNotification object:nil];
        
        _longPressRecognizer.delegate = self;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(50 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            [_chatKeyboard.messageToolView uex_change:isAudio];

        });
        
    }
    
}

- (void)setChatKeyboardDataWithDict:(NSDictionary *)chatKeyboardDataDict {
    
    ChatKeyboardData *chatKeyboardData = [ChatKeyboardData sharedChatKeyboardData];
    
    NSString *xmlPath = [chatKeyboardDataDict objectForKey:@"emojicons"];
    xmlPath = [self absPath:xmlPath];
    
    NSString *sharePath = [chatKeyboardDataDict objectForKey:@"shares"];
    sharePath = [self absPath:sharePath];
    
    [self setFaceDicByFaceXMLPath:xmlPath];
    [self setShareDicFromSharePath:sharePath];
    
    NSArray *facePathArray = [xmlPath componentsSeparatedByString:@"/"];
    NSString *fileName = [facePathArray lastObject];
    NSRange range = [xmlPath rangeOfString:fileName];
    xmlPath = [xmlPath substringToIndex:range.location];
    chatKeyboardData.facePath = xmlPath;
    
    NSArray *sharePathArray = [sharePath componentsSeparatedByString:@"/"];
    NSString *shareFileName = [sharePathArray lastObject];
    NSRange range1 = [sharePath rangeOfString:shareFileName];
    sharePath = [sharePath substringToIndex:range1.location];
    chatKeyboardData.sharePath = sharePath;
    
    //设置placeHolder
    NSString *placeHolder = @"";
    if ([chatKeyboardDataDict objectForKey:@"placeHold"]) {//兼容以前的错误
        placeHolder = [chatKeyboardDataDict objectForKey:@"placeHold"];
    }
    if ([chatKeyboardDataDict objectForKey:@"placeHolder"]) {
        placeHolder = [chatKeyboardDataDict objectForKey:@"placeHolder"];
    }
    chatKeyboardData.placeHolder = placeHolder;
    
    NSString *touchDownImg = nil;
    if ([chatKeyboardDataDict objectForKey:@"touchDownImg"]) {
        touchDownImg = [self absPath:[chatKeyboardDataDict objectForKey:@"touchDownImg"]];
    }
    
    NSString *dragOutsideImg = nil;
    if ([chatKeyboardDataDict objectForKey:@"dragOutsideImg"]) {
        dragOutsideImg = [self absPath:[chatKeyboardDataDict objectForKey:@"dragOutsideImg"]];
    }
    
    UIColor *textColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0];
    if ([chatKeyboardDataDict objectForKey:@"textColor"]) {
        NSString *textColorStr = [chatKeyboardDataDict objectForKey:@"textColor"];
        textColor = [EUtility ColorFromString:textColorStr];
    }
    
    float textSize = 30.0;
    if ([chatKeyboardDataDict objectForKey:@"textSize"]) {
        textSize = [[chatKeyboardDataDict objectForKey:@"textSize"] floatValue];
    }
    
    UIColor *sendBtnbgColorUp = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    if ([chatKeyboardDataDict objectForKey:@"sendBtnbgColorUp"]) {
        NSString *sendBtnbgColorUpStr = [chatKeyboardDataDict objectForKey:@"sendBtnbgColorUp"];
        sendBtnbgColorUp = [EUtility ColorFromString:sendBtnbgColorUpStr];
    }
    UIColor *sendBtnbgColorDown = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    if ([chatKeyboardDataDict objectForKey:@"sendBtnbgColorDown"]) {
        NSString *sendBtnbgColorDownStr = [chatKeyboardDataDict objectForKey:@"sendBtnbgColorDown"];
        sendBtnbgColorDown = [EUtility ColorFromString:sendBtnbgColorDownStr];
    }
    
    NSString *sendBtnText = UEXChatKeyboard_LOCALIZEDSTRING(@"sendTitle");
    
    if ([chatKeyboardDataDict objectForKey:@"sendBtnText"]) {
        sendBtnText = [NSString stringWithFormat:@"%@",[chatKeyboardDataDict objectForKey:@"sendBtnText"]];
    }
    float sendBtnTextSize = 14.0;
    if ([chatKeyboardDataDict objectForKey:@"sendBtnTextSize"]) {
        sendBtnTextSize = [[chatKeyboardDataDict objectForKey:@"sendBtnTextSize"] floatValue];
    }
    UIColor *sendBtnTextColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    if ([chatKeyboardDataDict objectForKey:@"sendBtnTextColor"]) {
        NSString *sendBtnTextColorStr = [chatKeyboardDataDict objectForKey:@"sendBtnTextColor"];
        sendBtnTextColor = [EUtility ColorFromString:sendBtnTextColorStr];
    }
    
    chatKeyboardData.touchDownImg = touchDownImg;
    chatKeyboardData.dragOutsideImg = dragOutsideImg;
    chatKeyboardData.textColor = textColor;
    chatKeyboardData.textSize = textSize;
    chatKeyboardData.sendBtnbgColorUp = sendBtnbgColorUp;
    chatKeyboardData.sendBtnbgColorDown = sendBtnbgColorDown;
    chatKeyboardData.sendBtnText = sendBtnText;
    chatKeyboardData.sendBtnTextSize = sendBtnTextSize;
    chatKeyboardData.sendBtnTextColor = sendBtnTextColor;
    
    if ([chatKeyboardDataDict objectForKey:@"keyboardBtnImg"]) {
        chatKeyboardData.keyboardBtnImg = [self absPath:[chatKeyboardDataDict objectForKey:@"keyboardBtnImg"]];
    }
    if ([chatKeyboardDataDict objectForKey:@"voiceBtnImg"]) {
        chatKeyboardData.voiceBtnImg = [self absPath:[chatKeyboardDataDict objectForKey:@"voiceBtnImg"]];
    }
    if ([chatKeyboardDataDict objectForKey:@"emotionBtnImg"]) {
        chatKeyboardData.emotionBtnImg = [self absPath:[chatKeyboardDataDict objectForKey:@"emotionBtnImg"]];
    }
    if ([chatKeyboardDataDict objectForKey:@"selectorBtnImg"]) {
        chatKeyboardData.selectorBtnImg = [self absPath:[chatKeyboardDataDict objectForKey:@"selectorBtnImg"]];
    }
    //UEXChatKeyboard_LOCALIZEDSTRING(@"recorderHighlightedTitle");
    chatKeyboardData.recorderNormalTitle = UEXChatKeyboard_LOCALIZEDSTRING(@"recorderNormalTitle");
    //@"按住 说话";
    if ([chatKeyboardDataDict objectForKey:@"recorderNormalTitle"]) {
        chatKeyboardData.recorderNormalTitle = [NSString stringWithFormat:@"%@", [chatKeyboardDataDict objectForKey:@"recorderNormalTitle"]];
    }
    //@"松开 结束"
    chatKeyboardData.recorderHighlightedTitle = UEXChatKeyboard_LOCALIZEDSTRING(@"recorderHighlightedTitle");
    
    if ([chatKeyboardDataDict objectForKey:@"recorderHighlightedTitle"]) {
        chatKeyboardData.recorderHighlightedTitle = [NSString stringWithFormat:@"%@", [chatKeyboardDataDict objectForKey:@"recorderHighlightedTitle"]];
    }
    chatKeyboardData.recorderNormalTitleColor = [UIColor blackColor];
    if ([chatKeyboardDataDict objectForKey:@"recorderNormalTitleColor"]) {
        chatKeyboardData.recorderNormalTitleColor = [EUtility ColorFromString:[chatKeyboardDataDict objectForKey:@"recorderNormalTitleColor"]];
    }
    chatKeyboardData.recorderHighlightedTitleColor = [UIColor blackColor];
    if ([chatKeyboardDataDict objectForKey:@"recorderHighlightedTitleColor"]) {
        chatKeyboardData.recorderHighlightedTitleColor = [EUtility ColorFromString:[chatKeyboardDataDict objectForKey:@"recorderHighlightedTitleColor"]];
    }
    
    if ([chatKeyboardDataDict objectForKey:@"chatKeyboardBgColor"]) {
        chatKeyboardData.chatKeyboardBgColor = [EUtility ColorFromString:[chatKeyboardDataDict objectForKey:@"chatKeyboardBgColor"]];
    }
    if ([chatKeyboardDataDict objectForKey:@"inputBgColor"]) {
        chatKeyboardData.inputBgColor = [EUtility ColorFromString:[chatKeyboardDataDict objectForKey:@"inputBgColor"]];
    }
    if ([chatKeyboardDataDict objectForKey:@"recorderBgColor"]) {
        chatKeyboardData.recorderBgColor = [EUtility ColorFromString:[chatKeyboardDataDict objectForKey:@"recorderBgColor"]];
    }
    
    chatKeyboardData.isRound = YES;
    if ([chatKeyboardDataDict objectForKey:@"isRound"]) {
        chatKeyboardData.isRound = [[chatKeyboardDataDict objectForKey:@"isRound"] boolValue];
    }
    if ([chatKeyboardDataDict objectForKey:@"faceViewBgColor"]) {
        chatKeyboardData.faceViewBgColor = [EUtility ColorFromString:[chatKeyboardDataDict objectForKey:@"faceViewBgColor"]];
    }
    if ([chatKeyboardDataDict objectForKey:@"shareViewBgColor"]) {
        chatKeyboardData.shareViewBgColor = [EUtility ColorFromString:[chatKeyboardDataDict objectForKey:@"shareViewBgColor"]];
    }
    
}

- (NSString*)localizedString:(NSString *)key,...{
    
    NSString *defaultValue=@"";
    va_list argList;
    va_start(argList,key);
    id arg=va_arg(argList,id);
    //if(arg && [arg isKindOfClass:[NSString class]]){
    if(arg){
        defaultValue=arg;
    }
    va_end(argList);
    
    
    return [EUtility uexPlugin:@"uexChatKeyboard" localizedString:key,defaultValue];
    
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (void)hideKeyboard:(NSMutableArray*)inArguments {
    
    if (_chatKeyboard) {
 
        [_chatKeyboard hideKeyboard];
        
    }

}

- (void)getInputBarHeight:(NSMutableArray*)inArguments {
    CGFloat height;
    if ([[[UIDevice currentDevice]systemVersion]floatValue]>=7) {
        height = 45.0f;
    } else {
        height = 40.0f;
    }
    [self callBackJsonWithName:@"cbGetInputBarHeight" Object:@{@"height":@(height)}];
    
}

- (void)callBackJsonWithName:(NSString *)name Object:(id)obj {
    
    const NSString *kPluginName = @"uexChatKeyboard";
    NSString *result=[obj JSONFragment];
    NSString *jsSuccessStr = [NSString stringWithFormat:@"if(%@.%@ != null){%@.%@('%@');}",kPluginName,name,kPluginName,name,result];
    [self performSelector:@selector(delayedCallBack:) withObject:jsSuccessStr afterDelay:0.01];
    
}


- (void)delayedCallBack:(NSString *)str {
    
    [EUtility brwView:meBrwView evaluateScript:str];
    
}

- (void)setShareDicFromSharePath:(NSString *)sharePath {
    
    NSData *xmlData = [NSData dataWithContentsOfFile:sharePath];
    NSError *error;
    NSDictionary *chatKeyboardDataDict = [XMLReader dictionaryForXMLData:xmlData error: &error];
    NSDictionary *tempDic = [chatKeyboardDataDict objectForKey:@"shares"];
    [ChatKeyboardData sharedChatKeyboardData].shareArray = [tempDic objectForKey:@"key"];
    [ChatKeyboardData sharedChatKeyboardData].shareImgArray = [tempDic objectForKey:@"string"];
    [ChatKeyboardData sharedChatKeyboardData].pageNum = [tempDic objectForKey:@"prePageNum"];
    
}

- (NSMutableDictionary *)getDicByKeyArray:(NSArray *)keyArray andStringArray:(NSArray *)stringArray {
    
    NSMutableDictionary *reDic = [NSMutableDictionary dictionary];
    for (int i = 0; i < [keyArray count]; i++) {
        
        NSString *key = [[keyArray objectAtIndex:i] objectForKey:@"text"];
        NSString *string = [[stringArray objectAtIndex:i] objectForKey:@"text"];
        [reDic setObject:string forKey:key];
        
    }
    
    return reDic;
    
}

- (void)setFaceDicByFaceXMLPath:(NSString *)xmlPath {
    NSData *xmlData = [NSData dataWithContentsOfFile:xmlPath];
    NSError *error;
    NSDictionary *chatKeyboardDataDict = [XMLReader dictionaryForXMLData:xmlData error: &error];
    NSDictionary *emojiconsDic = [chatKeyboardDataDict objectForKey:@"emojicons"];
    [ChatKeyboardData sharedChatKeyboardData].faceArray = [emojiconsDic objectForKey:@"key"];
    [ChatKeyboardData sharedChatKeyboardData].faceImgArray = [emojiconsDic objectForKey:@"string"];
    [ChatKeyboardData sharedChatKeyboardData].deleteImg = [emojiconsDic objectForKey:@"delete"];
}

- (void)changeWebViewFrame:(NSMutableArray *)array {
    
    float h = [[array objectAtIndex:0] floatValue];
    
    if (_chatKeyboard) {
        [_chatKeyboard changeWebView:h];
    }
    
}

- (void)close:(NSMutableArray *)array {
    
    [self clean];
}

#pragma mark - 弃用onAt相关API
- (void)insertAfterAt:(NSMutableArray *)inArguments {
//    if([inArguments count] < 1){
//        return;
//    }
//    id data = inArguments[0];
//    NSString *str = nil;
//    if ([data isKindOfClass:[NSString class]]) {
//        str = data;
//    }
//    if ([data isKindOfClass:[NSNumber class]]) {
//        str = [data stringValue];
//    }
//    if (!str) {
//        return;
//    }
//    [self.chatKeyboard insertAfterAt:str];

}

#pragma mark - 通过关键字插入内容
- (void)insertTextByKeyword:(NSMutableArray *)inArguments{
    
    NSLog(@"AppCan --> uexChatKeyboard --> insertTextByKeyword --> inArguments = %@",inArguments);
    
    if([inArguments count] < 1){
        return;
    }
    
    NSDictionary *info = [inArguments[0] JSONValue];
    
    if (!([info isKindOfClass:[NSDictionary class]] || [info isKindOfClass:[NSMutableDictionary class]])) {
        return;
    }
    
    if (info[@"keyword"] == nil || info[@"insertText"] == nil || info[@"isReplaceKeyword"] == nil) {
        return;
    }
    
    NSString * keyword = [NSString stringWithFormat:@"%@",info[@"keyword"]];
    NSString * insertText = [NSString stringWithFormat:@"%@",info[@"insertText"]];
    NSNumber * isReplaceKeywordFlag = info[@"isReplaceKeyword"];
    if (![isReplaceKeywordFlag isKindOfClass:[NSNumber class]]) {
        isReplaceKeywordFlag = [[NSNumber alloc] initWithInt:[info[@"isReplaceKeyword"] intValue]];
    }
    
    BOOL isReplaceKeyword = isReplaceKeywordFlag ? isReplaceKeywordFlag.integerValue == 1 : NO;
    
    [self.chatKeyboard insertString:insertText afterKeyword:keyword isReplacingKeyword:isReplaceKeyword];
}






@end
