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
 *  Description:  AlertView.m
 *
 *  Notes:
 *
 ******************************************************************************/
#import "AlertView.h"
#import "MBProgressHUD.h"

@interface zt_AlertView () <MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

@end

@implementation zt_AlertView

- (void)showAlertWithView:(UIView *)targetView withTarget:(id)target withMethod:(SEL)method withObject:(id)object withString:(NSString *)message
{
    HUD = [[MBProgressHUD alloc] initWithView:targetView];
    [targetView addSubview:HUD];
    
    HUD.delegate = self;
    HUD.labelText = message;
    HUD.square = YES;
    

    [HUD showWhileExecuting:method onTarget:target withObject:object animated:YES];
}

- (void)showDetailedAlertWithView:(UIView *)targetView withTarget:(id)target withMethod:(SEL)method withObject:(id)object withHeader:(NSString *)header withDetails:(NSString*)details
{
    HUD = [[MBProgressHUD alloc] initWithView:targetView];
    [targetView addSubview:HUD];
    
    HUD.delegate = self;
    HUD.labelText = header;
    HUD.detailsLabelText = details;
    HUD.square = YES;
    
    [HUD showWhileExecuting:method onTarget:target withObject:object animated:YES];
}

- (void)showSuccessFailure:(UIView *)targetView isSuccess:(BOOL)success {
    
    HUD = [[MBProgressHUD alloc] initWithView:targetView];
    [targetView addSubview:HUD];
    
    // Set custom view mode
    HUD.mode = MBProgressHUDModeCustomView;
    
    HUD.delegate = self;
    if(success)
    {
        HUD.labelText = @"Success";
    }
    else
    {
        HUD.labelColor = [UIColor redColor];
        HUD.labelText = @"Failure";
    }
    
    
    [HUD show:YES];
    [HUD hide:YES afterDelay:1];
}

- (void)showSuccessFailureWithText:(UIView *)targetView isSuccess:(BOOL)success aSuccessMessage:(NSString*)success_message aFailureMessage:(NSString*)failure_message
{
    HUD = [[MBProgressHUD alloc] initWithView:targetView];
    [targetView addSubview:HUD];
    
    // Set custom view mode
    HUD.mode = MBProgressHUDModeCustomView;
    
    HUD.delegate = self;
    if(success)
    {
        HUD.labelText = success_message;
    }
    else
    {
        HUD.labelColor = [UIColor redColor];
        HUD.labelText = failure_message;
    }
    
    
    [HUD show:YES];
    [HUD hide:YES afterDelay:1];
}

- (void)showWarningText:(UIView *)targetView withString:(NSString *)warning {
    
    HUD = [MBProgressHUD showHUDAddedTo:targetView animated:YES];
    
    // Configure for text only and offset down
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = warning;
    HUD.margin = 10.f;
    HUD.removeFromSuperViewOnHide = YES;


    [HUD hide:YES afterDelay:3];
}

- (void)show:(UIView *)targetView {
    
    HUD = [MBProgressHUD showHUDAddedTo:targetView animated:YES];
    
    [HUD show:YES];
}

- (void)hide {
    if (HUD) {
        [HUD show:NO];
        [HUD hide:YES afterDelay:0];
    }
}

+ (void)showInfoMessage:(UIView *)targetView withHeader:(NSString *)header withDetails:(NSString*)details withDuration:(int)duration
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:targetView animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = header;
    hud.detailsLabelText = details;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:duration];
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    HUD = nil;
}

@end
