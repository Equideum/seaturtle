//
//  Copyright © 2011-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

/// Enable to make the view plain, no folders supported.
#define PSPDFStoreManagerPlain YES

NS_ASSUME_NONNULL_BEGIN

/// Notification emitted when magazines were successfully loaded form disk.
FOUNDATION_EXTERN NSNotificationName const PSCStoreDiskLoadFinishedNotification;

@class PSCMagazine, PSCMagazineFolder, PSCDownload;

@protocol PSCStoreManagerDelegate <NSObject>

- (void)magazineStoreBeginUpdate;
- (void)magazineStoreEndUpdate;

// folder
- (void)magazineStoreFolderDeleted:(PSCMagazineFolder *)magazineFolder;
- (void)magazineStoreFolderAdded:(PSCMagazineFolder *)magazineFolder;
- (void)magazineStoreFolderModified:(PSCMagazineFolder *)magazineFolder;

// magazine
- (void)magazineStoreMagazineDeleted:(PSCMagazine *)magazine;
- (void)magazineStoreMagazineAdded:(PSCMagazine *)magazine;
- (void)magazineStoreMagazineModified:(PSCMagazine *)magazine;

- (void)openMagazine:(PSCMagazine *)magazine;

@end

/// Store manager, keeps magazines and folders.
@interface PSCStoreManager : NSObject

/// Shared Instance.
@property (atomic, class, readonly) PSCStoreManager *sharedStoreManager;

/// Single delegate.
@property (nonatomic, weak) id<PSCStoreManagerDelegate> delegate;

/// Storage path currently used. (depends on iOS version)
+ (NSString *)storagePath;

/// Clears all magazineFolders. Will not send delegate events.
- (void)clearCache;

/// Reload all magazines from disk.
- (void)loadMagazinesFromDisk;

/// Add multiple magazines.
- (void)addMagazinesToStore:(NSArray *)magazines;

/// Delete a magazine.
- (void)deleteMagazine:(PSCMagazine *)magazine;

/// Delete a magazine folder.
- (void)deleteMagazineFolder:(PSCMagazineFolder *)magazineFolder;

/// All available magazine folders.
@property (nonatomic, readonly) NSArray<PSCMagazineFolder *> *magazineFolders;

/// Are we loading disk files?
@property (nonatomic, getter=isDiskDataLoaded, readonly) BOOL diskDataLoaded;

@end

NS_ASSUME_NONNULL_END
