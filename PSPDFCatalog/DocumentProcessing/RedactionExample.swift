//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

final class RedactionExample: PSCExample {

    // MARK: Lifecycle

    override init() {
        super.init()

        title = "Redaction"
        contentDescription = "Shows how to redact text with PSPDFProcessor."
        category = .documentProcessing
        priority = 12
    }

    // MARK: PSCExample

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let document = PSCAssetLoader.document(withName: .quickStart)!
        // Change the UID so the annotations we add in this example
        // don't show up in other examples using this document,
        // and are saved to an external file.
        document.uid = "QuickStart Redaction"

        // If there are any existing redact annotations, remove them.
        let existingRedactAnnotations = document.annotationsForPage(at: 0, type: .redaction)
        document.remove(annotations: existingRedactAnnotations)

        // Add a redact annotation over the word 'QuickStart' on the first page.
        if let textParser = document.textParserForPage(at: 0),
            let wordToRedact = textParser.words.first(where: { $0.stringValue == "QuickStart" }) {

            let redactionRect = wordToRedact.frame

            let redaction = PSPDFRedactionAnnotation()
            redaction.boundingBox = redactionRect
            redaction.rectsTyped = [redactionRect]
            redaction.color = .orange
            redaction.fillColor = .black
            redaction.outlineColor = .green
            redaction.overlayText = "REDACTED"

            document.add([redaction])
        }

        return RedactionPDFViewController(document: document)
    }

    final class RedactionPDFViewController: PSPDFViewController {
        override func commonInit(with document: PSPDFDocument?, configuration: PSPDFConfiguration) {
            super.commonInit(with: document, configuration: configuration)

            let redactButton = UIBarButtonItem(title: "Redact", style: .plain, target: self, action: #selector(applyRedactions))

            navigationItem.setRightBarButtonItems([annotationButtonItem, activityButtonItem, outlineButtonItem, redactButton], for: .document, animated: false)
        }

        @objc func applyRedactions() {
            let processorConfiguration = PSPDFProcessorConfiguration(document: document)!
            processorConfiguration.applyRedactions()

            let redactedDocumentURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("redacted.pdf")
            let processor = PSPDFProcessor(configuration: processorConfiguration, securityOptions: nil)
            try? processor.write(toFileURL: redactedDocumentURL)

            self.document = PSPDFDocument(url: redactedDocumentURL)
        }
    }
}
