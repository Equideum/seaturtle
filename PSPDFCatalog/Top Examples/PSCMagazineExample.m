//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'MagazineExample.swift' for the Swift version of this example.

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCMagazineExample : PSCExample
@end
@implementation PSCMagazineExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Settings for a magazine";
        self.contentDescription = @"Large thumbnails, page curl, sliding user interface.";
        self.category = PSCExampleCategoryTop;
        self.priority = 7;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameAnnualReport];
    document.UID = @"BOWTIES"; // set custom UID so it doesn't interfere with other examples
    document.title = @"RHANAUER BOW TIE"; // Override document title.

    PSPDFDocumentSharingConfiguration *sharingConfiguration = [PSPDFDocumentSharingConfiguration configurationWithBuilder:^(PSPDFDocumentSharingConfigurationBuilder * builder) {
        builder.excludedActivityTypes = @[UIActivityTypePostToWeibo, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
    }];

    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        builder.pageTransition = PSPDFPageTransitionCurl;
        builder.pageMode = PSPDFPageModeAutomatic;
        builder.userInterfaceViewAnimation = PSPDFUserInterfaceViewAnimationSlide;
        builder.thumbnailBarMode = PSPDFThumbnailBarModeScrollable;

        builder.sharingConfigurations = @[sharingConfiguration];
    }]];

    controller.documentInfoCoordinator.availableControllerOptions = @[PSPDFDocumentInfoOptionOutline];
    
    // Setup toolbar
    controller.navigationItem.rightBarButtonItems = @[controller.bookmarkButtonItem, controller.outlineButtonItem, controller.searchButtonItem, controller.activityButtonItem];

    controller.userInterfaceView.pageLabel.showThumbnailGridButton = YES;

    // Hide specific option on thumbnail filter bar
    controller.thumbnailController.filterOptions = @[PSPDFThumbnailViewFilterShowAll, PSPDFThumbnailViewFilterBookmarks];

    return controller;
}

@end
