//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation
import PSPDFKitSwift

final class ReportPDFGenerationExample: PSCExample {
    var statusHUDItem: PSPDFStatusHUDItem?

    // MARK: Lifecycle

    override init() {
        super.init()

        title = "Generate a PDF Report"
        contentDescription = "Generate a PDF document on a mobile device without any server use."
        category = .documentGeneration
        priority = 1
    }

    // MARK: PSCExample

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {

        // Get base document
        let document = PSCAssetLoader.document(withName: .annualReport)!
        guard let configuration = PSPDFProcessorConfiguration(document: document) else {
            fatalError("Processor configuration needs a valid document")
        }

        // Keep only the first and the last page of the original document.
        configuration.removePages(IndexSet(1..<Int(document.pageCount - 1)))

        // Add a newly created single-paged document as the second page of the report
        let pageInfo = document.pageInfoForPage(at: 0)!
        let secondPageDocument = self.generateSecondPage(pageInfo: pageInfo)
        let secondPageTemplate = PSPDFPageTemplate(document: secondPageDocument, sourcePageIndex: 0)
        configuration.addNewPage(at: 1, configuration: PSPDFNewPageConfiguration(pageTemplate: secondPageTemplate, builderBlock: nil))

        // Add a new page with a pattern grid as the third page of the report.
        configuration.addNewPage(at: 2, configuration: PSPDFNewPageConfiguration(pageTemplate: PSPDFPageTemplate(pageType: .tiledPatternPage, identifier: .grid5mm), builderBlock: { (builder) in
            builder.backgroundColor = .white
        }))

        // Add a page from an existing document.
        let quickStartDocument = PSCAssetLoader.document(withName: .quickStart)!
        let quickStartTemplate = PSPDFPageTemplate(document: quickStartDocument, sourcePageIndex: 7)
        configuration.addNewPage(at: 3, configuration: PSPDFNewPageConfiguration(pageTemplate: quickStartTemplate, builderBlock: nil))

        // Scale the recently added page to the first page size
        configuration.scalePage(3, to: pageInfo.size)

        // Draw "Generated for John Doe. Page X" on every page
        self.drawWatermark(name: "John Doe", configuration: configuration)

        // Flatten all annotations.
        configuration.modifyAnnotations(ofTypes: .all, change: .flatten)

        // Set owner password to only allow printing
        let ownerPassword = "test123"
        let documentSecurityOptions = try? PSPDFDocumentSecurityOptions(ownerPassword: ownerPassword, userPassword: nil, keyLength: PSPDFDocumentSecurityOptionsKeyLengthAutomatic, permissions: [.printing])
        let processedDocumentURL = PSCTempFileURLWithPathExtension("processed", "pdf")

        statusHUDItem = PSPDFStatusHUDItem.progress(withText: PSPDFLocalize("Preparing") + ("…"))
        statusHUDItem?.push(animated: true)

        DispatchQueue.global(qos: .default).async(execute: {() -> Void in
            // Process annotations.
            // `PSPDFProcessor` doesn't modify the document, but creates an output file instead.
            let processor = PSPDFProcessor(configuration: configuration, securityOptions: documentSecurityOptions)
            processor.delegate = self
            try! processor.write(toFileURL: processedDocumentURL)

            DispatchQueue.main.async(execute: { [weak self] () -> Void in
                guard let self = self else {
                    return
                }

                self.statusHUDItem?.pop(animated: true)
                self.statusHUDItem = nil
                // The newly processed PSPDFDocument.
                let processedDocument = PSPDFDocument(url: processedDocumentURL)
                processedDocument.title = "Generated PDF Report"
                let pdfController = PSPDFViewController(document: processedDocument)
                pdfController.navigationItem.rightBarButtonItems = [pdfController.annotationButtonItem, pdfController.searchButtonItem, pdfController.activityButtonItem]
                delegate.currentViewController?.navigationController?.pushViewController(pdfController, animated: true)
                self.presentSuccessAlert(viewController: pdfController)
            })
        })

        return nil
    }

