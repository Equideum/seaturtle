//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

class LinkCustomizationExample: PSCExample {

    override init() {
        super.init()

        title = "Link annotation view customization"
        contentDescription = "Shows how to enforce a fixed style for link annotations."
        type = "com.pspdfkit.catalog.playground.swift"
        category = .viewCustomization
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let document = PSCAssetLoader.document(withName: PSCAssetName.quickStart)

        let configuration = PSPDFConfiguration { builder in
            builder.overrideClass(PSPDFLinkAnnotationView.self, with: AlwaysVisibleLinkAnnotationView.self)
        }

        let controller = PSCKioskPDFViewController(document: document, configuration: configuration)
        return controller
    }

    /// Always shows a 1pt red border around link annotations.
    class AlwaysVisibleLinkAnnotationView: PSPDFLinkAnnotationView {

        let fixedBorderColor = UIColor.red
        let fixedStrokeWidth: CGFloat = 1

        // Override setters to enforce the hardcoded style and ignore
        // any values that would have otherwise ben obtained from the
        // link annotation.

        override var borderColor: UIColor? {
            set { super.borderColor = fixedBorderColor }
            get { return super.borderColor }
        }

        override var strokeWidth: CGFloat {
            set { super.strokeWidth = fixedStrokeWidth }
            get { return super.strokeWidth }
        }
    }
}
