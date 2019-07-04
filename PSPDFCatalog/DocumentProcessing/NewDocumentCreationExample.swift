//
//  Copyright © 2016-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

/// Shows how to create a new document with `PSPDFProcessor`.
final class NewDocumentCreationExample: PSCExample {

    // MARK: Lifecycle

    override init() {
        super.init()

        title = "Create new document"
        contentDescription = "Uses PSPDFProcessor to create a new document"
        category = .documentProcessing
        priority = 11
    }

    // MARK: PSCExample

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        // Set up configuration to create a new document.
        let configuration = PSPDFProcessorConfiguration()

        // Add an empty page with image in the bottom center.
        let backgroundColor = UIColor(red: 0.965, green: 0.953, blue: 0.906, alpha: 1)
        let image = UIImage(named: "exampleimage.jpg")!
        let emptyPageTemplate = PSPDFPageTemplate.blank
        let newPageConfiguration = PSPDFNewPageConfiguration(pageTemplate: emptyPageTemplate) { (builder) in
            builder.backgroundColor = backgroundColor
            builder.pageMargins = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
            builder.item = PSPDFProcessorItem(image: image, jpegCompressionQuality: 0.8) { itemBuilder in
                itemBuilder.alignment = .alignBottom
                itemBuilder.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            }
        }
        configuration.addNewPage(at: 0, configuration: newPageConfiguration)

        // Add a page with a pattern grid.
        configuration.addNewPage(at: 1, configuration: PSPDFNewPageConfiguration(pageTemplate: PSPDFPageTemplate(pageType: .tiledPatternPage, identifier: .grid5mm), builderBlock: { (builder) in
            builder.backgroundColor = backgroundColor
        }))

        // Add a page from a different document.
        let document = PSCAssetLoader.document(withName: .quickStart)!
        let documentTemplate = PSPDFPageTemplate(document: document, sourcePageIndex: 7)
        configuration.addNewPage(at: 2, configuration: PSPDFNewPageConfiguration(pageTemplate: documentTemplate, builderBlock: nil))

        let outputFileURL = PSCTempFileURLWithPathExtension("new-document", "pdf")
        do {
            // Invoke processor to create new document.
            let processor = PSPDFProcessor(configuration: configuration, securityOptions: nil)
            processor.delegate = self
            try processor.write(toFileURL: outputFileURL)
        } catch {
            print("Error while processing document: \(error)")
        }

        // Init new document and view controller.
        let newDocument = PSPDFDocument(url: outputFileURL)
        let pdfController = PSPDFViewController(document: newDocument)

        return pdfController
    }
}

extension NewDocumentCreationExample: PSPDFProcessorDelegate {
    func processor(_ processor: PSPDFProcessor, didProcessPage currentPage: UInt, totalPages: UInt) {
        print("Progress: \(currentPage + 1) of \(totalPages)")
    }
}
