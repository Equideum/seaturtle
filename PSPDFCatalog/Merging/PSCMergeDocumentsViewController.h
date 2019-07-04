//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Simple variant of a document merge UI to get you started.
@interface PSCMergeDocumentsViewController : UIViewController

/// Initialize with two documents, show them side-by-side
- (instancetype)initWithLeftDocument:(PSPDFDocument *)leftDocument rightDocument:(PSPDFDocument *)rightDocument; // convenience;

@property (nonatomic) PSPDFDocument *leftDocument;
@property (nonatomic) PSPDFDocument *rightDocument;

@end

NS_ASSUME_NONNULL_END
