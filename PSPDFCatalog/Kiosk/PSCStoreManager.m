//
//  Copyright © 2011-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCStoreManager.h"
#import "PSCMagazine.h"
#import "PSCMagazineFolder.h"
#import "PSCPathMonitor.h"
#import <objc/runtime.h>

@interface PSCStoreManager () {
    NSMutableArray *_magazineFolders;
    dispatch_queue_t _magazineFolderQueue;
    struct {
        unsigned int ignoreNextFileUpdate : 1;
    } _flags;
}
@property (nonatomic, getter=isDiskDataLoaded) BOOL diskDataLoaded;
@property (nonatomic, readonly) PSCPathMonitor *pathMonitor;
@property (nonatomic, null_resettable) NSArray<NSURL *> *searchPaths;
@end

@implementation PSCStoreManager

@synthesize searchPaths = _searchPaths;

NSNotificationName const PSCStoreDiskLoadFinishedNotification = @"PSCStoreDiskLoadFinishedNotification";

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Static

+ (PSCStoreManager *)sharedStoreManager {
    static dispatch_once_t onceToken = 0;
    static PSCStoreManager *_sharedStoreManager;
    dispatch_once(&onceToken, ^{
        _sharedStoreManager = [self new];
    });
    return _sharedStoreManager;
}

+ (NSString *)storagePath {
    static NSString *storagePath;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storagePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    });
    return storagePath;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle

- (instancetype)init {
    if ((self = [super init])) {
        dispatch_queue_attr_t attributes = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_USER_INITIATED, 0);
        _magazineFolderQueue = dispatch_queue_create([NSString stringWithFormat:@"com.PSPDFCatalog.%@", self].UTF8String, attributes);
        _pathMonitor = [PSCPathMonitor new];

        // Load magazines from disk, async.
        _diskDataLoaded = YES;
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            [self loadMagazinesFromDisk];
        });
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (void)deleteMagazineFolder:(PSCMagazineFolder *)magazineFolder {
    id<PSCStoreManagerDelegate> delegate = self.delegate;
    [delegate magazineStoreBeginUpdate];

    for (PSCMagazine *magazine in magazineFolder.magazines) {
        [delegate magazineStoreMagazineDeleted:magazine];

        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
            [magazine deleteFiles:NULL];
        });
    }

    [delegate magazineStoreFolderDeleted:magazineFolder];
    dispatch_barrier_sync(_magazineFolderQueue, ^{
        [self->_magazineFolders removeObject:magazineFolder];
    });

    [delegate magazineStoreEndUpdate];
}

- (void)deleteMagazine:(PSCMagazine *)magazine {
    self->_flags.ignoreNextFileUpdate = YES;
    id<PSCStoreManagerDelegate> delegate = self.delegate;
    [delegate magazineStoreBeginUpdate];

    PSCMagazineFolder *folder = magazine.folder;

    // Clear everything
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [magazine deleteFiles:NULL];
    });

    // if magazine has no URL - delete.
    if (!magazine.URL) {
        [folder removeMagazine:magazine];
        [delegate magazineStoreMagazineDeleted:magazine];

        if (folder.magazines.count > 0) {
            [delegate magazineStoreFolderModified:folder]; // was just modified
        } else {
            dispatch_barrier_sync(_magazineFolderQueue, ^{
                [self->_magazineFolders removeObject:folder]; // remove!
                [delegate magazineStoreFolderDeleted:folder];
            });
        }
    } else {
        // just set availability to now - needs redownloading!
        magazine.available = NO;
        [delegate magazineStoreMagazineModified:magazine];
    }

    [delegate magazineStoreEndUpdate];
}

