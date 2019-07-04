//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

class DocumentEditorCustomTemplates: PSCExample {
    override init() {
        super.init()
        title = "Add New Page from Custom Template"
        contentDescription = "Use custom templates to add new pages to a document."
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

    class EditingPDFController: PSPDFViewController, PSPDFNewPageViewControllerDelegate {
        // MARK: Actions

        @objc func edit(_ sender: AnyObject) {
            let url = PSCAssetLoader.document(withName: .about)!.fileURL!
            let document = PSPDFDocument(url: url)
            let customTemplate = PSPDFPageTemplate(document: document, sourcePageIndex: 0)

            let editorConfiguration = PSPDFDocumentEditorConfiguration { (builder) in
                builder.pageTemplates.append(contentsOf: [customTemplate])
            }

            let newPageViewController = PSPDFNewPageViewController(documentEditorConfiguration: editorConfiguration)
            newPageViewController.delegate = self
            newPageViewController.modalPresentationStyle = .popover

            let options = [PSPDFPresentationInNavigationControllerKey: true, PSPDFPresentationCloseButtonKey: true]
            present(newPageViewController, options: options, animated: true, sender: sender)
        }

        func newPageController(_ controller: PSPDFNewPageViewController, didFinishSelecting configuration: PSPDFNewPageConfiguration?, pageCount: PageCount) {
            dismiss(animated: true, completion: nil)

            guard let document = document, let configuration = configuration, let editor = PSPDFDocumentEditor(document: document) else { return }

            editor.addPages(in: NSRange(location: 0, length: 1), with: configuration)

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
