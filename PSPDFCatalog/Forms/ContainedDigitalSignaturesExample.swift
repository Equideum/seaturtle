//
//  Copyright © 2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import PSPDFKit

class PrepareDocumentForContainedSignaturesExample: PSCExample {

    override init() {
        super.init()
        title = "Prepare a document to embed a digital signature afterwards"
        category = .forms
        priority = 20
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        // Load a sample document with an already created signature form field.
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let documentURL = samplesURL.appendingPathComponent("Form_example.pdf")
        let newURL = PSCCopyFileURLToDocumentFolderAndOverride(documentURL, true)
        let document = PSPDFDocument(url: newURL)

        // Now we get the signature form widget.
        let signatureFormElement = document.annotationsForPage(at: 0, type: .widget).first { annotation -> Bool in
            return annotation is PSPDFSignatureFormElement
        } as! PSPDFSignatureFormElement

        // During document preparation, we are able to configure a custom digital signature appearance.
        // We use an instance of a `PSPDFSignatureAppearance` to do that.
        let signatureAppearance = PSPDFSignatureAppearance { builder in
            builder.appearanceMode = PSPDFSignatureAppearanceMode.signatureAndDescription
            builder.showSigningDate = false
        }

        // Configure a data sink as destination.
        let dataSink = try! PSPDFFileDataSink(fileURL: newURL, options: [])

        // Now configure the signer that will prepare the signature field. Configuring the "signersName" property
        // will customize the signer's name that will appear on the visual signature.
        let signer = PSPDFSigner()
        signer.signersName = "PSPDFKit GmbH"
        var preparedDocument: PSPDFDocument?

        // Typically, when preparing a document, we are not interested in what is inside the contents of the signature form field.
        // Passing an instance of a `PSPDFBlankSignatureContents` will fill the contents with zeroes.
        let signatureContents = PSPDFBlankSignatureContents()
        signer.prepare(signatureFormElement, toBeSignedWith: signatureAppearance, contents: signatureContents, writingTo: dataSink) { (_ success: Bool, _ document: PSPDFDataSink?, _ err: Error?) in
            let fileDataProvider = PSPDFFileDataProvider(fileURL: newURL)
            fileDataProvider.replace(with: dataSink)
            preparedDocument = PSPDFDocument(dataProviders: [fileDataProvider])
        }

        return PSPDFViewController(document: preparedDocument!)
    }
}

/**
 A sample `PSPDFSignatureContents` implementation that constructs a signature container from a binary file (.bin).
 A real implementation would make use of the document byte range covered by a signature, hash it, encrypt it,
 and return an hex-encoded PKCS7 container.
*/
class BinaryFileSignatureContents: NSObject, PSPDFSignatureContents {
    func sign(_ dataToSign: Data) -> Data {
        return try! Data(contentsOf: self.signatureContentsPath)
    }

    init(signatureContentsPath: URL) {
        self.signatureContentsPath = signatureContentsPath
        super.init()
    }

    private let signatureContentsPath: URL
}

class EmebedContainedSignatureExample: PSCExample {

    override init() {
        super.init()
        title = "Embed a digital signature in an already prepared PDF document"
        category = .forms
        priority = 20
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        // Load a sample document with a signature form field that was already prepared for signing.
        // See `PrepareDocumentForContainedSignaturesExample` to learn how to do that.
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let documentURL = samplesURL.appendingPathComponent("DocumentPreparedToBeSigned.pdf")
        let newURL = PSCCopyFileURLToDocumentFolderAndOverride(documentURL, true)
        let document = PSPDFDocument(url: newURL)

        // Now we get the signature form widget.
        let signatureFormElement = document.annotationsForPage(at: 0, type: .widget).first { annotation -> Bool in
            return annotation is PSPDFSignatureFormElement
            } as! PSPDFSignatureFormElement

        // The prepared signature is a .bin file that contains a PKCS7 signature for this document.
        let preparedSignatureSampleURL = samplesURL.appendingPathComponent("DocumentPreparedToBeSigned.bin")
        let signatureContents = BinaryFileSignatureContents(signatureContentsPath: preparedSignatureSampleURL)
        let dataSink = try! PSPDFFileDataSink(fileURL: newURL, options: [])

        // Finally, create the signer and embed the PKCS7 signature in this document.
        let signer = PSPDFSigner()
        var preparedDocument: PSPDFDocument?
        signer.embedSignature(in: signatureFormElement, with: signatureContents, writingTo: dataSink) { (_ success: Bool, _ document: PSPDFDataSink?, _ err: Error?) in
            let fileDataProvider = PSPDFFileDataProvider(fileURL: newURL)
            fileDataProvider.replace(with: dataSink)
            // Optionally, here you could make sure that the signed document is valid.
            // Read the `PSPDFSignatureValidator` documentation to learn how to do that.
            preparedDocument = PSPDFDocument(dataProviders: [fileDataProvider])
        }

        return PSPDFViewController(document: preparedDocument!)
    }
}
