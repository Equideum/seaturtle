//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

class BlurPagesExample: PSCExample, PSPDFViewControllerDelegate {

    override init() {
        super.init()

        title = "Blur Pages"
        contentDescription = "Shows how to blur specific pages in a document."
        category = .viewCustomization
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let sourceURL = samplesURL.appendingPathComponent(PSCAssetName.quickStart.rawValue)
        let writeableURL = PSCCopyFileURLToDocumentFolderAndOverride(sourceURL, false)
        let document = PSPDFDocument(url: writeableURL)

        let configuration = PSPDFConfiguration { builder in
            builder.pageTransition = .scrollPerSpread
            builder.pageMode = .single
            builder.thumbnailBarMode = .none
            builder.isTextSelectionEnabled = false
        }
        let controller = PSPDFViewController(document: document, configuration: configuration)

        // Remove the thumbnails button item from the toolbar.
        let rightBarButtonItems = controller.navigationItem.rightBarButtonItems?.filter({ (buttonItem) -> Bool in
            return buttonItem != controller.thumbnailsButtonItem
        })
        controller.navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: false)
        controller.delegate = self
        return controller
    }

    func pdfViewController(_ pdfController: PSPDFViewController, willBeginDisplaying pageView: PSPDFPageView, forPageAt pageIndex: Int) {
        // Only blur the first three pages.
        if pageIndex < 2 {
            // Blur pages if they aren't already blurred.
            if !pageView.isBlurred {
                let effect = UIBlurEffect(style: .light)
                let visualEffectView = UIVisualEffectView(effect: effect)
                visualEffectView.frame = pageView.bounds
                visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                pageView.addSubview(visualEffectView)
            }
        } else {
            // Remove the visual effect view from the blurred pages if necessary.
            for view in pageView.subviews where view is UIVisualEffectView {
                view.removeFromSuperview()
            }
        }
    }
}

fileprivate extension PSPDFPageView {
    var isBlurred: Bool {
        return self.subviews.contains(where: { $0 is UIVisualEffectView })
    }
}
