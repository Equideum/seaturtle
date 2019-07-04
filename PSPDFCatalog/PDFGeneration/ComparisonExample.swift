//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'PSCComparisonExample.m' for the Objective-C version of this example.

class ComparisonExample: PSCExample {

    override init() {
        super.init()
        title = "Document Comparison"
        contentDescription = "Compare PDFs by using a different stroke color for each document."
        category = .documentGeneration
        priority = 5
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let firstDocument = PSCAssetLoader.document(withName: PSCAssetName(rawValue: "FloorPlan_1.pdf"))!
        let secondDocument = PSCAssetLoader.document(withName: PSCAssetName(rawValue: "FloorPlan_2.pdf"))!

        let tabbedController = PSPDFTabbedViewController()
        tabbedController.documents = generateComparisonDocuments(byMerging: firstDocument, with: secondDocument)
        tabbedController.setVisibleDocument(tabbedController.documents[2], scrollToPosition: false, animated: false)
        return tabbedController
    }

    func generateComparisonDocuments(byMerging firstDocument: PSPDFDocument, with secondDocument: PSPDFDocument) -> [PSPDFDocument] {
        let greenDocument = self.createNewPDF(from: firstDocument, withStrokeColor: .green, fileName: "Old.pdf")
        let redDocument = self.createNewPDF(from: secondDocument, withStrokeColor: .red, fileName: "New.pdf")

        let configuration = PSPDFProcessorConfiguration(document: greenDocument)!
        configuration.mergePage(from: redDocument, password: nil, sourcePageIndex: 0, destinationPageIndex: 0, transform: .identity, blendMode: .darken)

        let processor = PSPDFProcessor(configuration: configuration, securityOptions: nil)
        let mergedDocumentURL = ComparisonExample.temporaryURL(with: "Comparison.pdf")
        try! processor.write(toFileURL: mergedDocumentURL)

        let mergedDocument = PSPDFDocument(url: mergedDocumentURL)
        return [greenDocument, redDocument, mergedDocument]
    }

    func createNewPDF(from document: PSPDFDocument, withStrokeColor strokeColor: UIColor, fileName: String) -> PSPDFDocument {
        let configuration = PSPDFProcessorConfiguration(document: document)!
        configuration.changeStrokeColorOnPage(at: 0, to: strokeColor)

        let processor = PSPDFProcessor(configuration: configuration, securityOptions: nil)
        let destinationURL = ComparisonExample.temporaryURL(with: fileName)
        try! processor.write(toFileURL: destinationURL)
        return PSPDFDocument(url: destinationURL)
    }

    class func temporaryURL(with name: String) -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)
    }
}
