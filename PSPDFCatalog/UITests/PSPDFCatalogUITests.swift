//
//  Copyright © 2016-2019 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import XCTest

class PSPDFCatalogUITests: XCTestCase {

    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        let app = XCUIApplication()

        app.launch()

        // go back to main examples list (state preservation might take us to the last example on launch)
        app.tapBack(fail: false)
    }

    func testExample() {
        let app = XCUIApplication()

        app.tables.staticTexts["PSPDFViewController Playground"].firstMatch.tap()
        app.tapBack()

        app.tables.staticTexts["Kiosk Grid"].firstMatch.tap()
        app.tapBack()

        app.tables.staticTexts["Settings"].firstMatch.tap()
        app.tapBack()
    }
}

extension XCUIApplication {

    func tapBack(fail: Bool = true) {
        let back = self.buttons.matching(identifier: "Catalog").firstMatch

        if back.exists && back.isHittable {
            back.tap()
        } else if fail {
            XCTFail("cannot find back button")
        }
    }
}
