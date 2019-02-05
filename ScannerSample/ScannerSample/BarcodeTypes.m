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
 *  Description:  BarcodeTypes.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import "BarcodeTypes.h"

NSString* get_barcode_type_name(int barcode_type)
{
    switch(barcode_type)
    {
        case ST_NOT_APP: return @"NOT APPLICABLE";
        case ST_CODE_39: return @"CODE 39";
        case ST_CODABAR: return @"CODABAR";
        case ST_CODE_128: return @"CODE 128";
        case ST_D2OF5: return @"D 2 OF 5";
        case ST_IATA: return @"IATA";
        case ST_I2OF5: return @"I 2 OF 5";
        case ST_CODE93: return @"CODE 93";
        case ST_UPCA: return @"UPCA";
        case ST_UPCE0: return @"UPCE 0";
        case ST_EAN8: return @"EAN 8";
        case ST_EAN13: return @"EAN 13";
        case ST_CODE11: return @"CODE 11";
        case ST_CODE49: return @"CODE 49";
        case ST_MSI: return @"MSI";
        case ST_EAN128: return @"EAN 128";
        case ST_UPCE1: return @"UPCE 1";
        case ST_PDF417: return @"PDF 417";
        case ST_CODE16K: return @"CODE 16K";
        case ST_C39FULL: return @"C39FULL";
        case ST_UPCD: return @"UPCD";
        case ST_TRIOPTIC: return @"TRIOPTIC";
        case ST_BOOKLAND: return @"BOOKLAND";
        case ST_COUPON: return @"COUPON";
        case ST_NW7: return @"NW7";
        case ST_ISBT128: return @"ISBT128";
        case ST_MICRO_PDF: return @"MICRO PDF";
        case ST_DATAMATRIX: return @"DATAMATRIX";
        case ST_QR_CODE: return @"QR CODE";
        case ST_MICRO_PDF_CCA: return @"MICRO PDF CCA";
        case ST_POSTNET_US: return @"POSTNET US";
        case ST_PLANET_CODE: return @"PLANET CODE";
        case ST_CODE_32: return @"CODE 32";
        case ST_ISBT128_CON: return @"ISBT 128 CON";
        case ST_JAPAN_POSTAL: return @"JAPAN POSTAL";
        case ST_AUS_POSTAL: return @"AUS POSTAL";
        case ST_DUTCH_POSTAL: return @"DUTCH POSTAL";
        case ST_MAXICODE: return @"MAXICODE";
        case ST_CANADIN_POSTAL: return @"CANADA POSTAL";
        case ST_UK_POSTAL: return @"UK POSTAL";
        case ST_MACRO_PDF: return @"MACRO PDF";
        case ST_RSS14: return @"RSS 14";
        case ST_RSS_LIMITED: return @"RSS LIMITED";
        case ST_RSS_EXPANDED: return @"RSS EXPANDED";
        case ST_SCANLET: return @"ST SCANLET";
        case ST_UPCA_2: return @"UPCA 2";
        case ST_UPCE0_2: return @"UPCE0 2";
        case ST_EAN8_2: return @"EAN8 2";
        case ST_EAN13_2: return @"EAN13 2";
        case ST_UPCE1_2: return @"UPCE1 2";
        case ST_CCA_EAN128: return @"CCA EAN 128";
        case ST_CCA_EAN13: return @"CCA EAN 13";
        case ST_CCA_EAN8: return @"CCA EAN 8";
        case ST_CCA_RSS_EXPANDED: return @"CCA RSS EXPANDED";
        case ST_CCA_RSS_LIMITED: return @"CCA RSS LIMITED";
        case ST_CCA_RSS14: return @"CCA RSS 14";
        case ST_CCA_UPCA: return @"CCA UPCA";
        case ST_CCA_UPCE: return @"CCA UPCE";
        case ST_CCC_EAN128: return @"CCC EAN 128";
        case ST_TLC39: return @"TLC39";
        case ST_CCB_EAN128: return @"CCB EAN 128";
        case ST_CCB_EAN13: return @"CCB EAN 13";
        case ST_CCB_EAN8: return @"CCB EAN 8";
        case ST_CCB_RSS_EXPANDED: return @"CCB RSS EXPANDED";
        case ST_CCB_RSS_LIMITED: return @"CCB RSS LIMITED";
        case ST_CCB_RSS14: return @"CCB RSS 14";
        case ST_CCB_UPCA: return @"CCB UPCA";
        case ST_CCB_UPCE: return @"CCB UPCE";
        case ST_SIGNATURE_CAPTURE: return @"SIGNATURE CAPTURE";
        case ST_MATRIX2OF5: return @"MATRIX 2 OF 5";
        case ST_CHINESE2OF5: return @"CHINESE 2 OF 5";
        case ST_UPCA_5: return @"UPCA 5";
        case ST_UPCE0_5: return @"UPCE0 5";
        case ST_EAN8_5: return @"EAN8 5";
        case ST_EAN13_5: return @"EAN13 5";
        case ST_UPCE1_5: return @"UPCE1 5";
        case ST_MACRO_MICRO_PDF: return @"MACRO MICRO PDF";
        case ST_MICRO_QR_CODE: return @"MICRO QR CODE";
        case ST_AZTEC: return @"AZTEC";
        case ST_HAN_XIN: return @"HAN XIN";
        case ST_KOREAN_3_OF_5: return @"KOREAN 3 OF 5";
        case ST_ISSN: return @"ISSN";
        case ST_MATRIX_2_OF_5: return @"MATRIX 2 OF 5";
        case ST_AZTEC_RUNE_CODE: return @"AZTEC RUNE CODE";
        case ST_NEW_COUPEN_CODE: return @"NEW COUPON CODE";
        default: return @"";
    }
}