//
//  InstantDocumentInfo.swift
//  PSPDFKit
//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import Instant

struct InstantDocumentInfo: Equatable {
    let serverURL: URL
    let url: URL
    /// No longer used except for backwards compatible URL generation since the identifier is now extracted from the JWT.
    let identifier: String
    let jwt: String

    public static func == (lhs: InstantDocumentInfo, rhs: InstantDocumentInfo) -> Bool {
        return lhs.serverURL == rhs.serverURL && lhs.identifier == rhs.identifier && lhs.jwt == rhs.jwt
    }
}
