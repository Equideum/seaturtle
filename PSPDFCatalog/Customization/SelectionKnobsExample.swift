//
//  Copyright © 2016-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

class SelectionKnobsExample: PSCExample, PSPDFViewControllerDelegate {

    // MARK: PSCExample

    override init() {
        super.init()
        title = "Custom Selection Knobs Example"
        contentDescription = "Shows how to remove, reposition and style the selection knobs."
        category = .viewCustomization
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let document = PSCAssetLoader.document(withName: .JKHF)

        // Add free text
        let freeText = PSPDFFreeTextAnnotation()
        freeText.fontSize = 30
        freeText.contents = "I am example text. Drag me!"
        freeText.boundingBox = CGRect(x: 50, y: 50, width: 300, height: 300)
        freeText.sizeToFit()
        freeText.color = UIColor.blue
        freeText.absolutePageIndex = 0
        document?.add([freeText])

        let configuration = PSPDFConfiguration { builder in
            builder.overrideClass(PSPDFResizableView.self, with: OnePointResizableView.self)
        }
        let pdfController = PSPDFViewController(document: document, configuration: configuration)
        pdfController.delegate = self

        let appearance = PSPDFResizableView.appearance()
        appearance.selectionBorderWidth = 3
        appearance.cornerRadius = 6

        return pdfController
    }

    // MARK: PSPDFViewControllerDelegate

    func pdfViewController(_ pdfController: PSPDFViewController, didConfigurePageView pageView: PSPDFPageView, forPageAt pageIndex: Int) {
        if pageView.pageIndex == 0 {
            pageView.selectedAnnotations = pdfController.document?.annotationsForPage(at: 0, type: .freeText)
        }
    }

    // MARK: - Resizable view customization

    class OnePointResizableView: PSPDFResizableView {

        // MARK: Lifecycle

        override init(frame: CGRect) {
            super.init(frame: frame)
            removeAndTintKnobs()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            removeAndTintKnobs()
        }

        // MARK: Knob customization

        func removeAndTintKnobs() {
            // Remove all knobs but the bottom right one.
            let range = PSPDFResizableViewOuterKnob.topLeft.rawValue...PSPDFResizableViewOuterKnob.bottomRight.rawValue
            for knobRawValue in range {
                if let knobType = PSPDFResizableViewOuterKnob(rawValue: knobRawValue) {
                    outerKnob(ofType: knobType)?.removeFromSuperview()
                }
            }
            // Use a custom tint color.
            tintColor = UIColor(red: 1, green: 0.622, blue: 0, alpha: 1)
        }

        override func centerPoint(for knobType: PSPDFResizableViewOuterKnob, inFrame frame: CGRect) -> CGPoint {
            var point = super.centerPoint(for: knobType, inFrame: frame)
            if knobType == .bottomRight {
                point.x += 10
                point.y += 10
            }
            return point
        }

        override func newKnobView(for type: PSPDFKnobType) -> UIView & PSPDFKnobView {
            return SquareKnobView(type: type)
        }
    }

    // MARK: - Custom knob view

    class SquareKnobView: UIView, PSPDFKnobView {

        // MARK: Lifecycle

        convenience init(type: PSPDFKnobType) {
            self.init()
            self.type = type
            frame = CGRect(origin: CGPoint.zero, size: knobSize)
            setUpShape()
        }

        // MARK: View

        override var bounds: CGRect {
            didSet {
                updatePaths()
            }
        }

        override func tintColorDidChange() {
            super.tintColorDidChange()
            updateColors()
        }

        // MARK: Layer

        override class var layerClass: AnyClass {
            return CAShapeLayer.self
        }

        var shapeLayer: CAShapeLayer {
            return layer as! CAShapeLayer
        }

        func setUpShape() {
            let layer = shapeLayer
            layer.strokeColor = UIColor.white.cgColor
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 1)
            layer.shadowOpacity = 0.4
            layer.shadowRadius = 1
            updateColors()
        }

        func updateColors() {
            let layer = shapeLayer
            layer.fillColor = tintColor.cgColor
            layer.strokeColor = UIColor(white: type == .outer ? 1 : 0.9, alpha: 1).cgColor
        }

        func updatePaths() {
            // The bounds change when zooming. Keep the dimensions proportional
            // to bounds to end up with the same apparent size.
            let width = min(bounds.width, bounds.height) / 6.0
            let layer = shapeLayer
            layer.path = UIBezierPath(roundedRect: bounds, cornerRadius: width).cgPath
            layer.shadowPath = layer.path
            layer.lineWidth = width
        }

        // MARK: PSPDFKnobView

        var type = PSPDFKnobType.outer {
            didSet {
                updateColors()
            }
        }

        let knobSize = CGSize(width: 12, height: 12)
    }
}
