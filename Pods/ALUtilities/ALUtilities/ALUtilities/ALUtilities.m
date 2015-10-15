//
//  ALUtilities.m
//  ALUtilities
//
//  Created by ALLENMAC on 2014/6/23.
//  Copyright (c) 2014年 AllenLee. All rights reserved.
//


#import "ALUtilities.h"

NSString *NSStringFromNSInteger(NSInteger num)	{
	NSString * strNum = [[NSNumber numberWithInteger:num] stringValue];
	return strNum;
}

NSString *NSStringFromLong(long num)	{
	NSString * strNum = [NSString stringWithFormat:@"%li",num];
	return strNum;
}

NSString *NSStringFromInt(int num)	{
	NSString * strNum = [NSString stringWithFormat:@"%i",num];
	return strNum;
}

NSString *NSStringFromFloat(float num)	{
	NSString * strNum = [NSString stringWithFormat:@"%f",num];
	return strNum;
}

//---------------------------

void dispatchBG(dispatch_block_t block)	{
	dispatch_async(DefaultGlobalQueue, block);
};

void dispatchMain(dispatch_block_t block)	{
	dispatch_async(MainQueue, block);
};

void dispatchAfter(double delayInSeconds, dispatch_block_t block)	{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)),
				   dispatch_get_main_queue(),
				   block
				   );
};

void repeat(size_t iterations, RepeatBlock block)	{
	repeatWithCompletion(iterations, block, NULL);
};

void repeatWithCompletion(size_t iterations, RepeatBlock block, void(^completion)() )	{
	dispatch_queue_t  queue = dispatch_queue_create("org.Allen.RepeatSerially", DISPATCH_QUEUE_SERIAL);
	dispatch_apply(iterations, queue, block);
	if (completion) {
		completion();
	}
};

void repeatConcurrently(size_t iterations, RepeatBlock block)	{
	repeatConcurrentlyWithCompletion(iterations, block, NULL);
};

void repeatConcurrentlyWithCompletion(size_t iterations, RepeatBlock block, void(^completion)() )	{
	dispatch_queue_t  queue = dispatch_queue_create("org.Allen.RepeatConcurrently", DISPATCH_QUEUE_CONCURRENT);//DefaultGlobalQueue;
	dispatch_apply(iterations, queue, block);
	if (completion) {
		completion();
	};
}

//---------------------------


//---------------------------
#pragma mark -
@implementation ALUtilities

+(BOOL)isIOSVersionOrLater:(float)iosVersion {
	NSString *osversion = [UIDevice currentDevice].systemVersion;
	
	if ( [osversion floatValue] >= iosVersion)
		return	YES;
	return	NO;
}



//檢核用
+ (BOOL)checkUnicharIsNumeric:(unichar)c	{
	if ( c>=48  && c<=57 ) {
		//數字
		return YES;
		
	} else {
		//非數字
		return NO;
	}
}
+ (BOOL)checkUnicharIsAlphabetic:(unichar)c	{
	if ( ( c>=65  && c<=90 ) || ( c>=97  && c<=122 ) ) {
		//英文字母大寫或小寫
		return YES;
		
	} else {
		//非英文字母
		return NO;
	}
}

+ (BOOL)checkStringIsAllNumeric:(NSString *)str	{
	
	BOOL isAllNumeric = YES;
	for (int i=0; i<[str length]; i++) {
		unichar c = [str characterAtIndex:i];
		if ( [ALUtilities checkUnicharIsNumeric:c] == NO ) {		//非數字
			isAllNumeric = NO;
		}
	}
//	NSLog(@"LOG: %@ isAllNumeric: %@", str ,(isAllNumeric)? @"YES":@"NO" );
	if (isAllNumeric) {
		return YES;
	}else	{
		return NO;
	}
}

