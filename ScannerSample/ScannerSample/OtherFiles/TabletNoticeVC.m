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
 *  Description:  TabletNoticeVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "TabletNoticeVC.h"

@interface zt_TabletNoticeVC ()

@end

@implementation zt_TabletNoticeVC

/* default cstr for storyboard */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_NoticeStr = [[NSString alloc] initWithString:@"Welcome notice"];
        m_TitleStr = [[NSString alloc] initWithString:@"Notice"];
        [self updateNoticeUI];
    }
    return self;
}


- (void)dealloc
{
    if (m_NoticeStr != nil)
    {
        [m_NoticeStr release];
    }
    if (m_TitleStr != nil)
    {
        [m_TitleStr release];
    }
    [m_lblNotice release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateNoticeUI];
}

- (void)updateNoticeUI
{
    if (m_NoticeStr != nil)
    {
        [m_lblNotice setText:m_NoticeStr];
    }
    else
    {
        [m_lblNotice setText:@""];
    }
    
    if (m_TitleStr != nil)
    {
        [self setTitle:m_TitleStr];
    }
    else
    {
        [self setTitle:@"Notice"];
    }
}

- (void)setNotice:(NSString*)notice withTitle:(NSString*)title
{
    if (m_NoticeStr != nil)
    {
        [m_NoticeStr release];
        m_NoticeStr = nil;
    }
    
    if (m_TitleStr != nil)
    {
        [m_TitleStr release];
        m_TitleStr = nil;
    }
    
    m_NoticeStr = [[NSString alloc] initWithFormat:@"%@", notice];
    m_TitleStr = [[NSString alloc] initWithFormat:@"%@", title];

    [self updateNoticeUI];
}

@end
