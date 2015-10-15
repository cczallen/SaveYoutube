//
//  ALUtilities.h
//  ALUtilities
//
//  Created by ALLENMAC on 2014/6/23.
//  Copyright (c) 2014年 AllenLee. All rights reserved.
//

#import <Foundation/Foundation.h>


//---------------------------
#pragma mark -
// 判斷是否iPad 或 iPhone
#define isIPadUI (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define isIPadDevice ([[[UIDevice currentDevice] model] isEqualToString:@"iPad"])
#define isIPhoneUI (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define isIPhoneDevice ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"])
// 判斷是否模擬器
#define isSimulator (NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location )

#define isIOS4Later [ALUtilities isIOSVersionOrLater:4.0]
#define isIOS7Later [ALUtilities isIOSVersionOrLater:7.0]
#define isIOS8Later [ALUtilities isIOSVersionOrLater:8.0]

#define degreesToRadians(x) ((x) * (M_PI / 180.0))
#define IsLandscape UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])

#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)
#define fequalzero(a) (fabs(a) < FLT_EPSILON)


//---------------------------
#pragma mark - Better NSLog
#ifndef __OPTIMIZE__
#    //A better version of NSLog	//http://onevcat.com/2014/01/black-magic-in-macro/
#    define NSLog(format, ...) do {		dispatch_queue_t lockQueue = dispatch_queue_create("com.log.LockQueue", NULL);      \
         dispatch_sync(lockQueue, ^{                                                                                        \
             fprintf(stderr, "<%s : %d> %s %s\n\n %s\n \n────────────────────────────────────────────────────────────\n"    \
                 , [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __func__            \
                 , ([NSThread isMainThread])? "":"\nisMainThread:NO"                                                        \
                 , [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String]                                         \
             );                                                                                                             \
     }); } while (0)
//Alternate Separators
//┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈
//────────────────────────────────────────────────────────────
//------------------------------------------------------------
#else
#    define NSLog(...) {}
#endif

//---------------------------
//GCDSingleton
#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
		static dispatch_once_t pred = 0; \
		__strong static id _sharedObject = nil; \
		dispatch_once(&pred, ^{ \
			_sharedObject = block(); \
		}); \
		return _sharedObject;

//---------------------------
#pragma mark - GCD dispatch
#define  MainQueue				dispatch_get_main_queue()
#define  DefaultGlobalQueue		dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
void dispatchBG(dispatch_block_t block);
void dispatchMain(dispatch_block_t block);
void dispatchAfter(double delayInSeconds, dispatch_block_t block);

typedef void(^RepeatBlock)(size_t i);
void repeat(size_t iterations, RepeatBlock block);
void repeatWithCompletion(size_t iterations, RepeatBlock block, void(^completion)() );
void repeatConcurrently(size_t iterations, RepeatBlock block);
void repeatConcurrentlyWithCompletion(size_t iterations, RepeatBlock block, void(^completion)() );

//---------------------------
#pragma mark -
#define SafeStr(x) ((x==nil)?@"":[NSString stringWithFormat:@"%@" , x])

NSString *NSStringFromNSInteger(NSInteger num);
NSString *NSStringFromLong(long num);
NSString *NSStringFromInt(int num);
NSString *NSStringFromFloat(float num);

//---------------------------

#define GetRandomBetween(min,max) (arc4random()%(max-min+1) +min)
#define GetRandomColor [UIColor colorWithRed:(double)arc4random()/0x100000000 green:(double)arc4random()/0x100000000 blue:(double)arc4random()/0x100000000 alpha:1]
#define GetRandomColorWithAlpha(x) ([UIColor colorWithRed:(double)arc4random()/0x100000000 green:(double)arc4random()/0x100000000 blue:(double)arc4random()/0x100000000 alpha:x])

#define AppSupportDir	[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define DocDir			[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]


//---------------------------
#pragma mark -
@interface ALUtilities : NSObject	// 20140816

+ (BOOL)isIOSVersionOrLater:(float)iosVersion;

+ (BOOL)checkUnicharIsNumeric:(unichar)c;
+ (BOOL)checkUnicharIsAlphabetic:(unichar)c;
+ (BOOL)checkStringIsAllNumeric:(NSString *)str;
+ (BOOL)checkStringIsAllAlphabetic:(NSString *)str;
+ (NSString *)KG2LB:(NSString *)kg;