+ (BOOL)checkStringIsAllAlphabetic:(NSString *)str	{
	
	BOOL isAllAlphabetic = YES;
	for (int i=0; i<[str length]; i++) {
		unichar c = [str characterAtIndex:i];
		if ( [ALUtilities checkUnicharIsAlphabetic:c] == NO ) {		//非數字
			isAllAlphabetic = NO;
		}
	}
//	NSLog(@"LOG:  isAllAlphabetic: %@",(isAllAlphabetic)? @"YES":@"NO" );
	if (isAllAlphabetic) {
		return YES;
	}else	{
		return NO;
	}
}

+ (NSString *)KG2LB:(NSString *)kg	{
	
	NSNumberFormatter * numFormatter = [[NSNumberFormatter alloc] init];
	[numFormatter setNumberStyle:(NSNumberFormatterDecimalStyle)];
	[numFormatter setMaximumFractionDigits:1];
	
	NSNumber * numKg = [numFormatter numberFromString:kg];
	NSNumber * numLb = [NSNumber numberWithFloat: [numKg floatValue] *2.20462 ];
	
	NSString * strLb = [numFormatter stringFromNumber:numLb];
	
	return strLb;
}

+ (instancetype)creatViewByName:(NSString *)className	{
	Class ViewClass = NSClassFromString(className);
	if (ViewClass == nil) {
		return nil;
	}
	
	id view = nil;
	NSArray * nibObjects = [ [NSBundle mainBundle] loadNibNamed:className owner:nil options:nil];
	for ( id currentObject in nibObjects ) {
		if ([currentObject isKindOfClass:ViewClass ]  ) {
			view = currentObject;
		}
	}
	
	return view;
}

static NSString *defaultStroyboardName = @"Main";
+ (void)setDefaultStroyboardName:(NSString *)stroyboardName {
	defaultStroyboardName = stroyboardName;
}

+ (instancetype)creatViewControllerByStoryboardID:(NSString *)stroyboardID	{
	return [[self class] creatViewControllerByStoryboardID:stroyboardID andStoryboardName:defaultStroyboardName];
}
+ (instancetype)creatViewControllerByStoryboardID:(NSString *)stroyboardID andStoryboardName:(NSString *)stroyboardName	{
	UIStoryboard * mainStroyboard = [UIStoryboard storyboardWithName:stroyboardName bundle:nil];
	id VC = [mainStroyboard instantiateViewControllerWithIdentifier:stroyboardID];
	return VC;
}

@end



//---------------------------
#pragma mark - UIViewController Categories
@implementation UIViewController (CreateFromStoryboard)
+ (instancetype)createFromMainStoryboard	{
	id vc = [ALUtilities creatViewControllerByStoryboardID:NSStringFromClass([self class])];
	return vc;
}
@end



//---------------------------
#pragma mark - UIView Categories

@implementation UIView (frameMethods)

-(void)moveToSuperviewsCenter	{
	
	if (self.superview == nil) {
		NSLog(@"LOG:  self.superview == nil]");
		return;
	}
	
	CGRect rect = self.frame;
	rect.origin.x = (self.superview.frame.size.width -self.frame.size.width) *0.5;
	rect.origin.y = (self.superview.frame.size.height -self.frame.size.height) *0.5;
	
	[self setFrame:rect];
}

-(void)moveToThisviewsCenter:(UIView *)thisView	{
	
	if (thisView == nil) {
		NSLog(@"LOG:  thisView == nil]");
		return;
	}
	
	CGRect rect = self.frame;
	rect.origin.x = (thisView.frame.size.width -self.frame.size.width) *0.5;
	rect.origin.y = (thisView.frame.size.height -self.frame.size.height) *0.5;
	
	[self setFrame:rect];
}

