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
 *  Description:  TabletNoticeVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>

@interface zt_TabletNoticeVC : UIViewController
{
    NSString *m_NoticeStr;
    NSString *m_TitleStr;
    IBOutlet UILabel *m_lblNotice;
}

- (void)updateNoticeUI;
- (void)setNotice:(NSString*)notice withTitle:(NSString*)title;

@end