- (void)addMagazinesToStore:(NSArray *)magazines {
    // Filter out magazines that are already in array.
    NSMutableArray *newMagazines = [NSMutableArray arrayWithArray:magazines];
    for (PSCMagazine *newMagazine in magazines) {
        for (PSCMagazineFolder *folder in self.magazineFolders) {
            NSArray *foundMagazines = [folder.magazines filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.UID == %@", newMagazine.UID]];
            [newMagazines removeObjectsInArray:foundMagazines];
        }
    }

    if (newMagazines.count > 0) {
        id<PSCStoreManagerDelegate> delegate = self.delegate;

        [delegate magazineStoreBeginUpdate];

        for (PSCMagazine *magazine in newMagazines) {
            PSCMagazineFolder *folder = [self addMagazineToFolder:magazine];

            // folder fresh or updated?
            if (folder.magazines.count == 1) {
                [delegate magazineStoreFolderAdded:folder];
            } else {
                [delegate magazineStoreFolderModified:folder];
            }

            [delegate magazineStoreMagazineAdded:magazine];
        }
        [delegate magazineStoreEndUpdate];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

// Helper for folder search.
- (NSMutableArray *)searchFolder:(NSString *)sampleFolder {
    NSError *error;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *documentContents = [fileManager contentsOfDirectoryAtPath:sampleFolder error:&error];
    NSMutableArray *folders = [NSMutableArray array];
    PSCMagazineFolder *rootFolder = [PSCMagazineFolder folderWithTitle:(NSString *)[NSURL fileURLWithPath:sampleFolder].lastPathComponent];

    for (NSString *folder in documentContents) {
        // check if target path is a directory (all magazines are in directories)
        NSString *fullPath = [sampleFolder stringByAppendingPathComponent:folder];
        BOOL isDir;
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&isDir]) {
            if (isDir) {
                PSCMagazineFolder *contentFolder = [PSCMagazineFolder folderWithTitle:fullPath.lastPathComponent];
                NSArray *subDocumentContents = [fileManager contentsOfDirectoryAtPath:fullPath error:&error];
                for (NSString *afolder in subDocumentContents) {
                    if ([afolder.lowercaseString hasSuffix:@"pdf"]) {
                        PSCMagazine *magazine = [PSCMagazine magazineWithPath:[fullPath stringByAppendingPathComponent:afolder]];
                        [contentFolder addMagazine:magazine];
                    }
                }

                if (contentFolder.magazines.count) {
                    [folders addObject:contentFolder];
                }
            } else if ([fullPath.lowercaseString hasSuffix:@"pdf"]) {
                @autoreleasepool {
                    PSCMagazine *magazine = [PSCMagazine magazineWithPath:fullPath];
                    [rootFolder addMagazine:magazine];
                }
            }
        }
    }
    if (rootFolder.magazines.count > 0) [folders addObject:rootFolder];

    return folders;
}

// doesn't support deep hierarchies. Just root or a folder.
- (NSMutableArray *)searchForMagazineFolders {
    NSMutableArray *folders = [NSMutableArray array];

    for (NSURL *searchPath in self.searchPaths) {
        [folders addObjectsFromArray:[self searchFolder:searchPath.path]];
    }

    // flatten hierarchy
    if (PSPDFStoreManagerPlain) {
        // if we don't have any folders, create one
        if (folders.count == 0) {
            PSCMagazineFolder *aFolder = [PSCMagazineFolder folderWithTitle:@""];
            [folders addObject:aFolder];
        }

        NSMutableArray *foldersCopy = [folders mutableCopy];
        PSCMagazineFolder *firstFolder = foldersCopy[0];
        [foldersCopy removeObject:firstFolder];
        NSMutableArray *magazineArray = [firstFolder.magazines mutableCopy];

        for (PSCMagazineFolder *folder in foldersCopy) {
            [magazineArray addObjectsFromArray:folder.magazines];
            [folders removeObject:folder];
        }

        firstFolder.magazines = magazineArray;
    }

    [folders sortUsingComparator:^NSComparisonResult(PSCMagazineFolder *folder1, PSCMagazineFolder *folder2) {
        return [folder1.title compare:folder2.title];
    }];

    return folders;
}

// Add a magazine to folder, then re-sort it.
- (PSCMagazineFolder *)addMagazineToFolder:(PSCMagazine *)magazine {
    PSCMagazineFolder *folder = self.magazineFolders.lastObject;
    [folder addMagazine:magazine];
    NSAssert([folder isKindOfClass:PSCMagazineFolder.class], @"incorrect type");
    return folder;
}

- (PSCMagazine *)magazineForUID:(NSString *)uid {
    for (PSCMagazineFolder *folder in self.magazineFolders) {
        for (PSCMagazine *magazine in folder.magazines) {
            if ([magazine.UID isEqualToString:uid]) {
                return magazine;
            }
        }
    }
    return nil;
}

- (void)clearCache {
    dispatch_barrier_sync(_magazineFolderQueue, ^{
        self->_magazineFolders = nil;
    });
}

// load magazines from disk
- (void)loadMagazinesFromDisk {
    NSMutableArray *magazineFolders = [self searchForMagazineFolders];

    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_barrier_sync(self->_magazineFolderQueue, ^{
            self->_magazineFolders = magazineFolders;
            self.diskDataLoaded = NO;
        });

        [NSNotificationCenter.defaultCenter postNotificationName:PSCStoreDiskLoadFinishedNotification object:nil];
    });
}

- (NSMutableArray *)magazineFolders {
    __block NSMutableArray *magazineFolders;
    dispatch_sync(_magazineFolderQueue, ^{
        magazineFolders = self->_magazineFolders;
    });

    return magazineFolders;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Search Paths

- (NSArray<NSURL *> *)searchPaths {
    if (_searchPaths == nil) {
        NSMutableArray *searchPaths = [NSMutableArray new];

        // Add Samples
        NSURL *sampleFolder = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
        [searchPaths addObject:sampleFolder];

        // Add files from Open In...
        NSError *documentsFolderError;
        NSURL *documentsFolder = [NSFileManager.defaultManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&documentsFolderError];
        if (documentsFolder) {
            [searchPaths addObject:documentsFolder];
        } else {
            PSCLog(@"Can't find documents directory: %@", documentsFolderError);
        }

        self.searchPaths = [searchPaths copy];
    }
    return _searchPaths;
}

- (void)setSearchPaths:(NSArray<NSURL *> *)searchPaths {
    NSSet *oldSet = [NSSet setWithArray:_searchPaths];
    NSSet *newSet = [NSSet setWithArray:searchPaths];

    NSMutableSet *removeSet = [oldSet mutableCopy];
    [removeSet minusSet:newSet];

    for (NSURL *fileURL in removeSet) {
        [self.pathMonitor stopMonitoringFileURL:fileURL];
    }

    _searchPaths = searchPaths;

    NSMutableSet *addSet = [newSet mutableCopy];
    [addSet minusSet:oldSet];

    __weak typeof(self) weakSelf = self;
    for (NSURL *fileURL in addSet) {
        [self.pathMonitor startMonitoringFileURL:fileURL error:NULL queue:NULL updateHandler:^(NSURL *updatedFileURL) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf->_flags.ignoreNextFileUpdate) {
                strongSelf->_flags.ignoreNextFileUpdate = NO;
                return;
            }
            [strongSelf loadMagazinesFromDisk];
        }];
    }
}

@end
