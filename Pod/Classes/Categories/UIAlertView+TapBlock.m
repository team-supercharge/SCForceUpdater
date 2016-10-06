//
//  UIAlertView+TapBlock.m
//  Pods
//
//  Created by Richard Szabo on 10/6/16.
//
//

#import "UIAlertView+TapBlock.h"

#import <objc/runtime.h>

static const void *UIAlertViewOriginalDelegateKey = &UIAlertViewOriginalDelegateKey;
static const void *UIAlertViewTapBlockKey         = &UIAlertViewTapBlockKey;

@implementation UIAlertView (TapBlock)

#pragma mark - Override
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self _checkAlertViewDelegate];
    UIAlertViewTapBlock tapBlock = alertView.tapBlock;

    if (tapBlock)
    {
        tapBlock(alertView, buttonIndex);
    }

    id originalDelegate = objc_getAssociatedObject(self, UIAlertViewOriginalDelegateKey);
    if ([originalDelegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
    {
        [originalDelegate alertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

- (UIAlertViewTapBlock)tapBlock
{
    return objc_getAssociatedObject(self, UIAlertViewTapBlockKey);
}

- (void)setTapBlock:(UIAlertViewTapBlock)tapBlock
{
    [self _checkAlertViewDelegate];
    objc_setAssociatedObject(self, UIAlertViewTapBlockKey, tapBlock, OBJC_ASSOCIATION_COPY);
}

#pragma mark -
- (void)_checkAlertViewDelegate
{
    if (self.delegate != (id<UIAlertViewDelegate>)self)
    {
        objc_setAssociatedObject(self, UIAlertViewOriginalDelegateKey, self.delegate, OBJC_ASSOCIATION_ASSIGN);
        self.delegate = (id<UIAlertViewDelegate>)self;
    }
}

@end