-(void)moveToNewOrigin:(CGPoint)newOrigin	{
	
	[self setFrame:CGRectMake(newOrigin.x, newOrigin.y, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
}

-(void)setFrameSameAsSuperView	{
	UIView * superView = self.superview;
	if (superView == nil)	{
		NSLog(@"LOG:  (superView == nil)]");
		return;
	}
	
	CGRect rect = superView.frame;
	rect.origin = CGPointZero;
	[self setFrame:rect];
}

-(void)setFrameIntegral	{	//20120404
	[self setFrame:CGRectIntegral(self.frame)];
}

- (CGFloat)getTotalXFrom:(UIView *)view	{
	if ([self isEqual:view] || self.superview == nil) {
		return self.frame.origin.x;
	}else {
		return [self.superview getTotalXFrom:view] + self.frame.origin.x;
	}
}
- (CGFloat)getTotalYFrom:(UIView *)view	{
	if ([self isEqual:view] || self.superview == nil) {
		return self.frame.origin.y;
	}else {
		return [self.superview getTotalYFrom:view] + self.frame.origin.y;
	}
}


-(void)addSubviewAtTheSamePlaceTo:(UIView *)view	{
	CGRect rect;
	
	CGFloat x = [self getTotalXFrom:view];
	CGFloat y = [self getTotalYFrom:view];
	rect = CGRectMake(x, y, self.frame.size.width, self.frame.size.height);
	
	
	[self setFrame:rect];
	[view addSubview:self];
}

/* 另一方法！！
 // Convenient category method to find actual ViewController that contains a view
 // Adapted from: http://stackoverflow.com/questions/1340434/get-to-uiviewcontroller-from-uiview-on-iphone
 
 @implementation UIView (FindUIViewController)
 - (UIViewController *) containingViewController {
 UIView * target = self.superview ? self.superview : self;
 return (UIViewController *)[target traverseResponderChainForUIViewController];
 }
 
 - (instancetype) traverseResponderChainForUIViewController {
 id nextResponder = [self nextResponder];
 BOOL isViewController = [nextResponder isKindOfClass:[UIViewController class]];
 BOOL isTabBarController = [nextResponder isKindOfClass:[UITabBarController class]];
 if (isViewController && !isTabBarController) {
 return nextResponder;
 } else if(isTabBarController){
 UITabBarController *tabBarController = nextResponder;
 return [tabBarController selectedViewController];
 } else if ([nextResponder isKindOfClass:[UIView class]]) {
 return [nextResponder traverseResponderChainForUIViewController];
 } else {
 return nil;
 }
 }
 
 */

-(UIViewController *)findNearestViewController	{
	
	UIViewController * targetViewController = nil;
	UIView * targetView = nil;
	
	targetView = self;
	do {
		
		if (targetView.superview == nil)
			break;
		
		targetView = targetView.superview;
		
	} while ( ![targetView.nextResponder isKindOfClass:[UIViewController class]] );
	
	targetViewController = (UIViewController *)targetView.nextResponder;
	
	return targetViewController;
}

-(UIView *)findNearestViewControllersView	{
	
	UIView * targetView = nil;
	
	targetView = self;
	do {
		
		if (targetView.superview == nil)
			break;
		
		targetView = targetView.superview;
		
	} while ( ![targetView.nextResponder isKindOfClass:[UIViewController class]] );
	
	
	return targetView;
}

-(void)resignAllResponder	{
	
    for (UIView* view in self.subviews) {
        
        if ([view isKindOfClass:[UITextField class]])
            
            [view resignFirstResponder];
        
    }
}

- (instancetype)findFirstResponder	{
	id firstResponder = nil;
	
	for (UIView * subview in [self subviews]) {
		if ([subview isFirstResponder]) {
			firstResponder = subview;
			break;
		}
	}
	
	return firstResponder;
}

//+ (UIImage*)captureView:(UIView *)theView
//{
//	CGRect rect = theView.frame;
//	UIGraphicsBeginImageContext(rect.size);
//	CGContextRef context = UIGraphicsGetCurrentContext();
//	[theView.layer renderInContext:context];
//	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
//	UIGraphicsEndImageContext();
//	return img;
//}


#pragma mark -


//
-(instancetype)findNearestScrollView	{
	
	id scrollView = [self findNearestScrollViewStartFrom:self];
	
	return scrollView;
}
-(instancetype)findNearestScrollViewStartFrom:(UIView *)view	{
	
	id targetScrollView = view;
	while (YES) {
		
		targetScrollView = [targetScrollView superview];
		if (targetScrollView == nil) {
			break;
		}
		if ([targetScrollView isKindOfClass:[UIScrollView class]]) {
			break;
		}
	}
	
	return targetScrollView;
}


-(void)showPoint:(CGPoint)pt	{
	
	UIView * centerPoint = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 10, 10))];
	[centerPoint setBackgroundColor:[UIColor whiteColor]];
	[centerPoint moveToNewOrigin:pt];
	[self addSubview:centerPoint];	//[centerPoint release];
	
}

