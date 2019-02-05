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
 *  Description:  ScannersTableVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import <ExternalAccessory/ExternalAccessory.h>
#import "ConnectionManager.h"
#import "ScannersTableVC.h"
#import "ActiveScannerVC.h"
#import "TabletNoticeVC.h"
#import "AppSettingsKeys.h"
#import "config.h"
#import "ActiveScannerBarcodeVC.h"
#import "ScannerSample-Bridging-Header.h"
#import "ScannerSample-Swift.h"


@interface zt_ScannersTableVC () {
    BOOL didDisplayNoScannerFoundUI;
}

@property (nonatomic, retain) NSArray *m_tableData;
@end

@implementation zt_ScannersTableVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_EmptyDeviceList = YES;
        
        self.m_tableData = [[NSArray alloc] init];
        
        m_CurrentScannerActive = NO;
        m_CurrentScannerId = SBT_SCANNER_ID_INVALID;
        
        m_btnUpdateDevList = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(btnUpdateScannersListPressed)];
        
        [[zt_ScannerAppEngine sharedAppEngine] addDevListDelegate:self];
        [[zt_ScannerAppEngine sharedAppEngine] addDevConnectionsDelegate:self];

    }
    return self;
}

- (void)dealloc
{
    [[zt_ScannerAppEngine sharedAppEngine] removeDevListDelegate:self];
    [[zt_ScannerAppEngine sharedAppEngine] removeDevConnectiosDelegate:self];
    
    [self.tableView setDataSource:nil];
    [self.tableView setDelegate:nil];

    if (m_btnUpdateDevList != nil)
    {
        [m_btnUpdateDevList release];
    }
    
    if (self.m_tableData != nil)
    {
        [self.m_tableData release];
    }
    
    if (activityView != nil)
    {
        [activityView release];
    }
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Initialize the connection manager
    [ConnectionManager sharedConnectionManager];
 
    activityView = [[zt_AlertView alloc]init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /* just to reload data from app engine */
    
    [self scannersListHasBeenUpdated];
    
    /* 
        configure [UPD] button in accordance with app settings:
            - hide if detection, available and active notifications 
                are enabled
            - otherwise show
     
     */
    
    NSMutableArray *right_items = [[NSMutableArray alloc] init];
    
    BOOL hide = YES;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_SCANNER_DETECTION] == NO)
    {
        hide = NO;
    }
    
    if ((YES == hide) && ([[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_EVENT_ACTIVE] == NO))
    {
        hide = NO;
    }
    
    if ((YES == hide) && ([[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_EVENT_AVAILABLE] == NO))
    {
        hide = NO;
    }
    
    if (NO == hide)
    {
        [right_items addObject:m_btnUpdateDevList];
    }
    
    hide = YES;
    NSInteger op_mode = [[NSUserDefaults standardUserDefaults] integerForKey:ZT_SETTING_OPMODE];
    
    switch (op_mode)
    {
        case SBT_OPMODE_MFI:
            hide = NO;
            break;
        case SBT_OPMODE_BTLE:
            hide = YES;
            break;
        case SBT_OPMODE_ALL:
            hide = NO;
            break;
    }
    
    if ([right_items count] == 0)
    {
        self.navigationItem.rightBarButtonItems = nil;
    }
    else
    {
        self.navigationItem.rightBarButtonItems = right_items;
    }
    
    [right_items removeAllObjects];
    [right_items release];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        for (UINavigationController *nav in [self.splitViewController viewControllers]) {
            nav.view.userInteractionEnabled = YES;
            for (UIViewController *vc in [nav viewControllers]) {
                vc.view.userInteractionEnabled = YES;
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showActiveScannerVC:(NSNumber*)scannerID aBarcodeView:(BOOL)barcodeView aAnimated:(BOOL)animated
{
    int scanner_id = [scannerID intValue];
    
    m_CurrentScannerId = scanner_id;
    m_CurrentScannerActive = YES;
    if([[zt_ScannerAppEngine sharedAppEngine] firmwareDidUpdate] && [[zt_ScannerAppEngine sharedAppEngine] previousScannerId] == scanner_id) {
        
    
//        UpdateFirmwareVC *active_vc = nil;
//
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//        {
//            active_vc = (UpdateFirmwareVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SCANNER_FWUPDATE_DAT_VC"];
//        }
//        else
//        {
//            active_vc = (UpdateFirmwareVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SCANNER_FWUPDATE_DAT_VC"];
//        }
        
//        if (active_vc != nil)
//        {
//            [active_vc setScannerID:scanner_id];
//            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//            {
//                UINavigationController *detail_vc = (UINavigationController*)[[self.splitViewController viewControllers] objectAtIndex:1];
//                [detail_vc pushViewController:active_vc animated:animated];
//            }
//            else
//            {
//                [self.navigationController pushViewController:active_vc animated:animated];
//            }
//            
//            // active_vc is autoreleased object returned by instantiateViewControllerWithIdentifier
//            // TBD: shouldn't be released, but without this is not deallocated
//            [active_vc release];
//        }

    } else {
//        zt_ActiveScannerVC *active_vc = nil;
//        
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//        {
//            active_vc = (zt_ActiveScannerVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_ACTIVE_SCANNER_VC"];
//        }
//        else
//        {
//            active_vc = (zt_ActiveScannerVC*)[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_ACTIVE_SCANNER_VC"];
//        }
//        
//        if (active_vc != nil)
//        {
//            [active_vc setScannerID:scanner_id];
//            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//            {
//                UINavigationController *detail_vc = (UINavigationController*)[[self.splitViewController viewControllers] objectAtIndex:1];
//                [detail_vc setViewControllers:[NSArray arrayWithObjects:active_vc, nil] animated:NO];
//            }
//            else
//            {
//                [self.navigationController pushViewController:active_vc animated:animated];
//            }
//            
//            if (YES == barcodeView)
//            {
//                [active_vc showBarcodeList];
//            }
//            
//            // active_vc is autoreleased object returned by instantiateViewControllerWithIdentifier
//            // TBD: shouldn't be released, but without this is not deallocated
//            [active_vc release];
//        }
        
        BarCodeList *active_vc1 = (BarCodeList*)[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"BarCodeList"];
        
        [self.navigationController presentViewController:active_vc1 animated:false completion:nil];

        
    }
}

- (void)btnUpdateScannersListPressed
{
    /* 
     nrv364:
        just to avoid following situations:
        - active VC is shown
        - notifications are turned off
        - active disappears
        - new available appears
        - user press upd button
        - as appeared available scanner has the same id as disappeared
        active one, then in accordance with scannersListHasBeenUpdated
        availble VC will be presented
     */
    m_CurrentScannerId = SBT_SCANNER_ID_INVALID;
    m_btnUpdateDevList.enabled = false;
    [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(updateScannersList) withObject:nil withString:@"Updating..."];

    usleep(10*1000);
    [self scannersListHasBeenUpdated];
    
}

- (void)updateScannersList
{
    [[zt_ScannerAppEngine sharedAppEngine] updateScannersList];
    m_btnUpdateDevList.enabled = true;
}

/* ###################################################################### */
/* ########## IScannerAppEngineDevListDelegate Protocol implementation ## */
/* ###################################################################### */
- (BOOL)scannersListHasBeenUpdated
{
    [[self tableView] reloadData];
    
    /* for iPad only:
     - if we have no scanners we should show some notice in detail 
     view of split view controller 
     - if we have some scanners - we should select one to display info
     about it in detail view of split view controller
     */
    
    self.m_tableData = [[zt_ScannerAppEngine sharedAppEngine] getAvailableScannersList];

    [[self tableView] reloadData];
    
    if ([self.m_tableData count] > 0)
    {
        /* for iPad only: we should select some row in master view to show smth in
         detail view of split view controller */
        
        /* determine actual status of previously selected scanner */
        NSArray *lst = self.m_tableData;
        BOOL found = NO;
        int selected_scanner_idx = 0;
        SbtScannerInfo *info = nil;
        for (int i = 0; i < [lst count]; i++)
        {
            info = (SbtScannerInfo*)[lst objectAtIndex:i];

            if ([info isActive])
            {
                /* previously selected scanner is still at least available */
                /* get new idx of previously selected scanner */
                selected_scanner_idx = i;
                found = YES;
                break;
            }
        }
        
        if (YES == found)
        {
            info = (SbtScannerInfo*)[lst objectAtIndex:selected_scanner_idx];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                if ([info isActive] != m_CurrentScannerActive)
                {
                    [[self tableView] selectRowAtIndexPath:[NSIndexPath indexPathForRow:selected_scanner_idx inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
                    
                    // ipad
                    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:selected_scanner_idx inSection:0]];
                }
                else
                {
                    // iphone
                    [[self tableView] selectRowAtIndexPath:[NSIndexPath indexPathForRow:selected_scanner_idx inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
                    if (didDisplayNoScannerFoundUI) {
                        didDisplayNoScannerFoundUI = NO;
                        [self showActiveScannerVC:[NSNumber numberWithInt:[info getScannerID]] aBarcodeView:NO aAnimated:YES];
                    }
                }
            }
        }
        else
        {
            /* previously selected scanner is not available now */
            /* iphone -> show scanner list */
            /* ipad -> select just first scanner in the list */
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                /* ipad */
                zt_TabletNoticeVC *notice_vc = (zt_TabletNoticeVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_NOTICE_VC"];
                if (notice_vc != nil)
                {
                    [notice_vc setNotice:@"Select a scanner." withTitle:@"Scanners"];
                    
                    UINavigationController *detail_vc = (UINavigationController*)[[self.splitViewController viewControllers] objectAtIndex:1];
                    [detail_vc setViewControllers:[NSArray arrayWithObjects:notice_vc, nil] animated:NO];
                    
                }
            }

        }
    }
    else
    {
        m_CurrentScannerId = SBT_SCANNER_ID_INVALID;
       
        /* ipad -> show notice vc in details view */
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            /* ipad */
            zt_TabletNoticeVC *notice_vc = (zt_TabletNoticeVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_NOTICE_VC"];
            if (notice_vc != nil)
            {
                [notice_vc setNotice:@"Scanners are not found." withTitle:@"Scanners"];
                
                UINavigationController *detail_vc = (UINavigationController*)[[self.splitViewController viewControllers] objectAtIndex:1];
                [detail_vc setViewControllers:[NSArray arrayWithObjects:notice_vc, nil] animated:NO];
                didDisplayNoScannerFoundUI = YES;
            }
        }
    }
    
    return YES;
}

#pragma mark - Table view data source
/* ###################################################################### */
/* ########## Table View Data Source Delegate Protocol implementation ### */
/* ###################################################################### */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [self.m_tableData count];
    if (count == 0)
    {
        count = 1;
        m_EmptyDeviceList = YES;
        m_CurrentScannerId = SBT_SCANNER_ID_INVALID;
    }
    else
    {
        m_EmptyDeviceList = NO;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ActiveScannerCellIdentifier = @"ActiveScannerCell";
    static NSString *AvailableScannerCellIdentifier = @"AvailableScannerCell";
    static NSString *NoScannerCellIdentifier = @"NoScannerCell";
    
    UITableViewCell *cell = nil;
    
    if (m_EmptyDeviceList == NO)
    {
        SbtScannerInfo *info = [self.m_tableData objectAtIndex:(int)[indexPath row]];
        
        if ([info isActive] == YES)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:ActiveScannerCellIdentifier];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ActiveScannerCellIdentifier];
            }
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",@"\u2713",[info getScannerName]];
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:AvailableScannerCellIdentifier];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AvailableScannerCellIdentifier];
            }
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",@"\u2001",[info getScannerName]];
        }
        
        switch ([info getConnectionType])
        {
            case SBT_CONNTYPE_MFI:
                cell.detailTextLabel.text = @"MFi";
                break;
            case SBT_CONNTYPE_BTLE:
                cell.detailTextLabel.text = @"BT LE";
                break;
            default:
                cell.detailTextLabel.text = @"Unknown type";
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:NoScannerCellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NoScannerCellIdentifier];
        }
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.textLabel.text = [NSString stringWithFormat:@"No device connected"];

    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate
