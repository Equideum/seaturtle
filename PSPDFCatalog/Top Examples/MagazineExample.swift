//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'PSCMagazineExample.m' for the Objective-C version of this example.

class MagazineExample: PSCExample {

    override init() {
        super.init()

        title = "Settings for a magazine"
        contentDescription = "Large thumbnails, page curl, sliding user interface."
        category = .top
        priority = 7
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        let document = PSCAssetLoader.document(withName: .annualReport)
        document?.uid = "BOWTIES" // set custom UID so it doesn't interfere with other examples
        document?.title = "RHANAUER BOW TIE" // Override document title.

        let shareConfiguration = PSPDFDocumentSharingConfiguration {
            $0.excludedActivityTypes = [.postToWeibo, .assignToContact, .saveToCameraRoll]
        }

        let configuration = PSPDFConfiguration { builder in
            builder.pageTransition = .curl
            builder.pageMode = .automatic
            builder.userInterfaceViewAnimation = .slide
            builder.thumbnailBarMode = .scrollable
            builder.sharingConfigurations = [shareConfiguration]
        }
        let controller = PSPDFViewController(document: document, configuration: configuration)

        controller.documentInfoCoordinator.availableControllerOptions = [PSPDFDocumentInfoOption.outline]

        // Setup toolbar
        controller.navigationItem.rightBarButtonItems = [controller.bookmarkButtonItem, controller.outlineButtonItem, controller.searchButtonItem, controller.activityButtonItem]

        controller.userInterfaceView.pageLabel.showThumbnailGridButton = true

        // Hide specific option on thumbnail filter bar
        controller.thumbnailController.filterOptions = [.showAll, .bookmarks]

        return controller
    }
}
