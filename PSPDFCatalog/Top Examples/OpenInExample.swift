//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'PSCOpenInExample.m' for the Objective-C version of this example.

class OpenInExample: PSCExample, PSPDFDocumentPickerControllerDelegate {
    override init() {
        super.init()

        title = "Open In… Inbox"
        contentDescription = "Displays all files in the Inbox directory via the PSPDFDocumentPickerController."
        category = .top
        priority = 6
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        // Add all documents in the Documents folder and subfolders (e.g. Inbox from Open In... feature)
        let documentSelector = PSPDFDocumentPickerController(directory: nil, includeSubdirectories: true, library: PSPDFKit.sharedInstance.library)
        documentSelector.delegate = self
        documentSelector.fullTextSearchEnabled = true
        documentSelector.title = self.title
        return documentSelector
    }

     func documentPickerController(_ controller: PSPDFDocumentPickerController, didSelect document: PSPDFDocument, pageIndex: PageIndex, search searchString: String?) {
        let pdfController = PSPDFViewController(document: document)
        pdfController.pageIndex = pageIndex
        pdfController.navigationItem.setRightBarButtonItems([pdfController.thumbnailsButtonItem, pdfController.annotationButtonItem, pdfController.outlineButtonItem, pdfController.searchButtonItem, pdfController.activityButtonItem], for: .document, animated: false)
        controller.navigationController?.pushViewController(pdfController, animated: true)
    }
}
