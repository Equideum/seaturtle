//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'PSCAddAnnotationsProgrammaticallyExamples.m' for the Objective-C version of this example.

import PSPDFKitSwift

class AddInkAnnotationProgrammaticallyExample: PSCExample {

    override init() {
        super.init()

        title = "Add Ink Annotation"
        category = .annotations
        priority = 10
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        let document = PSCAssetLoader.document(withName: .annualReport)!
        document.annotationSaveMode = .disabled

        // add ink annotation if there isn't one already.
        let targetPage: PageIndex = 0
        let annotation = PSPDFInkAnnotation()

        // example how to create a line rect.
        let lines = [
            [(CGPoint(x: 100, y: 100)), (CGPoint(x: 100, y: 200)), (CGPoint(x: 150, y: 300))],     // first line
            [(CGPoint(x: 200, y: 100)), (CGPoint(x: 200, y: 200)), (CGPoint(x: 250, y: 300))]
        ]

        // convert view line points into PDF line points.
        let pageInfo = document.pageInfoForPage(at: targetPage)!
        let viewRect = UIScreen.main.bounds // this is your drawing view rect - we don't have one yet, so lets just assume the whole screen for this example. You can also directly write the points in PDF coordinate space, then you don't need to convert, but usually your user draws and you need to convert the points afterwards.
        annotation.lineWidth = 5
        annotation.linesTyped = ConvertToPDFLines(viewLines: lines, pageInfo: pageInfo, viewBounds: viewRect)

        annotation.color = UIColor(red: 0.667, green: 0.279, blue: 0.748, alpha: 1)
        annotation.pageIndex = targetPage
        document.add([annotation])

        let controller = PSPDFViewController(document: document)
        return controller
    }
}

class AddHighlightAnnotationProgrammaticallyExample: PSCExample {

    override init() {
        super.init()

        title = "Add Highlight Annotations"
        category = .annotations
        priority = 20
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        let document = PSCAssetLoader.document(withName: .annualReport)
        document?.annotationSaveMode = .disabled

        // Let's create a highlight for all occurences of "bow" on the first 10 pages in orange.
        var annotationCounter = 0
        for pageIndex: PageIndex in 0...9 {
            guard let textParser = document?.textParserForPage(at: pageIndex) else { continue }
            for word in textParser.words where word.stringValue == "bow" {
                guard let range = Range<Int>(word.range) else {
                    continue
                }
                let annotation = PSPDFHighlightAnnotation.textOverlayAnnotation(with: [PSPDFGlyph](textParser.glyphs[range]))!
                annotation.color = .orange
                annotation.contents = "This is an automatically created highlight #\(annotationCounter)"
                annotation.pageIndex = pageIndex

                document?.add([annotation])
                annotationCounter += 1
            }
        }

        // Highlight an entire text selection on the second page, in yellow.
        let pageIndex: PageIndex = 1
        // Text selection rect in PDF coordinates for the first paragraph of the second page.
        let textSelectionRect = CGRect(x: 36, y: 547, width: 238, height: 135)
        let glyphs = document?.objects(atPDFRect: textSelectionRect, pageIndex: pageIndex, options: [PSPDFObjectsGlyphsKey: true])[PSPDFObjectsGlyphsKey] as! [PSPDFGlyph]
        let annotation = PSPDFHighlightAnnotation.textOverlayAnnotation(with: glyphs)!
        annotation.color = UIColor.yellow
        annotation.contents = "This is an automatically created highlight #\(annotationCounter)"
        annotation.pageIndex = pageIndex
        document?.add([annotation])

        let controller = PSPDFViewController(document: document)
        controller.pageIndex = pageIndex
        return controller
    }
}

class AnnotationsProgramaticallyCreateAnnotationsExample: PSCExample {

    override init() {
        super.init()

        title = "Add Note Annotation"
        category = .annotations
        priority = 30
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let hackerMagURL = samplesURL.appendingPathComponent(PSCAssetName.annualReport.rawValue)
        let data = try? Data(contentsOf: hackerMagURL, options: .mappedIfSafe)

        // we use a NSData document here but it'll work even better with a file-based variant.
        let document = PDFDocument(dataProviders: [PSPDFDataContainerProvider(data: data!)])
        document.annotationSaveMode = .disabled
        document.title = "Programmatically create annotations"

        var annotations = [PSPDFAnnotation]()
        let maxHeight = document.pageInfoForPage(at: 0)!.size.height
        for i in 0...4 {
            let noteAnnotation = PSPDFNoteAnnotation()
            // width/height will be ignored for note annotations.
            noteAnnotation.boundingBox = CGRect(x: 100, y: (50 + CGFloat(i) * CGFloat(maxHeight / 5)), width: 32, height: 32)
            noteAnnotation.contents = "Note #\(5 - i)"
            annotations.append(noteAnnotation)
        }
        document.add(annotations)

        let pdfController = PSPDFViewController(document: document)
        return pdfController
    }
}

class AddPolyLineAnnotationProgrammaticallyExample: PSCExample {

