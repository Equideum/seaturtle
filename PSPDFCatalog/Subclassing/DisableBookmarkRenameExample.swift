//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

class DisableBookmarkRenameExample: PSCExample {

    override init() {
        super.init()

        title = "Disable Bookmark Rename"
        contentDescription = "Shows how to use a custom bookmark cell to disable bookmark renaming"
        category = .subclassing
        priority = 250
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let sourceURL = samplesURL.appendingPathComponent(PSCAssetName.quickStart.rawValue)
        let writeableURL = PSCCopyFileURLToDocumentFolderAndOverride(sourceURL, false)
        let document = PSPDFDocument(url: writeableURL)

        let configuration = PSPDFConfiguration { builder in
            // Use our PSPDFBookmarkCell subclass which has disabled bookmark editing.
            builder.overrideClass(PSPDFBookmarkCell.self, with: DisableRenameBookmarkCell.self)
        }

        let controller = PSPDFViewController(document: document, configuration: configuration)
        controller.navigationItem.setRightBarButtonItems([controller.outlineButtonItem, controller.bookmarkButtonItem], animated: false)

        return controller
    }
}

class DisableRenameBookmarkCell: PSPDFBookmarkCell {

    /// Overriding this method and returning false disables the bookmark name editing when the cell is in edit mode.
    override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}
