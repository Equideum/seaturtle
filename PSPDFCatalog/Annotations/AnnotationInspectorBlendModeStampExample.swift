//
//  Copyright © 2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

class AnnotationInspectorBlendModeStampExample: PSCExample {

    override init() {
        super.init()

        title = "Configure the annotation Inspector to set Blend Mode for stamp annotations"
        contentDescription = "Shows how to customize the annotation Inspector to set Blend Mode for vector stamp annotations."
        category = .annotations
        priority = 203
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let sourceURL = samplesURL.appendingPathComponent(PSCAssetName.quickStart.rawValue)
        let writeableURL = PSCCopyFileURLToDocumentFolderAndOverride(sourceURL, false)
        let document = PSPDFDocument(url: writeableURL)
        document.annotationSaveMode = .embedded

        // Add stamp annotation if there isn't one already.
        let pageIndex: PageIndex = 0
        let stamps = document.annotationsForPage(at: pageIndex, type: .stamp)
        if stamps.isEmpty {
            let logoURL = samplesURL.appendingPathComponent("PSPDFKit Logo.pdf")
            let stampAnnotation = PSPDFStampAnnotation()
            stampAnnotation.boundingBox = CGRect(x: 180.0, y: 150.0, width: 444.0, height: 500.0)
            stampAnnotation.appearanceStreamGenerator = PSPDFFileAppearanceStreamGenerator(fileURL: logoURL)
            stampAnnotation.pageIndex = pageIndex
            document.add([stampAnnotation])
        }

        let configuration = PSPDFConfiguration { builder in
            // Do not show color presets.
            var typesShowingColorPresets = builder.typesShowingColorPresets
            typesShowingColorPresets.remove(.stamp)
            builder.typesShowingColorPresets = typesShowingColorPresets

            // Configure the properties for stamp annotations to show the blend mode setting in the annotation Inspector.
            var properties = builder.propertiesForAnnotations
            properties[AnnotationString.stamp] = [[AnnotationStyleKey.blendMode]]
            builder.propertiesForAnnotations = properties
        }

        let controller = BlendModeInspectorForStampsViewController(document: document, configuration: configuration)
        return controller
    }
}

class BlendModeInspectorForStampsViewController: PSPDFViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Select the stamp annotation to show the Inspector menu.
        let pageView = self.pageViewForPage(at: 0)
        guard let stampAnnotation = self.document?.annotationsForPage(at: pageIndex, type: .stamp).first else { return }
        pageView?.select(stampAnnotation, animated: true)
    }
}
