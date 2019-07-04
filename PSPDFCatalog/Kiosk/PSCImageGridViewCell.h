//
//  Copyright © 2011-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PSCMagazine, PSCMagazineFolder;

/// Cell for PDF magazines. Adds support for deleting.
@interface PSCImageGridViewCell : PSPDFThumbnailGridViewCell

/// Set magazineCount badge for a PSPDFMagazineFolder.
@property (nonatomic) NSUInteger magazineCount;

/// Cell may contain a magazine or a folder. don't set both.
@property (nonatomic, nullable) PSCMagazine *magazine;
@property (nonatomic, nullable) PSCMagazineFolder *magazineFolder;

/// If set to YES, image is loaded synchronously, not via a thread.
@property (nonatomic) BOOL immediatelyLoadCellImages;

/// Delete button shown in edit mode.
@property (nonatomic) UIButton *deleteButton;

/// Show delete image on the top left of the cell image.
@property (nonatomic) BOOL showDeleteImage;

@end

NS_ASSUME_NONNULL_END
