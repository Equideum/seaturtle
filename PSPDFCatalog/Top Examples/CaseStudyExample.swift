//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'PSCCaseStudyExample.m' for the Objective-C version of this example.

class CaseStudyExample: PSCExample {

    override init() {
        super.init()

        title = "Case Study from Box"
        contentDescription = "Includes a RichMedia inline video."
        category = .top
        priority = 4
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let document = PSCAssetLoader.document(withName: .caseStudyBox)

        let configuration = PSPDFConfiguration { builder in
            builder.shouldShowUserInterfaceOnViewWillAppear = false
            builder.isPageLabelEnabled = false
        }
        let controller = PSPDFViewController(document: document, configuration: configuration)
        controller.navigationItem.rightBarButtonItems = [controller.activityButtonItem, controller.searchButtonItem, controller.annotationButtonItem]
        return controller
    }
}
