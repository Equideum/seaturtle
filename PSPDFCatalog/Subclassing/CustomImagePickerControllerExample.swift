//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

class CustomImagePickerController: PSPDFImagePickerController {
    // Make sure you configured Image Permissions in your app. See https://pspdfkit.com/guides/ios/current/getting-started/permissions/#toc_image-permissions for more details.
    override class func availableImagePickerSourceTypes() -> [NSNumber] {
        return [NSNumber(value: UIImagePickerController.SourceType.camera.rawValue)]
    }
}

class CustomImagePickerControllerExample: PSCExample {
    override init() {
        super.init()

        title = "Custom Image Picker"
        contentDescription = "Custom Image Picker with source type UIImagePickerControllerSourceType.camera"
        category = .subclassing
        priority = 300
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let sourceURL = samplesURL.appendingPathComponent(PSCAssetName.JKHF.rawValue)
        let writeableURL = PSCCopyFileURLToDocumentFolderAndOverride(sourceURL, false)
        let document = PSPDFDocument(url: writeableURL)

        let configuration = PSPDFConfiguration { builder in
            builder.overrideClass(PSPDFImagePickerController.self, with: CustomImagePickerController.self)
        }
        let controller = PSPDFViewController(document: document, configuration: configuration)
        return controller
    }
}