+ (instancetype)creatViewByName:(NSString *)className;
+ (void)setDefaultStroyboardName:(NSString *)stroyboardName;
+ (instancetype)creatViewControllerByStoryboardID:(NSString *)stroyboardID;
+ (instancetype)creatViewControllerByStoryboardID:(NSString *)stroyboardID andStoryboardName:(NSString *)stroyboardName;

//+ (NSString *)NSDateToStrDate:(NSDate *)date;
//+ (NSString *)NSDateToStrTime:(NSDate *)date;
//+ (NSDate *)NSStringToNSDate:(NSString *)strDate;
//+ (NSDate *)NSStringToNSDateTime:(NSString *)strDate;
@end



//---------------------------
#pragma mark - UIViewController Categories
@interface UIViewController (CreateFromStoryboard)
+ (instancetype)createFromMainStoryboard;	//use class name as stroyboardID
@end



//---------------------------
#pragma mark - UIView Categories

@interface UIView (frameMethods)
-(void)moveToSuperviewsCenter;
-(void)moveToThisviewsCenter:(UIView *)thisView;
-(void)moveToNewOrigin:(CGPoint)newOrigin;
-(void)setFrameSameAsSuperView;
-(void)setFrameIntegral;
-(CGFloat)getTotalXFrom:(UIView *)view;
-(CGFloat)getTotalYFrom:(UIView *)view;

-(void)addSubviewAtTheSamePlaceTo:(UIView *)view;

-(UIViewController *)findNearestViewController;
-(UIView *)findNearestViewControllersView;
-(void)resignAllResponder;
- (instancetype)findFirstResponder;

#pragma mark -
-(instancetype)findNearestScrollView;
-(instancetype)findNearestScrollViewStartFrom:(UIView *)view;

-(void)showPoint:(CGPoint)pt;
+ (void)setCAAnimationDuration:(NSTimeInterval)dura;
- (void)addCAAnimationFromTop;
- (void)addCAAnimationFromBottom;
- (void)addCAAnimationFromLeft;
- (void)addCAAnimationFromRight;
- (void)addCAAnimationBykCATransitionFrom:(NSString *)from;

- (void)drawBorder;

// 20120927 http://code4app.com/snippets/one/查询子视图/50164d0a6803fa4c15000000#s0
- (NSArray *)allSubviews;
- (NSArray *)allApplicationViews;
- (NSArray *)pathToView;
@end



//---------------------------
#pragma mark - Image Categories
@interface UIImage (ResizeMethods)
+ (UIImage *)captureImageFromView:(UIView *)theView;
//+ (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize;
+ (UIImage *)imageWithContentsOfFileByPNGNamed:(NSString *)imgName;
+ (UIImage *)imageWithContentsOfFileByJPGNamed:(NSString *)imgName;
- (UIImage *)imageWithCropToSquare;
@end

@interface UIImageView (InitMethods)
+ (UIImageView *)imageViewWithPNGNamed:(NSString *)imageName;
+ (UIImageView *)imageViewWithJPGNamed:(NSString *)imageName;
+ (UIImageView *)imageViewWithNamed:(NSString *)imageName AndType:(NSString *)imageType;
@end



//---------------------------
#pragma mark -
@interface UITableView (reloadMethods)
-(void)reloadDataWithRowAnimation:(UITableViewRowAnimation)rowAnimation;
@end



//---------------------------
#pragma mark -
@interface NSArray (Unicode)
- (NSString*)description;
@end

@interface NSDictionary (Unicode)
- (NSString*)description;
@end



//---------------------------
#pragma mark -
@interface NSDictionary (SortedKeys)
- (NSArray *)sortedKeys;
- (NSArray *)sortedKeysByDescending;
@end



//---------------------------
#pragma mark -
@interface NSString (verifyCheck)
- (NSString *)getTrimmedVal;
- (BOOL)verifyROCPersonalID;
@end



//---------------------------
#pragma mark -
@interface UILabel (alignTop)
//http://fstoke.me/blog/?p=2819
// adjust the height of a multi-line label to make it align vertical with top
- (void) alignLabelWithTop;
@end



//---------------------------
#pragma mark -
@interface NSDate (theSameDay)
- (BOOL)isSameDay:(NSDate*)date2;
@end


//---------------------------
#pragma mark -
@interface NSDictionary (jsonString)
- (NSString *)jsonString;
@end

@interface NSArray (jsonString)
- (NSString *)jsonString;
@end

@interface NSString (jsonDic)
- (id)jsonDic;	//NSDictionary * or NSArray *
@end

@interface NSData (NSDataToUTF8String)
- (NSString *)string;
@end

@interface NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end


//---------------------------
#pragma mark -