/******************************************************************************
 *
 *       Copyright Zebra Technologies, Inc. 2014 - 2015
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Zebra Technologies
 *       Confidential Proprietary Information.
 *
 *
 *  Description:  AlertView.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface zt_AlertView : NSObject
{
    
}

- (void)showAlertWithView:(UIView *)targetView withTarget:(id)target withMethod:(SEL)method withObject:(id)object withString:(NSString *)message;
- (void)showDetailedAlertWithView:(UIView *)targetView withTarget:(id)target withMethod:(SEL)method withObject:(id)object withHeader:(NSString *)header withDetails:(NSString*)details;
- (void)showSuccessFailure:(UIView *)targetView isSuccess:(BOOL)success;
- (void)showSuccessFailureWithText:(UIView *)targetView isSuccess:(BOOL)success aSuccessMessage:(NSString*)success_message aFailureMessage:(NSString*)failure_message;
- (void)showWarningText:(UIView *)targetView withString:(NSString *)warning;

+ (void)showInfoMessage:(UIView *)targetView withHeader:(NSString *)header withDetails:(NSString*)details withDuration:(int)duration;
- (void)show:(UIView *)targetView;
- (void)hide;

@end
