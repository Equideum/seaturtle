//
//  Copyright © 2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

class BlendModeMenuForMarkupAnnotationsExample: PSCExample {

    override init() {
        super.init()

        title = "Show Blend Mode menu item when selecting a highlight annotation"
        contentDescription = "Shows how to add the Blend Mode menu item in the highlight annotation selection menu."
        category = .annotations
        priority = 204
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let sourceURL = samplesURL.appendingPathComponent(PSCAssetName.quickStart.rawValue)
        let writeableURL = PSCCopyFileURLToDocumentFolderAndOverride(sourceURL, false)
        let document = PSPDFDocument(url: writeableURL)
        document.annotationSaveMode = .embedded

        // Add highlight annotation if there isn't one already.
        let pageIndex: PageIndex = 0
        let highlights = document.annotationsForPage(at: pageIndex, type: .highlight)
        if highlights.isEmpty {
            let textParser = document.textParserForPage(at: pageIndex)!
            for word in textParser.words where word.stringValue == "PSPDFKit" {
                guard let range = Range<Int>(word.range) else {
                    continue
                }
                let highlightAnnotation = PSPDFHighlightAnnotation.textOverlayAnnotation(with: [PSPDFGlyph](textParser.glyphs[range]))!
                highlightAnnotation.color = .yellow
                highlightAnnotation.pageIndex = pageIndex
                document.add([highlightAnnotation])
            }
        }

        let configuration = PSPDFConfiguration { builder in
            // Configure the properties for highlight annotations to show the blend mode menu item.
            var annotationProperties = builder.propertiesForAnnotations
            annotationProperties[.highlight] = [[AnnotationStyleKey.blendMode, AnnotationStyleKey.color, AnnotationStyleKey.alpha]]
            builder.propertiesForAnnotations = annotationProperties
        }

        let controller = BlendModeMenuForMarkupsViewController(document: document, configuration: configuration)
        return controller
    }
}

class BlendModeMenuForMarkupsViewController: PSPDFViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Select the highlight annotation to show the Inspector menu.
        let pageView = self.pageViewForPage(at: 0)
        guard let highlightAnnotation = self.document?.annotationsForPage(at: pageIndex, type: .highlight).first else { return }

        pageView?.select(highlightAnnotation, animated: true)
    }
}
