//
//  Copyright © 2016-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

extension PSPDFColorPalette {
    class func mainCustomPalette() -> PSPDFColorPalette {
        return PSPDFColorPalette(title: "Custom Colors", colorPatches: [
            PSPDFColorPatch(color: .white),
            PSPDFColorPatch(color: .gray),
            PSPDFColorPatch(color: .black),
            PSPDFColorPatch(color: .red),
            PSPDFColorPatch(color: .green),
            PSPDFColorPatch(color: .blue)
        ])
    }

    class func granularCustomPalette() -> PSPDFColorPalette {
        return PSPDFColorPalette(title: "Custom Colors", colorPatches: [
            PSPDFColorPatch(color: .white),
            PSPDFColorPatch(colors: [
                .lightGray,
                .gray,
                .darkGray
            ]),
            PSPDFColorPatch(color: UIColor.black),
            PSPDFColorPatch(colors: [
                UIColor.red,
                UIColor(hue: 0.0, saturation: 1.0, brightness: 0.8, alpha: 1.0),
                UIColor(hue: 0.0, saturation: 1.0, brightness: 0.6, alpha: 1.0),
                UIColor(hue: 0.0, saturation: 1.0, brightness: 0.4, alpha: 1.0),
                UIColor(hue: 0.0, saturation: 1.0, brightness: 0.2, alpha: 1.0)
            ]),
            PSPDFColorPatch(colors: [
                UIColor.green,
                UIColor(hue: 0.33333, saturation: 1.0, brightness: 0.7, alpha: 1.0),
                UIColor(hue: 0.33333, saturation: 1.0, brightness: 0.4, alpha: 1.0),
                UIColor(hue: 0.33333, saturation: 1.0, brightness: 0.1, alpha: 1.0)
            ]),
            PSPDFColorPatch(colors: [
                UIColor.blue,
                UIColor(hue: 0.66666, saturation: 1.0, brightness: 0.6, alpha: 1.0),
                UIColor(hue: 0.66666, saturation: 1.0, brightness: 0.2, alpha: 1.0)
            ])
        ])
    }
}

class CustomColorPickerFactory: PSPDFColorPickerFactory {
    override class func colorPalettes(in colorSet: PSPDFColorSet) -> [PSPDFColorPalette] {
        switch colorSet {
        case .default:
            return [PSPDFColorPalette.mainCustomPalette(), PSPDFColorPalette.granularCustomPalette(), PSPDFColorPalette.hsv()]
        default:
            return super.colorPalettes(in: colorSet)
        }
    }
}

// MARK: - PSCExample

class CustomColorPickersExample: PSCExample {

    override init() {
        super.init()

        title = "Color Pickers"
        contentDescription = "Customizes color pickers."
        category = .controllerCustomization
        priority = 20
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let document = PSCAssetLoader.document(withName: .quickStart)

        let configuration = PSPDFConfiguration { builder in
            builder.overrideClass(PSPDFColorPickerFactory.self, with: CustomColorPickerFactory.self)
        }
        let controller = PSPDFViewController(document: document, configuration: configuration)

        return controller
    }
}
