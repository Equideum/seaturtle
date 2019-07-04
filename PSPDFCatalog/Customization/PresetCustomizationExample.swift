//
//  Copyright © 2016-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

class PresetCustomizationExample: PSCExample, PSPDFViewControllerDelegate {

    // MARK: PSCExample

    override init() {
        super.init()
        title = "Preset Customization Example"
        contentDescription = "Shows how to override default color presets."
        category = .viewCustomization
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        // Configure custom default presets.
        let presets = [
            PSPDFColorPreset(color: UIColor.black),
            PSPDFColorPreset(color: UIColor.red),
            PSPDFColorPreset(color: UIColor.orange),
            PSPDFColorPreset(color: UIColor.blue),
            PSPDFColorPreset(color: UIColor.purple)
        ]
        let styleManager = PSPDFKit.sharedInstance.styleManager
        let key = PSPDFAnnotationStateVariantIDMake(.line, nil)
        styleManager.setDefaultPresets(presets, forKey: key, type: .colorPreset)

        // NOTE: Users can change the stles in the inspector unless you change
        // PSPDFAnnotationStyleViewControllerDelegate.persistsColorPresetChanges.

        // Setup controller
        let document = PSCAssetLoader.document(withName: .quickStart)

        // Add a sample line
        let line = PSPDFLineAnnotation(point1: CGPoint(x: 50, y: 50), point2: CGPoint(x: 200, y: 200))
        document?.add([line!])

        let pdfController = PSPDFViewController(document: document)
        pdfController.delegate = self

        return pdfController
    }

    // MARK: PSPDFViewControllerDelegate

    func pdfViewController(_ pdfController: PSPDFViewController, didConfigurePageView pageView: PSPDFPageView, forPageAt pageIndex: Int) {
        // Preselect the line.
        if pageView.pageIndex == 0 {
            pageView.selectedAnnotations = pdfController.document?.annotationsForPage(at: 0, type: .line)
        }
    }

    func pdfViewControllerDidDismiss(_ pdfController: PSPDFViewController) {
        // Restore default presets to not affect other examples.
        let styleManager = PSPDFKit.sharedInstance.styleManager
        let key = PSPDFAnnotationStateVariantIDMake(.line, nil)
        styleManager.setDefaultPresets(nil, forKey: key, type: .colorPreset)
    }
}
