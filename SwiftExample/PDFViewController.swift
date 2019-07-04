//
//  Copyright © 2014-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import UIKit
import PSPDFKitUI

class PDFViewController: PSPDFViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        processorExample()
    }

    /// Sample call how to use `PSPDFProcessor` in Swift.
    func processorExample() {
        guard let document = document else { return }

        let indexSet = IndexSet(integersIn: 0..<Int(document.pageCount))
        let url = URL(fileURLWithPath: (NSTemporaryDirectory() as NSString).appendingPathComponent("export.pdf"))
        guard let configuration = PSPDFProcessorConfiguration(document: document) else { return }
        configuration.includeOnlyIndexes(indexSet)
        do {
            let processor = PSPDFProcessor(configuration: configuration, securityOptions: nil)
            processor.delegate = self
            try processor.write(toFileURL: url)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

// MARK: PSPDFProcessorDelegate

extension PDFViewController: PSPDFProcessorDelegate {
    func processor(_ processor: PSPDFProcessor, didProcessPage currentPage: UInt, totalPages: UInt) {
        print("Progress: \(currentPage + 1) of \(totalPages)")
    }
}

// MARK: PSPDFViewControllerDelegate

extension PDFViewController: PSPDFViewControllerDelegate {

    func pdfViewController(_ pdfController: PSPDFViewController, didConfigurePageView pageView: PSPDFPageView) {
        print("Page loaded: %@", pageView)
    }
}
