//
//  Copyright © 2016-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

class NewPageFromDocumentExample: PSCExample {

    // MARK: PSCExample

    override init() {
        super.init()
        title = "Copy Page From Another Document"
        contentDescription = "Use PSPDFDocumentEditor to copy a page from another document."
        category = .documentEditing
        priority = 3
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        // Let's create a new writable document every time we invoke the example.
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let sourceURL = samplesURL.appendingPathComponent(PSCAssetName.quickStart.rawValue)
        let writableURL = PSCCopyFileURLToDocumentFolderAndOverride(sourceURL, true)

        let document = PSPDFDocument(url: writableURL)
        let pdfController = EditingPDFController(document: document)

        // Add a single button that triggers preset document editing actions.
        let editButtonItem = UIBarButtonItem(image: PSPDFKit.imageNamed("document_editor"), style: .plain, target: pdfController, action: #selector(EditingPDFController.edit))
        pdfController.navigationItem.rightBarButtonItems = [editButtonItem]

        return pdfController
    }

    // MARK: Controller

    class EditingPDFController: PSPDFViewController {

        // MARK: Actions

        @objc func edit(_ sender: AnyObject) {
            guard let document = document else { return }
            guard let editor = PSPDFDocumentEditor(document: document) else { return }

            let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
            let anotherDocumentURL = samplesURL.appendingPathComponent("A.pdf")
            let anotherDocument = PSPDFDocument(url: anotherDocumentURL)

            // Copy page from another document
            let template = PSPDFPageTemplate(document: anotherDocument, sourcePageIndex: 0)
            let newPageConfiguration = PSPDFNewPageConfiguration(pageTemplate: template, builderBlock: nil)
            editor.addPages(in: NSRange(location: 0, length: 1), with: newPageConfiguration)

            // Save and overwrite the document.
            editor.save { _, error in
                if let error = error {
                    print("Document editing failed: \(error)")
                    return
                }

                // Access the UI on the main thread.
                DispatchQueue.main.async {
                    self.pdfController.reloadData()
                }
            }
        }
    }
}
