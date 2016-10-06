//
//  UIAlertView+TapBlock.h
//  Pods
//
//  Created by Richard Szabo on 10/6/16.
//
//

#import <UIKit/UIKit.h>

typedef void (^UIAlertViewTapBlock)(UIAlertView *alertView, NSInteger buttonIndex);

@interface UIAlertView (TapBlock)

@property (nonatomic, copy) UIAlertViewTapBlock tapBlock;

@end