    override init() {
        super.init()

        title = "Add PolyLine Annotation"
        category = .annotations
        priority =  40
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        let document = PSCAssetLoader.document(withName: .annualReport)
        document?.annotationSaveMode = .disabled

        // Add shape annotation if there isn't one already.
        let pageIndex: PageIndex = 0
        let polyLines = document?.annotationsForPage(at: pageIndex, type: .polyLine)
        if let polyLines = polyLines, polyLines.isEmpty {
            let polyLine = PSPDFPolyLineAnnotation()
            polyLine.pointsTyped = [CGPoint(x: 152, y: 333), CGPoint(x: 167, y: 372), CGPoint(x: 231, y: 385), CGPoint(x: 278, y: 354), CGPoint(x: 215, y: 322)]
            polyLine.color = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
            polyLine.fillColor = .yellow
            polyLine.lineEnd2 = .closedArrow
            polyLine.lineWidth = 5
            polyLine.pageIndex = pageIndex
            document?.add([polyLine])
        }

        let controller = PSPDFViewController(document: document)
        controller.navigationItem.setRightBarButtonItems([controller.thumbnailsButtonItem, controller.outlineButtonItem, controller.openInButtonItem, controller.searchButtonItem], for: .document, animated: false)
        return controller
    }
}

class AddShapeAnnotationProgrammaticallyExample: PSCExample {

    override init() {
        super.init()

        title = "Add Shape Annotation"
        category = .annotations
        priority = 50
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        let document = PSCAssetLoader.document(withName: .annualReport)
        document?.annotationSaveMode = .disabled

        // add shape annotation if there isn't one already.
        let pageIndex: PageIndex = 0
        let squares = document?.annotationsForPage(at: pageIndex, type: .square)
        if let squares = squares, squares.isEmpty {
            let annotation = PSPDFSquareAnnotation()
            annotation.boundingBox = CGRect(origin: .zero, size: document!.pageInfoForPage(at: pageIndex)!.size).insetBy(dx: 100, dy: 100)
            annotation.color = UIColor(red: 0, green: 100 / 255, blue: 0, alpha: 1)
            annotation.fillColor = annotation.color
            annotation.alpha = 0.5
            annotation.pageIndex = pageIndex

            document?.add([annotation])
        }

        let controller = PSPDFViewController(document: document, configuration: PSPDFConfiguration { builder in
            builder.isTextSelectionEnabled = false
        })
        controller.navigationItem.setRightBarButtonItems([controller.thumbnailsButtonItem, controller.openInButtonItem, controller.searchButtonItem], for: .document, animated: false)
        return controller
    }
}

class AddVectorStampAnnotationProgramaticallyExample: PSCExample {

    override init() {
        super.init()

        title = "Add Vector Stamp Annotation"
        category = .annotations
        priority = 60
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let sourceURL = samplesURL.appendingPathComponent(PSCAssetName.quickStart.rawValue)
        let writableURL = PSCCopyFileURLToDocumentFolderAndOverride(sourceURL, false)
        let document = PSPDFDocument(url: writableURL)
        document.annotationSaveMode = .embedded

        let logoURL = samplesURL.appendingPathComponent("PSPDFKit Logo.pdf")

        // Add stamp annotation if there isn't one already.
        let pageIndex: PageIndex = 0
        let stamps = document.annotationsForPage(at: pageIndex, type: .stamp)
        if stamps.isEmpty {
            // Add a transparent stamp annotation using the appearance stream generator.
            let stampAnnotation = PSPDFStampAnnotation()
            stampAnnotation.boundingBox = CGRect(x: 180.0, y: 150.0, width: 444.0, height: 500.0)
            stampAnnotation.appearanceStreamGenerator = PSPDFFileAppearanceStreamGenerator(fileURL: logoURL)
            stampAnnotation.pageIndex = pageIndex
            document.add([stampAnnotation])
        }
        let pdfController = PSPDFViewController(document: document)
        return pdfController
    }
}

class AddFileAnnotationProgrammaticallyExample: PSCExample {

    override init() {
        super.init()

        title = "Add File Annotation With Embedded File"
        category = .annotations
        priority = 70
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let sourceURL = samplesURL.appendingPathComponent(PSCAssetName.quickStart.rawValue)
        let writableURL = PSCCopyFileURLToDocumentFolderAndOverride(sourceURL, false)
        let document = PSPDFDocument(url: writableURL)
        document.annotationSaveMode = .embedded
        let embeddedFileURL = samplesURL.appendingPathComponent("PSPDFKit Logo.pdf")

        // Add file annotation if there isn't one already.
        let pageIndex: PageIndex = 0
        let fileAnnotations = document.annotationsForPage(at: pageIndex, type: .file)
        if fileAnnotations.isEmpty {
            // Create a file annotation.
            let fileAnnotation = PSPDFFileAnnotation()
            fileAnnotation.pageIndex = pageIndex
            fileAnnotation.iconName = .graph
            fileAnnotation.color = .blue
            fileAnnotation.boundingBox = CGRect(x: 500, y: 250, width: 32, height: 32)

            // Create an embedded file and add it to the file annotation.
            let embeddedFile = PSPDFEmbeddedFile(fileURL: embeddedFileURL, fileDescription: "PSPDFKit")
            fileAnnotation.embeddedFile = embeddedFile
            document.add([fileAnnotation])
        }
        let pdfController = PSPDFViewController(document: document)
        return pdfController
    }
}
