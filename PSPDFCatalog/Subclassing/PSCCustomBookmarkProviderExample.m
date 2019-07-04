//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

/// Example how to subclass the bookmark parser to relay the bookmark data.
@interface PSCBookmarkParser : NSObject <PSPDFBookmarkProvider>
@end

@interface PSCCustomBookmarkProviderExample : PSCExample
@end
@implementation PSCCustomBookmarkProviderExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Custom Bookmark Provider";
        self.contentDescription = @"Shows how to use a custom bookmark provider using a csv file";
        self.category = PSCExampleCategorySubclassing;
        self.priority = 250;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    document.bookmarkManager.provider = @[[PSCBookmarkParser new]];

    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        builder.bookmarkSortOrder = PSPDFBookmarkManagerSortOrderCustom;
    }]];
    [controller.navigationItem setRightBarButtonItems:@[controller.thumbnailsButtonItem, controller.outlineButtonItem, controller.searchButtonItem, controller.bookmarkButtonItem] forViewMode:PSPDFViewModeDocument animated:NO];
    return controller;
}

@end

@interface PSCBookmarkParser ()

@property (nonatomic, readonly) NSMutableArray<PSPDFBookmark *> *bookmarkData;

@end

@implementation PSCBookmarkParser

+ (NSURL *)bookmarkURL {
    NSURL *applicationSupport = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    NSURL *fileURL = [[applicationSupport URLByAppendingPathComponent:@"customBookmarksProvider"] URLByAppendingPathExtension:@"csv"];
    return fileURL;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:[PSCBookmarkParser bookmarkURL]];
        NSString *csv = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        NSMutableArray<PSPDFBookmark *> *bookmarkData = [NSMutableArray new];

        NSArray<NSString *> *lines = [csv componentsSeparatedByString:@"\n"];

        for (NSString *line in lines) {
            NSScanner *scanner = [[NSScanner alloc] initWithString:line];
            NSMutableArray<NSString *> *lineItems = [NSMutableArray new];
            while (![scanner isAtEnd]) {
                NSString *item;
                [scanner scanUpToString:@"\"" intoString:NULL];
                if ([scanner scanString:@"\"" intoString:NULL]) {
                    [scanner scanUpToString:@"\"" intoString:&item];
                    [scanner scanString:@"\"" intoString:NULL];
                    [lineItems addObject:item ?: @""];
                }
            }

            if (lineItems.count != 4) {
                continue;
            }

            /*
             For the purpose of this demo we just assume things are where they should
             be. In production, this should be properly parsed, evaluated and an
             appropriate error handling should be in place.
             */
            PSPDFBookmark *bookmark = [[PSPDFBookmark alloc] initWithIdentifier:lineItems[0] action:[[PSPDFGoToAction alloc] initWithPageIndex:lineItems[1].integerValue] name:lineItems[2] sortKey:@(lineItems[3].integerValue)];
            [bookmarkData addObject:bookmark];
        }

        _bookmarkData = bookmarkData;
    }
    return self;
}

- (NSArray<PSPDFBookmark *> *)bookmarks {
    return self.bookmarkData.copy;
}

- (BOOL)addBookmark:(PSPDFBookmark *)bookmark {
    NSLog(@"Add Bookmark: %@", bookmark);
    NSUInteger index = [self.bookmarkData indexOfObject:bookmark];
    if (index == NSNotFound) {
        [self.bookmarkData addObject:bookmark];
    } else {
        self.bookmarkData[index] = bookmark;
    }
    return YES;
}

- (BOOL)removeBookmark:(PSPDFBookmark *)bookmark {
    NSLog(@"Remove Bookmark: %@", bookmark);
    if ([self.bookmarkData containsObject:bookmark]) {
        [self.bookmarkData removeObject:bookmark];
        return YES;
    } else {
        return NO;
    }
}

- (void)save {
    NSLog(@"Save bookmarks.");

    NSMutableString *csv = [NSMutableString new];

    for (PSPDFBookmark *bookmark in self.bookmarkData.copy) {
        NSString *identifier = bookmark.identifier;
        NSString *pageIndex = @(bookmark.pageIndex).stringValue;
        NSString *name = [bookmark.name stringByReplacingOccurrencesOfString:@"\"" withString:@"'"] ?: @"";
        NSString *sortKey = bookmark.sortKey.stringValue ?: @"";
        [csv appendFormat:@"\"%@\",\"%@\",\"%@\",\"%@\"\n", identifier, pageIndex, name, sortKey];
    }

    NSData *data = [csv dataUsingEncoding:NSUTF8StringEncoding];
    [data writeToURL:[PSCBookmarkParser bookmarkURL] atomically:YES];
}

@end
