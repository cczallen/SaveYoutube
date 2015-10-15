//
//  ParsingYoutuveViewController.m
//  SaveYoutube
//
//  Created by ALLENMAC on 2015/10/9.
//  Copyright © 2015年 AllenLee. All rights reserved.
//

#import "ParsingYoutuveViewController.h"
#import "DaiYoutubeParser.h"
#import "SVProgressHUD.h"
#import "FBKVOController.h"



@interface ParsingYoutuveViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *urlTextfield;
@property (weak, nonatomic) IBOutlet UITextField *youtubeIDTextfield;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

- (IBAction)pasteAction:(id)sender;
- (IBAction)goAction:(id)sender;
- (IBAction)downloadAction:(id)sender;

@end

@implementation ParsingYoutuveViewController

- (NSURLSession *)sharedSession {
    static NSURLSession *sharedSession = nil;
    if (sharedSession == nil) {
//        static NSString * const identifier = @"SaveYoutubeSessionConfigID";
//        sharedSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier]];
        sharedSession = [NSURLSession sharedSession];
    }
    return sharedSession;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.downloadButton.enabled = NO;
    self.goButton.layer.borderColor = [UIColor blueColor].CGColor;
    self.webView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.webView.layer.borderWidth = 1;
    
    self.webView.delegate = self;
    self.webView.allowsInlineMediaPlayback = NO;
    self.webView.mediaPlaybackRequiresUserAction = YES;

    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self tryToAutoPaste];
    }];
    
    [self tryToAutoPaste];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Actions

- (void)tryToAutoPaste {
    UIPasteboard *pasteboard=[UIPasteboard generalPasteboard];
    NSString *string = [pasteboard string];
    if (string) {
        NSString *pattern1 = @"youtu.be";
        NSString *pattern2 = @"youtube";
        if ([string containsString:pattern1] || [string containsString:pattern2]) {
            self.urlTextfield.text = string;
        }
    }
    [self goAction:nil];
}

- (IBAction)pasteAction:(id)sender {
    self.downloadButton.enabled = NO;
    
    UIPasteboard *pasteboard=[UIPasteboard generalPasteboard];
    NSString *string = [pasteboard string];
    NSLog(@"LOG:  string: %@",string);
    if (string) {
        self.urlTextfield.text = string;
        [self goAction:sender];
    }
}

- (IBAction)goAction:(id)sender {
    self.downloadButton.enabled = NO;
    
    NSString *youtubeURLString = self.urlTextfield.text;
    NSString *youtubeID = self.youtubeIDTextfield.text;

    NSString *pattern1 = @"youtu.be/";
    NSString *pattern2 = @"www.youtube.com/watch?v=";
    
    youtubeURLString = [youtubeURLString stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    youtubeURLString = [youtubeURLString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    youtubeURLString = [youtubeURLString stringByReplacingOccurrencesOfString:@"m.youtube" withString:@"www.youtube"];
    
    if ([youtubeURLString containsString:pattern1]) {
        youtubeID = [youtubeURLString stringByReplacingOccurrencesOfString:pattern1 withString:@""];
        NSArray *array = [youtubeID componentsSeparatedByString:@"/"];
        if ([array count] > 0) {
            youtubeID = [array firstObject];
        }
    } else if ([youtubeURLString containsString:pattern2]) {
        // https://www.youtube.com/watch?v=x6vV67uefeM&list=FLg43Z-3yCBwSMwVoXrP6COA&index=52
        youtubeID = [youtubeURLString stringByReplacingOccurrencesOfString:pattern2 withString:@""];
        NSArray *array = [youtubeID componentsSeparatedByString:@"&"];
        if ([array count] > 0) {
            youtubeID = [array firstObject];
        }
    }
    
    if (youtubeID) {
        youtubeURLString = [NSString stringWithFormat:@"http://youtu.be/%@", youtubeID];
        self.urlTextfield.text = youtubeURLString;
        self.youtubeIDTextfield.text = youtubeID;
    }
    
    if (![youtubeID length]) {
        return;
    }
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:youtubeURLString]]];
    self.downloadButton.enabled = YES;
}

