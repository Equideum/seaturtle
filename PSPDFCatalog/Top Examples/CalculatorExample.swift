//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

class CalculatorExample: PSCExample {
    override init() {
        super.init()

        title = "Calculator in a PDF with embedded JavaScript"
        contentDescription = "Example showing JavaScript support in PSPDFKit."
        category = .top
        priority = 900
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let document = PSCAssetLoader.document(withName: PSCAssetName(rawValue: "calculator.pdf"))

        // Create a custom configuration that hides the UI elements that are not relevant for this example.
        let configuration = PSPDFConfiguration {
            $0.thumbnailBarMode = .none
            $0.isPageLabelEnabled = false
            $0.shouldShowUserInterfaceOnViewWillAppear = false
        }

        let pdfController = PSPDFViewController(document: document, configuration: configuration)
        // Hide the default PSPDFViewController navigation items.
        pdfController.navigationItem.rightBarButtonItems = []

        return pdfController
    }

}
