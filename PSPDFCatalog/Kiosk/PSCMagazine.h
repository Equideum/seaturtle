//
//  Copyright © 2011-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

@class PSCMagazineFolder;

NS_ASSUME_NONNULL_BEGIN

/// Represents a magazine.
@interface PSCMagazine : PSPDFDocument

/// Initializes a magazine object with the specified path.
+ (nullable PSCMagazine *)magazineWithPath:(nullable NSString *)path;

/// Returns the coverImage, which is the first page of the magazine.
/// Here we download that from the web to have sth to show before the pdf is available.
- (nullable UIImage *)coverImageForSize:(CGSize)size;

/// Magazine folder. Weak to break the retain cycle.
@property (nonatomic, weak) PSCMagazineFolder *folder; // weak!

/// URL for downloading the pdf.
@property (nonatomic, copy, nullable) NSURL *URL;

/// URL for downloading image.
@property (nonatomic, copy, nullable) NSURL *imageURL;

/// Handles serialization/deserialization of the last known viewState (page, ...)
@property (nullable, nonatomic) PSPDFViewState *lastViewState;

/// YES if magazine is on-disk and/or successfully downloaded.
@property (nonatomic, getter=isAvailable) BOOL available;

/// YES if the magazine can be deleted. NO if it's within the app bundle, which can't be edited.
@property (nonatomic, getter=isDeletable, readonly) BOOL deletable;

@end

NS_ASSUME_NONNULL_END