    // MARK: Private
    private func generateSecondPage(pageInfo: PSPDFPageInfo) -> PSPDFDocument {
        // Create a separate single-paged document, which will be added as the second page of the report.
        let secondPageConfiguration = PSPDFProcessorConfiguration()
        let blankPageConfiguration = PSPDFNewPageConfiguration(pageTemplate: PSPDFPageTemplate.blank) { (builder) in
            builder.backgroundColor = .white
            builder.pageSize = pageInfo.size
        }
        secondPageConfiguration.addNewPage(at: 0, configuration: blankPageConfiguration)

        // Invoke processor to create new document.
        let processor = PSPDFProcessor(configuration: secondPageConfiguration, securityOptions: nil)
        processor.delegate = self
        let data = try? processor.data()

        // Create the document which will be the report's second page
        let secondPageDocument = PDFDocument(dataProviders: [PSPDFDataContainerProvider(data: data!)])

        // Create a free text annotation as the title of the second page.
        let titleFreeTextAnnotation = PSPDFFreeTextAnnotation()
        titleFreeTextAnnotation.boundingBox = CGRect(x: 228, y: 924, width: 600, height: 80)
        titleFreeTextAnnotation.contents = "Some Annotations"
        titleFreeTextAnnotation.fontSize = 40

        // Create a vector stamp annotation on the second page.
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let logoURL = samplesURL.appendingPathComponent("PSPDFKit Logo.pdf")

        let vectorStamp = PSPDFStampAnnotation()
        vectorStamp.boundingBox = CGRect(x: 50, y: 724, width: 200, height: 200)
        vectorStamp.appearanceStreamGenerator = PSPDFFileAppearanceStreamGenerator(fileURL: logoURL)

        // Create a free text annotation which describes the vector stamp
        let vectorStampDescriptionFreeTextAnnotation = PSPDFFreeTextAnnotation()
        vectorStampDescriptionFreeTextAnnotation.contents = "The logo above is a vector stamp annotation."
        vectorStampDescriptionFreeTextAnnotation.boundingBox = CGRect(x: 67, y: 620, width: 600, height: 80)
        vectorStampDescriptionFreeTextAnnotation.fontSize = 18

        // Create an image stamp annotation on the second page.
        let imageStamp = PSPDFStampAnnotation()
        imageStamp.image = UIImage(named: "exampleimage.jpg")
        imageStamp.boundingBox = CGRect(x: 60, y: 400, width: (imageStamp.image?.size.width)! / 4, height: (imageStamp.image?.size.height)! / 4)

        // Create a free text annotation which describes the image stamp
        let imageStampDescriptionFreeTextAnnotation = PSPDFFreeTextAnnotation()
        imageStampDescriptionFreeTextAnnotation.contents = "The image above is an image stamp annotation."
        imageStampDescriptionFreeTextAnnotation.boundingBox = CGRect(x: 67, y: 290, width: 600, height: 80)
        imageStampDescriptionFreeTextAnnotation.fontSize = 18

        // Add annotations to the newly processed document.
        secondPageDocument.add([titleFreeTextAnnotation, vectorStamp, vectorStampDescriptionFreeTextAnnotation, imageStamp, imageStampDescriptionFreeTextAnnotation])

        guard let flattenedSecondPageConfiguration = PSPDFProcessorConfiguration(document: secondPageDocument) else {
            fatalError("Processor configuration needs a valid document")
        }

        // Flatten all annotations
        flattenedSecondPageConfiguration.modifyAnnotations(ofTypes: .all, change: .flatten)
        let flattenedSecondPageOutputFileURL = PSCTempFileURLWithPathExtension("flattened-second-page", "pdf")
        let secondPageProcessor = PSPDFProcessor(configuration: flattenedSecondPageConfiguration, securityOptions: nil)
        secondPageProcessor.delegate = self
        try? secondPageProcessor.write(toFileURL: flattenedSecondPageOutputFileURL)

        return PSPDFDocument(url: flattenedSecondPageOutputFileURL)
    }

    private func drawWatermark(name: String, configuration: PSPDFProcessorConfiguration) {
        let renderDrawBlock: PDFRenderDrawBlock = { context, page, cropBox, _, _ in
            // Careful, this code is executed on background threads. Only use thread-safe drawing methods.
            let text = "Generated for \(name). Page \(page + 1)"
            let stringDrawingContext = NSStringDrawingContext()
            stringDrawingContext.minimumScaleFactor = 0.1

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 30),
                .foregroundColor: UIColor.red.withAlphaComponent(0.5)
            ]
            // Add text in the bottom center
            context.translateBy(x: (cropBox.size.width / 2) - 230, y: cropBox.size.height - 100)
            text.draw(with: cropBox, options: .usesLineFragmentOrigin, attributes: attributes, context: stringDrawingContext)
        }
        // Draw at the bottom of all pages.
        configuration.drawOnAllCurrentPages(renderDrawBlock)
    }

    private func presentSuccessAlert(viewController: UIViewController) {
        let message = "1. Keep only the first and the last page of the original document.\n2. Add a newly created single-paged document as the second page of the report.\n3. Add a new page with a pattern grid as the third page of the report.\n4. Add a page from an existing document on disk.\n5. Draw watermark on every page.\n6. Flatten all annotations.\n7. Set owner password to only allow printing."
        let alert = UIAlertController(title: "Successful PDF Report Generation", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}

extension ReportPDFGenerationExample: PSPDFProcessorDelegate {
    func processor(_ processor: PSPDFProcessor, didProcessPage currentPage: UInt, totalPages: UInt) {
        statusHUDItem?.progress = CGFloat((currentPage + 1) / totalPages)
        print("Progress: \(currentPage + 1) of \(totalPages)")
    }
}
