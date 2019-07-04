//
//  Copyright © 2011-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCBasicViewController.h"
#import "PSCStoreManager.h"

@class PSCMagazineFolder;

NS_ASSUME_NONNULL_BEGIN

/// Displays a grid of elements from the `PSCStoreManager`.
@interface PSCGridViewController : PSCBasicViewController <PSCStoreManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

/// Force-update grid.
- (void)updateGrid;

/// Grid that's used internally.
@property (nonatomic, nullable) UICollectionView *collectionView;

/// Magazine-folder, if one is selected.
@property (nonatomic, nullable) PSCMagazineFolder *magazineFolder;

@end

NS_ASSUME_NONNULL_END
