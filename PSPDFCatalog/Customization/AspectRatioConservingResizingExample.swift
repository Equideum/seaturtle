//
//  Copyright © 2016-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation
import PSPDFKitSwift

class AspectRatioConservingResizingExample: PSCExample {

    // MARK: PSCExample

    override init() {
        super.init()
        title = "Aspect Ratio Conserving Example"
        contentDescription = "Shows how to implement resizing that always preserves the annotation aspect ratio."
        category = .viewCustomization
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let document = PSCAssetLoader.document(withName: .annualReport)

        // Add free text
        let freeText = PSPDFFreeTextAnnotation()
        freeText.fontSize = 30
        freeText.contents = "Example text. Drag me!"
        freeText.boundingBox = CGRect(x: 50, y: 50, width: 300, height: 300)
        freeText.sizeToFit()
        freeText.color = UIColor.blue
        freeText.absolutePageIndex = 0
        document?.add([freeText])

        let configuration = PSPDFConfiguration { builder in
            builder.overrideClass(PSPDFResizableView.self, with: AspectResizableView.self)
        }
        let pdfController = PSPDFViewController(document: document, configuration: configuration)
        pdfController.delegate = self

        return pdfController
    }

    // MARK: Resizable view customization

    private class AspectResizableView: PSPDFResizableView {

        // MARK: Lifecycle

        override init(frame: CGRect) {
            super.init(frame: frame)
            customize()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            customize()
        }

        // MARK: Knob customization

        private func customize() {
            // Always snap to guide.
            guideSnapAllowance = PSPDFGuideSnapAllowanceAlways
            // Remove all knobs but the bottom right one.
            let range = PSPDFResizableViewOuterKnob.topLeft.rawValue...PSPDFResizableViewOuterKnob.bottomRight.rawValue
            let knobTypes = range.compactMap { PSPDFResizableViewOuterKnob(rawValue: $0) }
            for knobType in knobTypes {
                outerKnob(ofType: knobType)?.removeFromSuperview()
            }
        }
    }
}

// MARK: PSPDFViewControllerDelegate

extension AspectRatioConservingResizingExample: PSPDFViewControllerDelegate {

    func pdfViewController(_ pdfController: PSPDFViewController, didConfigurePageView pageView: PSPDFPageView, forPageAt pageIndex: Int) {
        if pageView.pageIndex == 0 {
            pageView.selectedAnnotations = pdfController.document?.annotationsForPage(at: 0, type: .freeText)
        }
    }
}
