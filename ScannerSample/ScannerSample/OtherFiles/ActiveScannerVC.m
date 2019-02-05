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
 *  Description:  ActiveScannerVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "ActiveScannerVC.h"
#import "ActiveScannerBarcodeVC.h"
#import "config.h"
//#import "ScannersTableVC.h"

@interface zt_ActiveScannerVC ()

@end

@implementation zt_ActiveScannerVC

/* default cstr for storyboard */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_ScannerID = SBT_SCANNER_ID_INVALID;
        m_WillDisappear = NO;
        [[zt_ScannerAppEngine sharedAppEngine] addDevConnectionsDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[zt_ScannerAppEngine sharedAppEngine] removeDevConnectiosDelegate:self];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setTitle:@"Active Scanner"];
    [[zt_ScannerAppEngine sharedAppEngine] previousScannerpreviousScanner:0];
	
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    [back autorelease];
    self.navigationItem.backBarButtonItem = back;

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setScannerID:(int)scannerID
{
    m_ScannerID = scannerID;

    SbtScannerInfo *scanner_info = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID:m_ScannerID];
    
    /* Hide unsupported Image&Video tab for scanners that do not support it */
    if ([scanner_info getScannerModel] == SBT_DEVMODEL_SSI_CS4070  ||
        [scanner_info getScannerModel] == SBT_DEVMODEL_SSI_RFD8500 ||
        [scanner_info getScannerModel] == SBT_DEVMODEL_SSI_LI3678  ||
        [scanner_info getScannerModel] == SBT_DEVMODEL_SSI_DS2278  ||
        [scanner_info getScannerModel] == SBT_DEVMODEL_SSI_DS3678  ||
        [scanner_info getScannerModel] == SBT_DEVMODEL_SSI_DS8178)
    {
        NSMutableArray *vc = [[NSMutableArray alloc] init];
        //[vc addObject:[[self viewControllers] objectAtIndex:1]]; /* info tab */
        //[vc addObject:[[self viewControllers] objectAtIndex:1]]; /* decode tab */
        //[vc addObject:[[self viewControllers] objectAtIndex:3]]; /* settings tab tab */
        [self setViewControllers:vc];
        [vc removeAllObjects];
        [vc release];
    }
}

- (int)getScannerID
{
    return m_ScannerID;
}

- (void)showBarcode
{
    [self showBarcodeList];
    [(zt_ActiveScannerBarcodeVC*)[self selectedViewController] showBarcode];
}

- (void)showBarcodeList
{
    /* it should be barcode view controller */
    [self setSelectedViewController:[self.viewControllers objectAtIndex:1]];
}

- (void)showSettingsPage
{
    [self setSelectedViewController:[self.viewControllers objectAtIndex:2]];
}

/* ###################################################################### */
/* ########## IScannerAppEngineDevConnectionsDelegate Protocol implementation ## */
/* ###################################################################### */
- (BOOL)scannerHasAppeared:(int)scannerID
{
    /* should not matter */
    return NO; /* we have not processed the notification */
}

- (BOOL)scannerHasDisappeared:(int)scannerID
{
    if (scannerID == m_ScannerID)
    {
        /*
         // All alerts are in ScannerAppEngine
        UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:MOT_SCANNER_APP_NAME
                          message:@"Active scanner has disappeared"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
        [alert show];
        [alert release];
         */
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            /* iphone */
            for (UIViewController *vc in [self.navigationController viewControllers])
            {
//                if ([vc isKindOfClass:[zt_ScannersTableVC class]] == YES)
//                {
//                    /* nrv364:
//                     we should pop exactly to scanner list view controller
//                     it is actual for active scanner VC as active scanner VC could be
//                     not on the top of stack (e.g. symbologies or beeper/led action vc
//                     could be presented)
//                     as available scanner VC should be always on top of navigation
//                     stack, the available scanner VC may just pop itself
//                     */
//                    if (NO == m_WillDisappear)
//                    {
//                        m_WillDisappear = YES;
//                        [self.navigationController popToViewController:vc animated:YES];
//                    }
//
//                }
            }
        }
        else
        {
            /* ipad */
            /* do nothing; all logic is in ScannersTableVC */
        }
        return YES; /* we have processed the notification */
    }
    return NO; /* we have not processed the notification */
}

- (BOOL)scannerHasConnected:(int)scannerID
{
    /* should not matter */
    return NO; /* we have not processed the notification */
}

- (BOOL)scannerHasDisconnected:(int)scannerID
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        for (UINavigationController *nav in [self.splitViewController viewControllers]) {
            nav.view.userInteractionEnabled = YES;
            for (UIViewController *vc in [nav viewControllers]) {
                vc.view.userInteractionEnabled = YES;
            }
        }
    }
    if (scannerID == m_ScannerID)
    {
        /*
         // All alerts are in ScannerAppEngine
        UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:MOT_SCANNER_APP_NAME
                          message:@"Communication session has been terminated"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
        [alert show];
        [alert release];
         */
    
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            /* iphone */
            for (UIViewController *vc in [self.navigationController viewControllers])
            {
//                if ([vc isKindOfClass:[zt_ScannersTableVC class]] == YES)
                
                
                  
//                {
//                    /* nrv364:
//                        we should pop exactly to scanner list view controller
//                        it is actual for active scanner VC as active scanner VC could be
//                        not on the top of stack (e.g. symbologies or beeper/led action vc
//                        could be presented)
//                        as available scanner VC should be always on top of navigation
//                        stack, the available scanner VC may just pop itself
//                     */
//                    /* after disconnection available vc will be shown with animation;
//                     the animated poping will cause UI degradation */
//
//                    if (NO == m_WillDisappear)
//                    {
//                        m_WillDisappear = YES;
//                        [self.navigationController popToViewController:vc animated:NO];
//                    }
//                }
            }
        }
        else
        {
            /* ipad */
            /* do nothing; all logic is in ScannersTableVC */
        }
        return YES; /* we have processed the notification */
    }
    return NO; /* we have not processed the notification */
}

@end
