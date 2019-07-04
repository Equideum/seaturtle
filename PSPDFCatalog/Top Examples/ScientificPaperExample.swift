//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//
// See 'PSCScientificPaperExample.m' for the Objective-C version of this example.

class ScientificPaperExample: PSCExample {

    override init() {
        super.init()

        title = "Settings for a scientific paper"
        contentDescription = "Automatic text link detection, continuous scrolling, default style."
        category = .top
        priority = 8
        wantsModalPresentation = true
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        let document = PSCAssetLoader.document(withName: .JKHF)
        document?.autodetectTextLinkTypes = .all

        let configuration = PSPDFConfiguration { builder in
            builder.pageTransition = .scrollContinuous
            builder.scrollDirection = .vertical
            builder.isRenderAnimationEnabled = false
            builder.shouldHideNavigationBarWithUserInterface = false
            builder.shouldHideStatusBarWithUserInterface = false
        }

        let controller = PSPDFViewController(document: document, configuration: configuration)
        if let layout = controller.documentViewController?.layout as? PSPDFContinuousScrollingLayout {
            layout.fillAlongsideTransverseAxis = true
        }
        controller.navigationItem.setRightBarButtonItems([controller.thumbnailsButtonItem, controller.searchButtonItem, controller.outlineButtonItem, controller.activityButtonItem, controller.annotationButtonItem], for: .document, animated: false)

        return controller
    }
}
