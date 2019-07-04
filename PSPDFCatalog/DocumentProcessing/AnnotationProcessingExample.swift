//
//  Copyright © 2016-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

/// Shows how to embed, flatten and remove annotations with `PSPDFProcessor`.
final class AnnotationProcessingExample: PSCExample {

    // MARK: Lifecycle

    override init() {
        super.init()

        title = "Annotation Processing"
        contentDescription = "Shows how to embed, flatten and remove annotations with PSPDFProcessor"
        category = .documentProcessing
        priority = 10
    }

    // MARK: PSCExample

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let document = PSCAssetLoader.document(withName: .quickStart)!
        return AnnotationProcessingPDFViewController(document: document)
    }
}

/// Processes annotations of it's document.
private final class AnnotationProcessingPDFViewController: PSPDFViewController {

    // MARK: Lifecycle

    override func commonInit(with document: PSPDFDocument?, configuration: PSPDFConfiguration) {
        super.commonInit(with: document, configuration: configuration)

        let actions = [("Embed", #selector(embedAnnotations)), ("Flatten", #selector(flattenAnnotations)), ("Remove", #selector(removeAnnotations))]
        let barButtonItems = actions.map { title, selector in
            UIBarButtonItem(title: title, style: .plain, target: self, action: selector)
        }
        navigationItem.setRightBarButtonItems(barButtonItems.reversed(), for: .document, animated: false)
    }

    // MARK: Bar Button Item Actions

    /// Presents document with annotations embedded.
    @objc
    private func embedAnnotations() {
        let embeddedDocumentURL = PSCTempFileURLWithPathExtension("embedded", "pdf")

        // We want to embed annotations, i.e. keep them editable.
        guard processAnnotations(.embed, document: document!, newDocumentURL: embeddedDocumentURL) else {
            presentErrorMessage("Embedding annotations failed.")
            return
        }

        presentProcessedDocument(embeddedDocumentURL)
    }

    /// Presents document with annotations flattened.
    @objc
    private func flattenAnnotations() {
        let flattenedDocumentURL = PSCTempFileURLWithPathExtension("flattened", "pdf")

        // We want to flatten annotations, i.e. make them non-editable.
        guard processAnnotations(.flatten, document: document!, newDocumentURL: flattenedDocumentURL) else {
            presentErrorMessage("Flattening annotations failed.")
            return
        }

        presentProcessedDocument(flattenedDocumentURL)
    }

    /// Presents document with annotations removed.
    @objc
    private func removeAnnotations() {
        let removedAnnotationsDocumentURL = PSCTempFileURLWithPathExtension("removedAnnotations", "pdf")

        // We want to remove annotations.
        guard processAnnotations(.remove, document: document!, newDocumentURL: removedAnnotationsDocumentURL) else {
            presentErrorMessage("Removing annotations failed.")
            return
        }

        presentProcessedDocument(removedAnnotationsDocumentURL)
    }

    // MARK: Document Processing

    /// Processes annotations.
    ///
    /// - Parameters:
    ///     - annotationChange: Which `PSPDFAnnotationChange` to perform.
    ///     - document: `PSPDFDocument` containing pages with annotations.
    ///     - newDocumentURL: `NSURL` that's used as output file URL of `PSPDFProcessor`.
    /// - Returns: `true` iff processing succeeded, `false` otherwise.
    private func processAnnotations(_ annotationChange: PSPDFAnnotationChange, document: PSPDFDocument, newDocumentURL: URL) -> Bool {
        // Set up configuration to flatten the document.
        guard let configuration = PSPDFProcessorConfiguration(document: document) else {
            print("Processor configuration needs a valid document")
            return false
        }

        // Process all types of annotations.
        configuration.modifyAnnotations(ofTypes: .all, change: annotationChange)

        // We are only interested in the pages that actually have annotations.
        configuration.includeOnlyIndexes(pagesWithAnnotations(document))

        do {
            // Process annotations.
            // `PSPDFProcessor` doesn't modify the document, but creates an output file instead.
            let processor = PSPDFProcessor(configuration: configuration, securityOptions: nil)
            processor.delegate = self
            try processor.write(toFileURL: newDocumentURL)
        } catch {
            print("Error while processing document: \(error)")
            return false
        }

        return true
    }

    // MARK: Helper

    /// Filters pages with annotations.
    ///
    /// - Parameter document: `PSPDFDocument` containing pages to filter.
    /// - Returns: `NSIndexSet` of pages with annotations.
    private func pagesWithAnnotations(_ document: PSPDFDocument) -> IndexSet {
        let pagesWithAnnotations = NSMutableIndexSet()
        let allTypesButLinkAndForms = AnnotationType.all.subtracting([.link, .widget])

        for page in 0..<document.pageCount {
            if document.annotationsForPage(at: page, type: allTypesButLinkAndForms).isEmpty { continue }
            pagesWithAnnotations.add(Int(page))
        }

        return pagesWithAnnotations as IndexSet
    }

    /// Presents a processed document.
    ///
    /// - Parameter processedDocumentURL: `NSURL` of processed document.
    private func presentProcessedDocument(_ processedDocumentURL: URL) {
        let processedDocument = PSPDFDocument(url: processedDocumentURL)
        let pdfController = PSPDFViewController(document: processedDocument)
        pdfController.navigationItem.setRightBarButtonItems([], for: .document, animated: false)
        let navigationController = UINavigationController(rootViewController: pdfController)
        present(navigationController, animated: true, completion: nil)
    }

    /// Presents an error message.
    ///
    /// - Parameter message: Error message to present.
    private func presentErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension AnnotationProcessingPDFViewController: PSPDFProcessorDelegate {
    func processor(_ processor: PSPDFProcessor, didProcessPage currentPage: UInt, totalPages: UInt) {
        print("Progress: \(currentPage + 1) of \(totalPages)")
    }
}
