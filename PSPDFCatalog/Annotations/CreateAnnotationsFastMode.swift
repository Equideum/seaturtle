//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation
import PSPDFKit
import PSPDFKitUI
import PSPDFKitSwift

class CreateAnnotationsFastMode: PSCExample {

    override init() {
        super.init()
        title = "Create Free Text Annotations Continuously"
        contentDescription = "Shows a way to disable the automatic state ending after annotation creation"
        category = .annotations
        priority = 202
    }

    // store observer for later removal (if needed)
    private var observer: Any?

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let document = PSCAssetLoader.document(withName: .quickStart)!
        let pdfController = PSPDFViewController(document: document)

        observer = NotificationCenter.default.addObserver(forName: .PSPDFAnnotationsAdded, object: nil, queue: OperationQueue.main) { [weak pdfController] (notification) in
            guard let pdfController = pdfController else { return }

            // bail out if this is for another controller (e.g. split screen)
            // or if this inserts another annotation type.
            guard let annotation = (notification.object as? NSArray)?.firstObject as? PSPDFFreeTextAnnotation, annotation.document == pdfController.document else {
                return
            }

            // Set the state again on the main thread.
            DispatchQueue.main.async(execute: { [weak pdfController] () -> Void in
                if pdfController!.annotationStateManager.state == nil {
                    pdfController!.annotationStateManager.state = .freeText
                }
            })
        }

        return pdfController
    }
}