static NSTimeInterval CAAnimDuraion = 0.0;
+ (void)setCAAnimationDuration:(NSTimeInterval)dura	{	//20120604
	CAAnimDuraion = dura;
}
- (void)addCAAnimationFromTop	{
	[self addCAAnimationBykCATransitionFrom:kCATransitionFromTop];
}
- (void)addCAAnimationFromBottom	{
	[self addCAAnimationBykCATransitionFrom:kCATransitionFromBottom];
}
- (void)addCAAnimationFromLeft	{
	[self addCAAnimationBykCATransitionFrom:kCATransitionFromLeft];
}
- (void)addCAAnimationFromRight	{
	[self addCAAnimationBykCATransitionFrom:kCATransitionFromRight];
}

- (void)addCAAnimationBykCATransitionFrom:(NSString *)from	{
	//使用動畫
	if ( isIOS4Later ) {
		UIView * targetView = self;
		CATransition* transition = [CATransition animation];
		transition.duration = (CAAnimDuraion == 0.0)?0.23:CAAnimDuraion;
		transition.type = kCATransitionPush;
		transition.subtype = from;
		
		[targetView.layer addAnimation:transition forKey:nil];
	}
}

- (void)drawBorder	{
	[self.layer setBorderColor:GetRandomColor.CGColor];
	[self.layer setBorderWidth:1];
	for ( UIView *subview in [self subviews]) {
		[subview drawBorder];
	}
}

// Return an exhaustive descent of the view's subviews
//NSArray *allSubviews(UIView *aView)
- (NSArray *)allSubviews
{
    NSArray *results = [self subviews];
    for (UIView *eachView in [self subviews]) {
		NSArray * riz = [eachView allSubviews];
        if (riz)
			results = [results arrayByAddingObjectsFromArray:riz];
    }
    return results;
}

// Return all views throughout the application
- (NSArray *)allApplicationViews
{
    NSArray *results = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in [[UIApplication sharedApplication]windows]) {
        NSArray *riz = [window allSubviews];
        if (riz) results = [results arrayByAddingObjectsFromArray:riz];
    }
    return results;
}

// Return an array of parent views from the window down to the view
- (NSArray *)pathToView
{
    NSMutableArray *array = [NSMutableArray arrayWithObject:self];
    UIView *view = self;
    UIWindow *window = self.window;
    while (view != window)
    {
        view = [view superview];
        [array insertObject:view atIndex:0];
    }
    return array;
}

@end



//---------------------------
#pragma mark - Image Categories
@implementation UIImage (ResizeMethods)
//自行定義的函式用來取得UIView中的UIImage
+ (UIImage *)captureImageFromView:(UIView *)theView {
	
	//設定邊界大小和影像透明度與比例
	//	UIGraphicsBeginImageContextWithOptions(theView.bounds.size, theView.opaque, 0.0);
	UIGraphicsBeginImageContextWithOptions(theView.bounds.size, NO, 0.0);
	[theView.layer renderInContext:UIGraphicsGetCurrentContext()];
	
	//取得影像
	UIImage *captureImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return captureImage;
}
/*
 + (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize	{
 
 //	UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
 //	[image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
 //	UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
 //	UIGraphicsEndImageContext();
 //	return reSizeImage;
 
 return [image resizedImage:reSize interpolationQuality:(kCGInterpolationDefault)];
 }
 */