/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        /* iphone - clear all selections */
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell != nil)
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    else
    {
        /* 
         ipad:
            - do not clear selection of scanner related cells 
            - clear selection of "no scanners" cell
         */
        if (m_EmptyDeviceList == YES)
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (cell != nil)
            {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
    }
    
    if (m_EmptyDeviceList == NO)
    {
        SbtScannerInfo *info = [self.m_tableData objectAtIndex:(int)[indexPath row]];
        
        if ([info isActive] == YES)
        {
            [self showActiveScannerVC:[NSNumber numberWithInt:[info getScannerID]] aBarcodeView:NO aAnimated:YES];
        }
        else
        {
            // attempt to connect to selected scanner
            [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(connectToScanner:) withObject:info withString:@"Connecting..."];
        }
    }
}

- (void) connectToScanner :(SbtScannerInfo *)scannerInfo
{
    [[ConnectionManager sharedConnectionManager] connectDeviceUsingScannerId:[scannerInfo getScannerID]];
}

/* ###################################################################### */
/* ########## IScannerAppEngineDevConnectionsDelegate Protocol implementation ## */
/* ###################################################################### */
- (BOOL)scannerHasAppeared:(int)scannerID
{
    /* does not matter */
    return NO; /* we have not processed the notification */
}

- (BOOL)scannerHasDisappeared:(int)scannerID
{
    /* does not matter */
    return NO; /* we have not processed the notification */
}

- (BOOL)scannerHasConnected:(int)scannerID
{
    [self showActiveScannerVC:[NSNumber numberWithInt:scannerID] aBarcodeView:NO aAnimated:YES];
    
    return YES; /* we have processed the notification */


}

- (BOOL)scannerHasDisconnected:(int)scannerID
{
    /* does not matter */
    return NO; /* we have not processed the notification */
}


@end
