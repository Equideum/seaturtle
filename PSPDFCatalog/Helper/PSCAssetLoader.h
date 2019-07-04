//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *PSCAssetName NS_EXTENSIBLE_STRING_ENUM;

FOUNDATION_EXTERN PSCAssetName const PSCAssetNameQuickStart;
FOUNDATION_EXTERN PSCAssetName const PSCAssetNameAbout;
FOUNDATION_EXTERN PSCAssetName const PSCAssetNameWeb;
FOUNDATION_EXTERN PSCAssetName const PSCAssetNameCaseStudyBox;
FOUNDATION_EXTERN PSCAssetName const PSCAssetNameJKHF;
FOUNDATION_EXTERN PSCAssetName const PSCAssetNameAnnualReport;

@class PSPDFDocument;

@interface PSCAssetLoader : NSObject

/// Load sample file with file `name`.
+ (nullable PSPDFDocument *)documentWithName:(PSCAssetName)name;

/// Loads a document and copies it to a temp directory so it can be written.
+ (nullable PSPDFDocument *)writableDocumentWithName:(PSCAssetName)name overrideIfExists:(BOOL)overrideIfExists;

/// Generates a test PDF with `string` as content.
+ (PSPDFDocument *)temporaryDocumentWithString:(nullable PSCAssetName)string;

@end

NS_ASSUME_NONNULL_END
