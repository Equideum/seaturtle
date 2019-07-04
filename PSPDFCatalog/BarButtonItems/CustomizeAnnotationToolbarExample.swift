//
//  Copyright © 2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

class CustomizeAnnotationToolbarExample: PSCExample {

    override init() {
        super.init()
        title = "Customized Annotation Toolbar"
        contentDescription = "Customizes the buttons in the annotation toolbar."
        category = .barButtons
        priority = 200
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        let document = PSCAssetLoader.document(withName: .annualReport)

        let configuration = PSPDFConfiguration { builder in
            builder.overrideClass(PSPDFAnnotationToolbar.self, with: CustomizedAnnotationToolbar.self)
        }

        let controller = PSPDFViewController(document: document, configuration: configuration)
        return controller
    }
}

class CustomizedAnnotationToolbar: PSPDFAnnotationToolbar {
    override init(annotationStateManager: PSPDFAnnotationStateManager) {
        super.init(annotationStateManager: annotationStateManager)

        let highlight = PSPDFAnnotationGroupItem(type: .highlight)
        let underline = PSPDFAnnotationGroupItem(type: .underline)
        let freeText = PSPDFAnnotationGroupItem(type: .freeText)
        let note = PSPDFAnnotationGroupItem(type: .note)

        let square = PSPDFAnnotationGroupItem(type: .square)
        let circle = PSPDFAnnotationGroupItem(type: .circle)
        let line = PSPDFAnnotationGroupItem(type: .line)

        let compactGroups = [
            PSPDFAnnotationGroup(items: [highlight, underline, freeText, note]),
            PSPDFAnnotationGroup(items: [square, circle, line])
        ]
        let compactConfiguration = PSPDFAnnotationToolbarConfiguration(annotationGroups: compactGroups)

        let regularGroups = [
            PSPDFAnnotationGroup(items: [highlight, underline]),
            PSPDFAnnotationGroup(items: [freeText]),
            PSPDFAnnotationGroup(items: [note]),
            PSPDFAnnotationGroup(items: [square, circle, line])
        ]
        let regularConfiguration = PSPDFAnnotationToolbarConfiguration(annotationGroups: regularGroups)

        configurations = [compactConfiguration, regularConfiguration]
    }
}
