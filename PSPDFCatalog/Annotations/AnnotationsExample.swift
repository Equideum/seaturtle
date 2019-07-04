//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'PSCAnnotationsExample.m' for the Objective-C version of this example.

import PSPDFKitSwift

class CustomAnnotationsWithMultipleFilesExample: PSCExample {

    override init() {
        super.init()

        title = "Custom annotations with multiple files"
        category = .annotations
        priority = 400
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        let dataProviders = ["A", "B", "C", "D"].map { PSPDFCoordinatedFileDataProvider(fileURL: Bundle.main.url(forResource: $0, withExtension: "pdf", subdirectory: "Samples")!) }
        let document = PDFDocument(dataProviders: dataProviders)

        // contentMode(2) = UIViewContentModeScaleAspectFill
        let aVideo = PSPDFLinkAnnotation(url: (URL(string: "pspdfkit://[contentMode=2]localhost/Bundle/big_buck_bunny.mp4"))!)
        aVideo.boundingBox = CGRect(origin: .zero, size: document.pageInfoForPage(at: 5)!.size)
        aVideo.pageIndex = 5
        document.add([aVideo])

        let anImage = PSPDFLinkAnnotation(url: (URL(string: "pspdfkit://[contentMode=2]localhost/Bundle/exampleImage.jpg"))!)
        anImage.boundingBox = CGRect(origin: .zero, size: document.pageInfoForPage(at: 2)!.size)
        anImage.pageIndex = 2
        document.add([anImage])

        let controller = PSPDFViewController(document: document)
        return controller

    }
}

class AnnotationLinkstoExternalDocumentsExample: PSCExample {

    override init() {
        super.init()

        title = "Annotation Links to external documents"
        contentDescription = "PDF links can point to pages within the same document, or also different documents or websites."
        category = .annotations
        priority = 600
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        let document = PSCAssetLoader.document(withName: PSCAssetName(rawValue: "one.pdf"))
        return PSPDFViewController(document: document)
    }
}