+ (UIImage *)imageWithContentsOfFileByPNGNamed:(NSString *)imgName	{
	NSString * path = [[NSBundle mainBundle] pathForResource:imgName ofType:@"png"];
	return [UIImage imageWithContentsOfFile:path];
}
+ (UIImage *)imageWithContentsOfFileByJPGNamed:(NSString *)imgName	{
	NSString * path = [[NSBundle mainBundle] pathForResource:imgName ofType:@"png"];
	return [UIImage imageWithContentsOfFile:path];
}
- (UIImage *)imageWithCropToSquare	{
	
	CGFloat minSize = MIN(self.size.width, self.size.height);
	CGFloat maxSize = MAX(self.size.width, self.size.height);
	BOOL isLandscape = (maxSize == self.size.width);
	
	//	CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, [self bounds]);
	
	UIGraphicsBeginImageContext(CGSizeMake(maxSize, maxSize));
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(ctx, 0, maxSize);
	CGContextScaleCTM(ctx, 1, -1);
	
	CGRect rect = CGRectMake(0, 0, maxSize, maxSize);
	CGFloat offset = (maxSize-minSize)*0.5;
	if (isLandscape)	{
		rect.origin.y = offset;
		rect.size.height -=offset*2;
	}else	{
		rect.origin.x = offset;
		rect.size.width -=offset*2;
	}
	//	NSLog(@"LOG:  rect:%@", NSStringFromCGRect(rect));
	
	//background color
	//	[[UIColor blackColor] set];
	//	CGContextFillRect(ctx, CGRectMake(0, 0, maxSize, maxSize));
	CGContextDrawImage(ctx, rect, self.CGImage);
	
	UIImage * cropedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return cropedImage;
}
@end

@implementation UIImageView (InitMethods)
+ (UIImageView *)imageViewWithPNGNamed:(NSString *)imageName	{
	NSString * correctImageName = imageName;
	if ([correctImageName hasSuffix:@".png"]) {
		correctImageName = [imageName substringToIndex:imageName.length-4];
	}
	return [UIImageView imageViewWithNamed:correctImageName AndType:@"png"];
}
+ (UIImageView *)imageViewWithJPGNamed:(NSString *)imageName	{
	NSString * correctImageName = imageName;
	if ([correctImageName hasSuffix:@".jpg"]) {
		correctImageName = [imageName substringToIndex:imageName.length-4];
	}
	return [UIImageView imageViewWithNamed:correctImageName AndType:@"jpg"];
}

+ (UIImageView *)imageViewWithNamed:(NSString *)imageName AndType:(NSString *)imageType	{
	
	NSString * path = [[NSBundle mainBundle] pathForResource:imageName ofType:imageType];
	UIImage * img = [UIImage imageWithContentsOfFile:path];
	
	UIImageView * imgView = [[UIImageView alloc] initWithImage:img];
	return imgView;
}
@end



//---------------------------
#pragma mark -
@implementation UITableView (reloadMethods)	//update:20120420
-(void)reloadDataWithRowAnimation:(UITableViewRowAnimation)rowAnimation	{
	
	NSString *osversion = [UIDevice currentDevice].systemVersion;
	if ([osversion floatValue] >=4.3) {
		[self reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self numberOfSections])]
			withRowAnimation:rowAnimation
		 ];
	}else {
		//4.2及4.2以下 headerView上的UITextField裡的backgroundcolor或image 若用動畫,可能會有問題
		[self reloadData];
	}
}
@end



//---------------------------
static int indentLevelForLog = 0;		//for NSArray log

