//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import PSPDFKitUI

class CustomPencilInteractionExample: PSCExample {
    override init() {
        super.init()

        title = "Custom Pencil Interaction Action"
        contentDescription = "Performs a custom action in response to UIPencilInteraction."
        category = .annotations
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let document = PSCAssetLoader.document(withName: .quickStart)
        return CustomPencilInteractionViewController(document: document)
    }

    class CustomPencilInteractionViewController: PSPDFViewController, UIPencilInteractionDelegate {
        override func viewDidLoad() {
            super.viewDidLoad()

            if #available(iOS 12.1, *) {
                // Disable PSPDFKit’s default Pencil interaction handling by removing the interaction.
                // Setting the `isEnabled` property will not work because PSPDFKit may set this property internally.
                if let builtInPencilInteraction = annotationStateManager.pencilInteraction {
                    builtInPencilInteraction.view?.removeInteraction(builtInPencilInteraction)
                }

                // Add the custom interaction.
                let customPencilInteraction = UIPencilInteraction()
                customPencilInteraction.delegate = self
                view.addInteraction(customPencilInteraction)
            }
        }

        @available(iOS 12.1, *)
        func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
            let alert = UIAlertController(title: "Apple Pencil Tap!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}
