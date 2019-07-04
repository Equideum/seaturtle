//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'PSCAnnotationLinkEditorExample.m' for the Objective-C version of this example.

class AnnotationLinkEditorExample: PSCExample {

    override init() {
        super.init()

        title = "Annotation Link Editor"
        contentDescription = "Shows how to create link annotations."
        category = .annotations
        priority = 71
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        let document = PSCAssetLoader.document(withName: .JKHF)
        let configuration = PSPDFConfiguration { builder in
            // Only allow adding link annotations here
            builder.editableAnnotationTypes = [.link]
        }
        let controller = PSPDFViewController(document: document, configuration: configuration)

        return controller
    }
}