@implementation NSArray (Unicode)
- (NSString*)description
{
    NSMutableString *desc = [NSMutableString stringWithString:@"(\n"];
	indentLevelForLog++;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [desc appendFormat:@"	%@,\n",[obj description]];
    }];
	indentLevelForLog--;
	
	for (int i=0; i<indentLevelForLog; i++)		[desc appendString:@"	"];
    [desc appendString:@")"];
    return desc;
}
@end

@implementation NSDictionary (Unicode)
- (NSString*)description
{
    NSMutableString *desc = [NSMutableString stringWithString:@"{\n"];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [desc appendFormat:@"%@ = %@,\n",key,[obj description]];
    }];
    [desc appendString:@"}"];
    return desc;
}
@end



//---------------------------
#pragma mark -
@implementation NSDictionary (SortedKeys)
- (NSArray *)sortedKeys	{
	NSArray * keys = [[self allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		return [obj1 compare:obj2];
	}];
	return keys;
}
- (NSArray *)sortedKeysByDescending	{
	NSArray * keys = [[self allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		return [obj2 compare:obj1];
	}];
	return keys;
}
@end
//---------------------------
#pragma mark -
@implementation NSString (verifyCheck)
- (NSString *)getTrimmedVal
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)getTransformedNumberByAlphabet:(NSString *)alphabet	{
	NSDictionary * dic = [[NSDictionary alloc] initWithObjectsAndKeys:
						  @"10",@"A",
						  @"11",@"B",
						  @"12",@"C",
						  @"13",@"D",
						  @"14",@"E",
						  @"15",@"F",
						  @"16",@"G",
						  @"17",@"H",
						  
						  @"34",@"I",
						  
						  @"18",@"J",
						  @"19",@"K",
						  
						  @"21",@"M",
						  @"22",@"N",
						  @"35",@"O",
						  @"23",@"P",
						  @"24",@"Q",
						  
						  
						  @"27",@"T",
						  @"28",@"U",
						  @"29",@"V",
						  @"32",@"W",
						  @"30",@"X",
						  
						  @"33",@"Z",
						  
						  //已停發
						  @"20",@"L",
						  @"25",@"R",
						  @"26",@"S",
						  @"31",@"Y",
						  nil
						  ];
	
	NSString * number = [NSString stringWithString:[dic valueForKey:alphabet]];//		[dic release];
	
	return number;
}
- (BOOL)verifyROCPersonalID	{
	
	// 檢核身分證字號 或 統一証號
	BOOL isPID_OK = NO;
	NSString * strPID = [self uppercaseString];
	
	if ([strPID length] != 10) {
		isPID_OK = NO;
		
	}else if ([ALUtilities checkUnicharIsAlphabetic:[strPID characterAtIndex:0]]				//前一碼為英文，其餘為數字
			  && [ALUtilities checkStringIsAllNumeric: [strPID substringFromIndex:1] ] ) {
		
		//10碼中僅第一碼為字母者	可能為中華民國身分證統一編號,以身分證字號檢核規則進行檢核
		NSString * transformedNumber = [NSString getTransformedNumberByAlphabet:[strPID substringToIndex:1]];
		strPID = [transformedNumber stringByAppendingString:[strPID substringFromIndex:1]];
		int checkNumbers[11] = {1,9,8,7,6,5,4,3,2,1,1};
		
		int num = 0;
		for (int i = 0; i<11; i++) {
			num += [[strPID substringWithRange:NSMakeRange(i, 1)] intValue] * checkNumbers[i];
		}
//		NSLog(@"LOG:  num: %i",num);
		if ( (num %10) == 0) {
			isPID_OK = YES;
		}
		
	} else if ( [ALUtilities checkUnicharIsAlphabetic:[strPID characterAtIndex:0]]			//前兩碼為英文，其餘為數字
			   && [ALUtilities checkUnicharIsAlphabetic:[strPID characterAtIndex:1]]
			   && [ALUtilities checkStringIsAllNumeric: [strPID substringFromIndex:2]] ) {
		//10碼中有字母、數字者		應為外籍人士之統一証號,以統一證號檢核規則進行檢核
		NSString * transformedNumber1 = [NSString getTransformedNumberByAlphabet:[strPID substringToIndex:1]];
		NSString * transformedNumber2 = [NSString getTransformedNumberByAlphabet:[strPID substringWithRange:NSMakeRange(1, 1)]];
		NSString * lastNumber = [strPID substringWithRange:NSMakeRange([strPID length]-1, 1)];
		if ([transformedNumber2 length]>=2) //取尾數
			transformedNumber2 = [transformedNumber2 substringWithRange:NSMakeRange([transformedNumber2 length]-1, 1)];
		
		strPID = [[transformedNumber1 stringByAppendingString:transformedNumber2] stringByAppendingString: [strPID substringWithRange:NSMakeRange(2, 7)] ];
		int checkNumbers[10] = {1,9,8,7,6,5,4,3,2,1};
		int num = 0;
		for (int i = 0; i<10; i++) {
			int tmp = [[strPID substringWithRange:NSMakeRange(i, 1)] intValue] * checkNumbers[i];
			tmp = tmp%10;	//只取個位數
			num += tmp;
		}
//		NSLog(@"LOG:  num: %i",num);
		num = num%10;
		if (num !=0) {
			num = 10 -num;
		}
		
		if (num == [lastNumber intValue]) {
			isPID_OK = YES;
		}
		
	}// [END]  身分證 或 統一証號
	
	
	return isPID_OK;
}

