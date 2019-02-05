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
 *  Description:  BarcodeEventVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "BarcodeEventVC.h"
#import "SbtSdkDefs.h"
#import "BarcodeTypes.h"

@interface zt_BarcodeEventVC ()

@end

@implementation zt_BarcodeEventVC

/* default cstr for storyboard */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_Child = NO;
        m_ScannerID = SBT_SCANNER_ID_INVALID;
    }
    return self;
}

- (void)dealloc
{
    [m_lblScannerID release];
    [m_lblBarcodeType release];
    [m_lblBarcodeData release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Barcode Details";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateBarcodeUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateBarcodeUI];
}

- (void)viewDidLayoutSubviews
{
    dispatch_async(dispatch_get_main_queue(), ^{
        m_lblBarcodeData.preferredMaxLayoutWidth = m_lblBarcodeData.bounds.size.width;
    });
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureAsChild
{
    m_Child = YES;
}

- (BOOL)isChildOfActiveVC
{
    return m_Child;
}

- (void)setBarcodeEventData:(zt_BarcodeData*)barcodeData fromScanner:(int)scannerID
{
    m_ScannerID = scannerID;
    m_BarcodeData = barcodeData;
    [self updateBarcodeUI];
}
- (void)dismissAction
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateBarcodeUI
{
    [m_lblScannerID setText:[NSString stringWithFormat:@"%d", m_ScannerID]];
    [m_lblBarcodeType setText:[NSString stringWithFormat:@"%@", get_barcode_type_name([m_BarcodeData getDecodeType])]];
    [m_lblBarcodeData setText:[m_BarcodeData getDecodeDataAsStringUsingEncoding:NSUTF8StringEncoding]];
}

@end
