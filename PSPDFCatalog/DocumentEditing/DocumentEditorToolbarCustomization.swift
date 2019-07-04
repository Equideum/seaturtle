//
//  Copyright © 2016-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

class DocumentEditorToolbarCustomization: PSCExample {

    // MARK: PSCExample

    override init() {
        super.init()
        title = "Document Editor Toolbar Customization"
        contentDescription = "Customize the new page button and remove all remaining buttons."
        category = .documentEditing
        priority = 1
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        // Let's create a new writable document every time we invoke the example for the
        // purpose of this example.
        let writableURL: URL
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let sourceURL = samplesURL.appendingPathComponent(PSCAssetName.quickStart.rawValue)
        writableURL = PSCCopyFileURLToDocumentFolderAndOverride(sourceURL, true)

        let document = PSPDFDocument(url: writableURL)
        let pdfController = PSPDFViewController(document: document, configuration: PSPDFConfiguration {
            $0.overrideClass(PSPDFDocumentEditorToolbarController.self, with: FixedPageToolbarController.self)
            $0.overrideClass(PSPDFDocumentEditorToolbar.self, with: FixedPageToolbar.self)
        })

        // Immediateley switch into document editor.
        pdfController.viewMode = .documentEditor

        return pdfController
    }

    // MARK: - Toolbar Controller

    private class FixedPageToolbarController: PSPDFDocumentEditorToolbarController {

        override init(toolbar: PSPDFFlexibleToolbar) {
            super.init(toolbar: toolbar)

            // Replace the default action.
            let addPageButton = documentEditorToolbar.addPageButton
            addPageButton.removeTarget(nil, action: nil, for: .touchUpInside)
            addPageButton.addTarget(self, action: #selector(addNewFixedPage), for: .touchUpInside)
        }

        convenience override init(documentEditorToolbar: PSPDFDocumentEditorToolbar) {
            self.init(toolbar: documentEditorToolbar)
        }

        @objc func addNewFixedPage(_ sender: AnyObject) {
            guard let editor = documentEditor else {
                return
            }
            let pageSize = editor.pageSizeForPage(at: 0)
            let newPageConfiguration = PSPDFNewPageConfiguration(pageTemplate: PSPDFPageTemplate(pageType: .tiledPatternPage, identifier: .grid5mm)) { builder in
                builder.pageSize = pageSize
                builder.backgroundColor = UIColor(white: 0.95, alpha: 1)
            }
            editor.addPages(in: NSRange(location: 0, length: 1), with: newPageConfiguration)
        }
    }

    // MARK: - Toolbar

    private class FixedPageToolbar: PSPDFDocumentEditorToolbar {

        // An alternative would be to override the individual button properties and return nil.
        override func buttons(forWidth width: CGFloat) -> [PSPDFToolbarButton] {
            return super.buttons(forWidth: width).filter { button in
                // Keep the done button, add page button and spacers.
                button === doneButton || button === addPageButton || button.isFlexible == true
            }
        }
    }
}
