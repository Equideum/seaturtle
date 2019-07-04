//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'PSCCreatePasswordProtectedDocumentExample.m' for the Objective-C version of this example.

import Foundation

class CreatePasswordProtectedDocumentExample: PSCExample {

    override init() {
        super.init()
        title = "Create password protected PDF"
        contentDescription = "Password is 'test123'"
        category = .security
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        let password = "test123"
        let tempURL = PSCTempFileURLWithPathExtension("protected", "pdf")
        let hackerMagDoc = PSCAssetLoader.document(withName: .JKHF)
        let status = PSPDFStatusHUDItem.progress(withText: PSPDFLocalize("Preparing") + ("…"))
        status.push(animated: true)

        // By default, a newly initialized `PSPDFProcessorConfiguration` results in an exported Document that is the same as the input.
        let processorConfiguration = PSPDFProcessorConfiguration(document: hackerMagDoc)

        // Set the proper password and key length in the `PSPDFDocumentSecurityOptions`
        let documentSecurityOptions = try? PSPDFDocumentSecurityOptions(ownerPassword: password, userPassword: password, keyLength: PSPDFDocumentSecurityOptionsKeyLengthAutomatic)

        DispatchQueue.global(qos: .default).async(execute: {() -> Void in
            do {
                // Process annotations.
                // `PSPDFProcessor` doesn't modify the document, but creates an output file instead.
                let processor = PSPDFProcessor(configuration: processorConfiguration!, securityOptions: documentSecurityOptions)
                processor.delegate = self
                try processor.write(toFileURL: tempURL)
            } catch {
                print("Error while processing document: \(error)")
                return
            }
            DispatchQueue.main.async(execute: {() -> Void in
                status.pop(animated: true)
                // show file
                let document = PSPDFDocument(url: tempURL)
                let pdfController = PSPDFViewController(document: document)
                delegate.currentViewController?.navigationController?.pushViewController(pdfController, animated: true)
            })
        })
        return nil
    }
}

extension CreatePasswordProtectedDocumentExample: PSPDFProcessorDelegate {
    func processor(_ processor: PSPDFProcessor, didProcessPage currentPage: UInt, totalPages: UInt) {
        print("Progress: \(currentPage + 1) of \(totalPages)")
    }
}