@end



//---------------------------
#pragma mark -

@implementation UILabel (alignTop)
//http://fstoke.me/blog/?p=2819
// adjust the height of a multi-line label to make it align vertical with top
- (void) alignLabelWithTop {
	UILabel * label = self;
	
	CGSize maxSize = CGSizeMake(label.frame.size.width, 999);
	label.adjustsFontSizeToFitWidth = NO;
	
	// get actual height
	CGSize actualSize = [label.text sizeWithFont:label.font constrainedToSize:maxSize lineBreakMode:label.lineBreakMode];
	CGRect rect = label.frame;
	rect.size.height = actualSize.height;
	label.frame = rect;
}
@end



//---------------------------
#pragma mark -
@implementation NSDate (theSameDay)
//http://blog.sina.com.cn/s/blog_672af4e20100wbc7.html
- (BOOL)isSameDay:(NSDate*)date2
{
	NSDate * date1 = self;
	
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

@end



//---------------------------
#pragma mark -
@implementation NSDictionary (jsonString)
- (NSString *)jsonString	{
	NSError * err;
	NSData * jsonData = [NSJSONSerialization dataWithJSONObject:self options:(0) error:&err];
	NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	if (!jsonString || err) {
		NSLog(@"LOG:  err: %@",err);
		return nil;
	}
	return jsonString;
}
@end

@implementation NSArray (jsonString)
- (NSString *)jsonString	{
	NSError * err;
	NSData * jsonData = [NSJSONSerialization dataWithJSONObject:self options:(0) error:&err];
	NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	if (!jsonString || err) {
		NSLog(@"LOG:  err: %@",err);
		return nil;
	}
	return jsonString;
}
@end

@implementation NSString (jsonDic)
- (id)jsonDic	{	//NSDictionary * or NSArray *
	NSError * err;
	id jsonDic = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:(NSJSONReadingAllowFragments) error:&err];
	if (!jsonDic || err) {
		NSLog(@"LOG:  err: %@",err);
		return nil;
	}
	return jsonDic;
}
@end

@implementation NSData (NSDataToUTF8String)
- (NSString *)string		{
	NSString * string = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
	return string;
}
@end

@implementation NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
																				 (CFStringRef)self,
																				 NULL,
																				 (CFStringRef)@"!*'\"();@+$,#[]% ",//@"!*'\"();:@&=+$,/?%#[]% "
																				 CFStringConvertNSStringEncodingToEncoding(encoding)));
}
@end



//---------------------------
#pragma mark -