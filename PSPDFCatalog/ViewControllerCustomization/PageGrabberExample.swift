//
//  Copyright © 2016-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

class PageGrabberExample: PSCExample {

    override init() {
        super.init()

        title = "Page Grabber"
        contentDescription = "Show a page grabber to quickly skim through pages."
        category = .controllerCustomization
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let document = PSCAssetLoader.document(withName: .quickStart)

        let controller = PSPDFViewController(document: document, configuration: PSPDFConfiguration { builder in
            // Enable the page grabber:
            builder.isPageGrabberEnabled = true
            // This is not necessary, but the grabber is especially useful in this mode:
            builder.pageTransition = .scrollContinuous
            builder.scrollDirection = .vertical
        })

        // change the tint color, or even set a custom view.
        controller.pageGrabberController!.pageGrabber.grabberView.tintColor = UIColor.purple

        return controller
    }
}
