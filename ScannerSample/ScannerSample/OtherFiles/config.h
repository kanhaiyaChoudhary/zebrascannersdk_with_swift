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
 *  Description:  config.h
 *
 *  Notes:
 *
 ******************************************************************************/

#ifndef __CONFIG_H__
#define __CONFIG_H__


#define ZT_SCANNER_APP_NAME                        @"Zebra Scanner Control"
#define ZT_SCANNER_DEVICE_NAME_PATTERN_RFD8500     @"RFD*"
#define ZT_SCANNER_DEVICE_NAME_PATTERN_CS4070      @"CS*"
#define ZT_INFO_SCANNER_APP_NAME                   @"Zebra Scanner Control"
#define ZT_INFO_SCANNER_SDK_NAME                   @"Zebra Scanner SDK"
#define ZT_INFO_COPYRIGHT_TEXT                     @" ZIH Corp and/or its affiliates. All rights reserved. Zebra and the stylized Zebra head are trademarks of ZIH Corp., registered in many jurisdictions worldwide. All other trademarks are the property of their respective owners."
#define ZT_INFO_COPYRIGHT_YEAR                     @"©2015"
#define ZT_UPDATE_FW_BTN_TITLE                     @"UPDATE FIRMWARE"
#define ZT_UPDATE_FW_BTN_TITLE_UPDATED             @"✓ FIRMWARE UPDATED"
#define ZT_UPDATE_FW_VIEW_TITLE_UPDATING           @"Updating Firmware"
#define ZT_UPDATE_FW_VIEW_TITLE_REBOOTING          @"Rebooting Scanner"
#define ZT_FW_FILE_DIRECTIORY_NAME                 @"Download"
#define ZT_FW_FILE_EXTENTION                       @"DAT"
#define ZT_PLUGIN_FILE_EXTENTION                   @"SCNPLG"
#define ZT_RELEASE_NOTES_FILE_EXTENTION            @"txt"
#define ZT_METADATA_FILE                           @"Metadata.xml"
#define ZT_MODEL_LIST_TAG                          @"models"
#define ZT_MODEL_TAG                               @"model"
#define ZT_REVISION_TAG                            @"revision"
#define ZT_RELEASED_DATE_TAG                       @"release-date"
#define ZT_FAMILY_TAG                              @"family"
#define ZT_NAME_TAG                                @"name"
#define ZT_FIRMWARE_NAME_TAG                       @"combined-firmware"
#define ZT_RELEASE_DATE_LBL_PREFIX                 @"To Release "
#define ZT_PICTURE_FILE_NAME                       @"picture"
#define FW_PAGE_CONTENT_ONE                        @"Firmware Update Process Help"
#define FW_PAGE_CONTENT_ONE_SECOND                 @"Copy the correct 123Scan plug-in for your scanner to your phone"
#define FW_PAGE_CONTECT_THREE                      @"Load 123Scan onto a Windows computer from"
#define FW_PAGE_CONTECT_THREE_URL_REAL             @"https://www.zebra.com/ap/en/products/software/scanning-systems/scanner-drivers-and-utilities/123scan2-configuration-utility.html"
#define FW_PAGE_CONTECT_THREE_URL                  @"www.Zebra.com/123Scan"
#define FW_PAGE_CONTECT_FOUR                       @"From your Windows PC with 123Scan, access your scanner's plug-in(.scnplg file) from C:\\ProgramData\\123Scan\\Plug-ins"
#define FW_PAGE_CONTECT_FIVE                        @"Put a copy of the  plug-in into your phone's download folder (Application > Download)"
#define FW_PAGE_CONTECT_SIX                        @"Start the firmware update by clicking the update firmware button"
#define FW_PAGE_PLUGIN_MISMATCH_CONTENT_ONE        @"Delete the incorrect plug-in from the Download folder"
#define FW_PAGE_PLUGIN_MISMATCH_CONTENT_TWO        @"Load the correct plug-in from the Download folder"


typedef enum {
    ZT_INFO_UPDATE_FROM_DAT                   = 0x00,
    ZT_INFO_UPDATE_FROM_PLUGIN                = 0x01,
} ZT_INFO_UPDATE_FW;

#define MOT_INDENT_DEFAULT              20.0
#define MOT_NAVIGATION_BAR_HEIGHT       44.0
#define MOT_DEFAULT_FONT                17.0
#define MOT_START_IMAGE_WIDTH           0.7
#define MOT_MIN_IMAGE_WIDTH             0.4
#define MOT_ASPECT_RATIO_HEIGHT         0.4

typedef enum {
    BG_COLOUR_BLUE                   = 0x00,
    BG_COLOUR_YELLOW                 = 0x01,
    BG_COLOUR_FONT_COLOUR            = 0x02,
    BG_COLOUR_DARK_GRAY              = 0x03,
    BG_COLOUR_MEDIUM_GRAY            = 0x04,
    BG_COLOUR_LIGHT_GRAY             = 0x05,
    BG_COLOUR_TBL_LOW_GRAY           = 0x06,
    BG_COLOUR_WHITE                  = 0x07,
    BG_COLOUR_INACTIVE_BACKGROUND    = 0x08,
    BG_COLOUR_INACTIVE_TEXT          = 0x09,
    BG_COLOUR_DEFAULT_BTN_CLR        = 0x10,
} ZT_BG_COLOURS;

#endif /* __CONFIG_H__ */
