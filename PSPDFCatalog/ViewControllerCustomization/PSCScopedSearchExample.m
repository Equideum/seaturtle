//
//  Copyright © 2014-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "NSArray+PSCIndexSet.h"
#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCScopedSearchViewController : PSPDFSearchViewController
@end
@interface PSCScopedPDFViewController : PSPDFViewController
@end

@interface PSCScopedSearchExample : PSCExample
@end
@implementation PSCScopedSearchExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Add scope to PSPDFSearchViewController";
        self.contentDescription = @"Allows more fine-grained search control with a custom scope bar.";
        self.category = PSCExampleCategoryControllerCustomization;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *pdfController = [[PSCScopedPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        [builder overrideClass:PSPDFSearchViewController.class withClass:PSCScopedSearchViewController.class];
        // The scope bar is currently only supported for PSPDFSearchModeModal
        builder.searchMode = PSPDFSearchModeModal;
    }]];
    return pdfController;
}

@end

@implementation PSCScopedSearchViewController

- (UISearchBar *)createSearchBar {
    UISearchBar *searchBar = super.createSearchBar;
    // Add scopes
    searchBar.scopeButtonTitles = @[@"This Page", @"Everything"];
    searchBar.showsScopeBar = YES;
    return searchBar;
}

@end

@implementation PSCScopedPDFViewController

// The PSPDFSearchViewController has its delegate set to the PSPDFViewController, so subclass and add this method.
- (nullable NSIndexSet *)searchViewController:(PSPDFSearchViewController *)searchController searchRangeForScope:(NSString *)scope {
    if ([scope isEqualToString:@"This Page"]) {
        return self.visiblePageIndexes;
    } else {
        return nil; // all pages
    }
}

@end
