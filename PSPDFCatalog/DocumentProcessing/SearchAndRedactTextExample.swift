//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

class SearchAndRedactTextExample: PSCExample {

    override init() {
        super.init()

        title = "Search and Redact Text"
        contentDescription = "Shows how to search and redact text."
        category = .documentProcessing
        priority = 15
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        let redactionPrompt = UIAlertController(title: "Search and Redact Text", message: "Enter a word to redact:", preferredStyle: .alert)
        redactionPrompt.addTextField { textField in
            textField.text = "PSPDFKit"
        }

        redactionPrompt.addAction(UIAlertAction(title: "Redact", style: .default) { [weak redactionPrompt] _ in
            let wordToRedact = redactionPrompt?.textFields?.first?.text!
            let document = PSCAssetLoader.document(withName: .quickStart)!
            let status = PSPDFStatusHUDItem.indeterminateProgress(withText: "Processing...")
            status.push(animated: true, completion: nil)

            // Loop through all the pages of the document to find the search term.
            // In production we recommend doing this on a uitility queue.
            // Note: The search is case sensitive.
            for pageIndex in 0..<document.pageCount {
                if let textParser = document.textParserForPage(at: pageIndex) {
                    textParser.words.forEach { word in
                        // Redact all the words that contain the search term.
                        if word.stringValue.range(of: wordToRedact!) != nil {
                            let redaction = self.createRedactionAnnotationFor(word: word, pageIndex: pageIndex)
                            document.add([redaction])
                        }
                    }
                }
            }

            DispatchQueue.global(qos: .default).async {
                // Use PSPDFProcessor to create the newly redacted document.
                let processorConfiguration = PSPDFProcessorConfiguration(document: document)!
                processorConfiguration.applyRedactions()

                let redactedDocumentURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("redacted.pdf")
                let processor = PSPDFProcessor(configuration: processorConfiguration, securityOptions: nil)
                try? processor.write(toFileURL: redactedDocumentURL)

                DispatchQueue.main.async {
                    status.pop(animated: true)
                    // Instantiate the redacted document and present it.
                    let redactedDocument = PSPDFDocument(url: redactedDocumentURL)
                    let pdfController = PSPDFViewController(document: redactedDocument)
                    delegate.currentViewController!.navigationController?.pushViewController(pdfController, animated: true)
                }
            }
        })

        redactionPrompt.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        delegate.currentViewController!.present(redactionPrompt, animated: true)
        return nil
    }

    // MARK: Private
    private func createRedactionAnnotationFor(word: PSPDFWord, pageIndex: PageIndex) -> PSPDFRedactionAnnotation {
        let redactionRect = word.frame
        let redaction = PSPDFRedactionAnnotation()
        redaction.boundingBox = redactionRect
        redaction.rectsTyped = [redactionRect]
        redaction.color = .orange
        redaction.fillColor = .black
        redaction.overlayText = "REDACTED"
        redaction.pageIndex = pageIndex
        return redaction
    }
}
