//
//  Copyright © 2016-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

class DocumentWithOriginalURLExample: PSCExample {
    override init() {
        super.init()
        title = "Document with originalURL set"
        contentDescription = "Additional options for Open In"
        category = .documentDataProvider
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let document = PSCAssetLoader.document(withName: .quickStart)!
        // Define original file to get additional Open In options.
        document.originalFile = PSPDFFile(name: "My custom file.pdf", url: PSCAssetLoader.document(withName: .caseStudyBox)!.fileURL, data: nil)

        let controller = PSPDFViewController(document: document, configuration: PSPDFConfiguration {
            $0.pageMode = .single
        })

        return controller
    }
}
