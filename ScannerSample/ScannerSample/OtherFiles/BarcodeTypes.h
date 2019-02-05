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
 *  Description:  BarcodeTypes.h
 *
 *  Notes:
 *
 ******************************************************************************/

#ifndef _BARCODE_TYPES_H_
#define _BARCODE_TYPES_H_

//----- Symbology Types ---------------//
#define   ST_NOT_APP			0x00
#define   ST_CODE_39			0x01
#define   ST_CODABAR			0x02
#define   ST_CODE_128			0x03
#define   ST_D2OF5				0x04
#define   ST_IATA				0x05
#define   ST_I2OF5				0x06
#define   ST_CODE93				0x07
#define   ST_UPCA				0x08
#define   ST_UPCE0				0x09
#define   ST_EAN8				0x0a
#define   ST_EAN13				0x0b
#define   ST_CODE11				0x0c
#define   ST_CODE49				0x0d
#define   ST_MSI				0x0e
#define   ST_EAN128				0x0f
#define   ST_UPCE1				0x10
#define   ST_PDF417				0x11
#define   ST_CODE16K			0x12
#define   ST_C39FULL			0x13
#define   ST_UPCD				0x14
#define   ST_TRIOPTIC			0x15
#define   ST_BOOKLAND			0x16
#define   ST_COUPON				0x17
#define   ST_NW7				0x18
#define   ST_ISBT128			0x19
#define   ST_MICRO_PDF			0x1a
#define   ST_DATAMATRIX			0x1b
#define   ST_QR_CODE			0x1c
#define   ST_MICRO_PDF_CCA		0x1d
#define   ST_POSTNET_US			0x1e
#define   ST_PLANET_CODE		0x1f
#define   ST_CODE_32			0x20
#define   ST_ISBT128_CON		0x21
#define   ST_JAPAN_POSTAL		0x22
#define   ST_AUS_POSTAL			0x23
#define   ST_DUTCH_POSTAL		0x24
#define   ST_MAXICODE			0x25
#define   ST_CANADIN_POSTAL		0x26
#define   ST_UK_POSTAL			0x27
#define   ST_MACRO_PDF			0x28
#define   ST_RSS14				0x30
#define   ST_RSS_LIMITED		0x31
#define   ST_RSS_EXPANDED		0x32
#define   ST_SCANLET			0x37
#define   ST_UPCA_2				0x48
#define   ST_UPCE0_2			0x49
#define   ST_EAN8_2				0x4a
#define   ST_EAN13_2			0x4b
#define   ST_UPCE1_2			0x50
#define   ST_CCA_EAN128			0x51
#define   ST_CCA_EAN13			0x52
#define   ST_CCA_EAN8			0x53
#define   ST_CCA_RSS_EXPANDED	0x54
#define   ST_CCA_RSS_LIMITED	0x55
#define   ST_CCA_RSS14			0x56
#define   ST_CCA_UPCA			0x57
#define   ST_CCA_UPCE			0x58
#define   ST_CCC_EAN128			0x59
#define   ST_TLC39				0x5A
#define   ST_CCB_EAN128			0x61
#define   ST_CCB_EAN13			0x62
#define   ST_CCB_EAN8			0x63
#define   ST_CCB_RSS_EXPANDED	0x64
#define   ST_CCB_RSS_LIMITED	0x65
#define   ST_CCB_RSS14			0x66
#define   ST_CCB_UPCA			0x67
#define   ST_CCB_UPCE			0x68
#define   ST_SIGNATURE_CAPTURE	0x69
#define   ST_MATRIX2OF5			0x71
#define   ST_CHINESE2OF5		0x72
#define   ST_UPCA_5				0x88
#define   ST_UPCE0_5			0x89
#define   ST_EAN8_5				0x8a
#define   ST_EAN13_5			0x8b
#define   ST_UPCE1_5			0x90
#define   ST_MACRO_MICRO_PDF	0x9A
#define   ST_MICRO_QR_CODE		0x2c
#define	  ST_AZTEC				0x2d
#define	  ST_HAN_XIN		    0xB7
#define	  ST_KOREAN_3_OF_5		0x73
#define	  ST_ISSN		        0x36
#define   ST_MATRIX_2_OF_5      0x39
#define	  ST_AZTEC_RUNE_CODE	0x2E
#define	  ST_AZTEC_RUNE_CODE	0x2E
#define	  ST_NEW_COUPEN_CODE    0xB4

NSString* get_barcode_type_name(int barcode_type);

#endif /* _BARCODE_TYPES_H_ */
