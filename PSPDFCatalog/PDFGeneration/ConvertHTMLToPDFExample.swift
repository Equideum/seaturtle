//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

//  MIT License (MIT) for Simple HTML invoice template: https://github.com/sparksuite/simple-html-invoice-template/blob/master/LICENSE

class ConvertHTMLToPDFExample: PSCExample {

    override init() {
        super.init()

        title = "Convert HTML to PDF"
        contentDescription = "Convert a URL containing simple HTML to PDF."
        category = .documentGeneration
        priority = 10
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        let htmlFileURL = Bundle.main.url(forResource: "invoice", withExtension: "html", subdirectory: "Samples")!
        let htmlString = try! String(contentsOf: htmlFileURL, encoding: .utf8)
        let outputURL = PSCTempFileURLWithPathExtension("converted", "pdf")

        // start the conversion
        let status = PSPDFStatusHUDItem.indeterminateProgress(withText: "Converting...")
        status.setHUDStyle(.black)
        status.push(animated: true, completion: nil)

        let options = [PSPDFProcessorNumberOfPagesKey: 1, PSPDFProcessorDocumentTitleKey: "Generated PDF"] as [String: Any]
        let processor = PSPDFProcessor(options: options)
        processor.convertHTMLString(htmlString, outputFileURL: outputURL) { _ in
            // Update status to done.
            let statusDone = PSPDFStatusHUDItem.success(withText: "Done")
            statusDone.pushAndPop(withDelay: 2, animated: true)
            status.pop(animated: true)

            // Generate document and show it.
            let document = PSPDFDocument(url: outputURL)
            let pdfController = PSPDFViewController(document: document)
            delegate.currentViewController!.navigationController?.pushViewController(pdfController, animated: true)
        }
        return nil
    }
}
