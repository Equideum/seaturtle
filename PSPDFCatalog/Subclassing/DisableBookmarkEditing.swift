//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

class DisableBookmarkEditingExample: PSCExample {

    override init() {
        super.init()

        title = "Disable Bookmark Editing"
        contentDescription = "Shows how to disable bookmark editing using Document Features"
        category = .subclassing
        priority = 260
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let sourceURL = samplesURL.appendingPathComponent(PSCAssetName.quickStart.rawValue)
        let writeableURL = PSCCopyFileURLToDocumentFolderAndOverride(sourceURL, false)
        let document = PSPDFDocument(url: writeableURL)

        // Add the custom source to the document's features.
        let documentFeaturesSource = DisableBookmarkEditingDocumentFeaturesSource()
        document.features.add([documentFeaturesSource])

        let controller = PSPDFViewController(document: document)
        controller.navigationItem.setRightBarButtonItems([controller.outlineButtonItem], animated: false)
        return controller
    }
}

class DisableBookmarkEditingDocumentFeaturesSource: NSObject, PSPDFDocumentFeaturesSource {
    var features: PSPDFDocumentFeatures?

    // Return false to disable bookmark editing.
    var canEditBookmarks: Bool {
        return false
    }
}