- (IBAction)downloadAction:(id)sender {
    NSString *youtubeID = self.youtubeIDTextfield.text;
    if (![youtubeID length]) {
        return;
    }
    
    [SVProgressHUD showWithMaskType:(SVProgressHUDMaskTypeGradient)];
    
    __weak ParsingYoutuveViewController *weakSelf = self;
    [DaiYoutubeParser parse:youtubeID screenSize:self.webView.bounds.size videoQuality:DaiYoutubeParserQualityHighres completion:^(DaiYoutubeParserStatus status, NSString *url, NSString *videoTitle, NSNumber *videoDuration) {
        if (status) {
            NSLog(@"videoTitle: %@", videoTitle);
            NSLog(@"videoDuration: %@", videoDuration);
            NSLog(@"url: %@", url);
            
            [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"正在下載：%@", videoTitle]];
            
            NSURLSessionDownloadTask *task =
            [[weakSelf sharedSession] downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (location && !error) {
                    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
                    NSString *fileName = [NSString stringWithFormat:@"%@.mp4", videoTitle];
                    fileName = [[fileName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@"_" ];
                    fileName = [[fileName componentsSeparatedByCharactersInSet:[NSCharacterSet illegalCharacterSet]] componentsJoinedByString:@"_" ];
                    fileName = [[fileName componentsSeparatedByCharactersInSet:[NSCharacterSet symbolCharacterSet]] componentsJoinedByString:@"_" ];
                    NSURL *tempURL = [documentsURL URLByAppendingPathComponent:fileName];
                    [[NSFileManager defaultManager] moveItemAtURL:location toURL:tempURL error:nil];
                    
                    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"下載完成，正在儲存到相機膠捲 Youtube ID: %@", youtubeID]];
                    UISaveVideoAtPathToSavedPhotosAlbum(tempURL.path, weakSelf, @selector(video:didFinishSavingWithError:contextInfo:), CFBridgingRetain(videoTitle));
                    
                    NSLog(@"LOG:  fileName: %@", [fileName debugDescription]);
                    NSLog(@"LOG:  tempURL: %@", [tempURL debugDescription]);
                } else {
                    [SVProgressHUD showErrorWithStatus:@"影片下載失敗"];
                }
            }];
            
            [task resume];
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Load Video Fail" message:@"Handle on Fail" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil];
            [alert show];
        }
        
    }];

}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *videoTitle = CFBridgingRelease(contextInfo);
    if (![videoTitle isKindOfClass:[NSString class]]) {
        videoTitle = nil;
    }
    
    NSString *message = nil;
    if (error) {
        message = @"儲存到相機膠捲 失敗！";
        [SVProgressHUD showErrorWithStatus:message];
    } else {
        message = @"下載完成，儲存到相機膠捲 成功！";
        [SVProgressHUD showSuccessWithStatus:message];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"photos-redirect://"]];
        });
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
}



#pragma mark - <UIWebViewDelegate>

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
//    NSString *pattern1 = @"youtu.be";
//    NSString *pattern2 = @"youtube";
//    NSString *urlString = request.URL.absoluteString;
//    NSLog(@"LOG:  urlString: %@", [urlString debugDescription]);
//    
//    if ([urlString containsString:pattern1] || [urlString containsString:pattern2]) {
//        self.urlTextfield.text = urlString;
//        self.urlTextfield.textColor = [UIColor blueColor];
//        
//        self.goButton.layer.borderWidth = 1;
//        
//        [SVProgressHUD showWithStatus:@"捕獲 Youtube 網址！"];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.urlTextfield.textColor = [UIColor blackColor];
//            self.goButton.layer.borderWidth = 0;
//            [SVProgressHUD dismiss];
//        });
//    }

    return YES;
}

@end
