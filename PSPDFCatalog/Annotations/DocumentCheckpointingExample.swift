//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import UIKit
import PSPDFKit

/// Simple example to demonstrate how checkpointing works.
class DocumentCheckpointingExample: PSCExample {
    override init() {
        super.init()

        title = "Document Checkpointing"
        contentDescription = "Demonstrates use of document checkpointing API"
        category = .annotations
        priority = 2000
    }

    private var annotatedDocument: PSPDFDocument?

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        guard let document = PSCAssetLoader.writableDocument(withName: PSCAssetName.about, overrideIfExists: true) else {
            fatalError("Document not found")
        }

        // Checkpoint the document as soon as the annotation is added.
        document.checkpointer.strategy = .immediate

        let pdfController = PSPDFViewController()
        let notificationName = NSNotification.Name.PSPDFDocumentCheckpointSaved
        var observer: AnyObject?
        observer = NotificationCenter.default.addObserver(forName: notificationName, object: document.checkpointer, queue: OperationQueue.main) { (_) in
            NotificationCenter.default.removeObserver(observer!)

            // In practice, you would always want to use this initialiser when creating documents that may have been changed by the user.
            let documentWithCheckpoint = PSPDFDocument(dataProviders: [PSPDFCoordinatedFileDataProvider(fileURL: document.fileURL!)], loadCheckpointIfAvailable: true)
            pdfController.document = documentWithCheckpoint

            // At this point, the document is not saved, but still has the annotation.
            // Calling PSPDFDocument.save() will save the annotations restored from the checkpoint to the document.
            NSLog("Annotation from checkpoint: \(document.allAnnotations(of: .square))")
        }

        let annotation = PSPDFSquareAnnotation()
        annotation.boundingBox = CGRect(x: 20, y: 200, width: 100, height: 100)
        annotation.fillColor = .red

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Add the annotation to the document.
            document.add([annotation])
        }
        return pdfController
    }
}
