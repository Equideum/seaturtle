//
//  Copyright © 2016-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import PSPDFKitSwift

/// Uses `PSPDFProcessor` to draw on all current pages of a document.
final class DrawOnPagesExample: PSCExample {

    // MARK: Lifecycle

    override init() {
        super.init()

        title = "Draw Watermarks On Pages"
        contentDescription = "Uses PSPDFProcessor to draw watermarks on all current pages of a document"
        category = .documentProcessing
        priority = 14
    }

    // MARK: PSCExample

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let document = PSCAssetLoader.document(withName: .quickStart)!
        guard let configuration = PSPDFProcessorConfiguration(document: document) else {
            fatalError("Processor configuration needs a valid document")
        }

        let renderDrawBlock: PSPDFRenderDrawBlock = { context, page, cropBox, _, _ in
            // Careful, this code is executed on background threads. Only use thread-safe drawing methods.
            let text = "PSPDF Live Watermark"
            let pageText = "On Page \(page + 1)"
            let stringDrawingContext = NSStringDrawingContext()
            stringDrawingContext.minimumScaleFactor = 0.1

            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 30),
                .foregroundColor: UIColor.red.withAlphaComponent(0.5)
            ]

            let pageTextAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: UIColor.black.withAlphaComponent(0.5)
            ]
            // Add text in the bottom right corner
            context.translateBy(x: (cropBox.size.width / 2) + 30, y: cropBox.size.height - 200)
            text.draw(with: cropBox, options: .usesLineFragmentOrigin, attributes: textAttributes, context: stringDrawingContext)
            // Add second text below the first text
            context.translateBy(x: 0, y: 30)
            pageText.draw(with: cropBox, options: .usesLineFragmentOrigin, attributes: pageTextAttributes, context: stringDrawingContext)

        }

        configuration.drawOnAllCurrentPages(renderDrawBlock)

        let processedDocumentURL = PSCTempFileURLWithPathExtension("processed", "pdf")

        // Process annotations.
        // `PSPDFProcessor` doesn't modify the document, but creates an output file instead.
        let processor = PSPDFProcessor(configuration: configuration, securityOptions: nil)
        processor.delegate = self
        try! processor.write(toFileURL: processedDocumentURL)

        let processedDocument = PSPDFDocument(url: processedDocumentURL)
        return PSPDFViewController(document: processedDocument)
    }
}

extension DrawOnPagesExample: PSPDFProcessorDelegate {
    func processor(_ processor: PSPDFProcessor, didProcessPage currentPage: UInt, totalPages: UInt) {
        print("Progress: \(currentPage + 1) of \(totalPages)")
    }
}
