//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

class LockAnnotationsExample: PSCExample {

    override init() {
        super.init()

        title = "Generate a new file with locked annotations"
        contentDescription = "Uses the annotation flags to create a locked copy."
        category = .annotations
        priority = 1000
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        // We use the same URL as in the "Write annotations into the PDF" example.

        // Original URL for the example file.
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let annotationsSavingURL = samplesURL.appendingPathComponent(PSCAssetNameJKHF)

            // Document-based URL (we use the changed file from "writing annotations into a file" for additional test annotations)
        let documentSamplesURL = PSCCopyFileURLToDocumentFolderAndOverride(annotationsSavingURL, false)

        // Target temp directory and copy file.
        let tempURL = PSCTempFileURLWithPathExtension("locked_#\(documentSamplesURL)", "pdf")
        if FileManager.default.fileExists(atPath: documentSamplesURL.path) {
            try? FileManager.default.copyItem(at: documentSamplesURL, to: tempURL)
        } else {
           try? FileManager.default.copyItem(at: annotationsSavingURL!, to: tempURL)
        }

        // Open the new file and modify the annotations to be locked.
        let document = PSPDFDocument(url: tempURL)
        document.annotationSaveMode = .embedded

        // Create at least one annotation if the document is currently empty.
       // if document.annotationsForPage(at: 0, type: PSPDFAnnotationType.link & ~PSPDFAnnotationType.link) {
        let controller = PSPDFViewController(document: document)
        return controller
    }
}
