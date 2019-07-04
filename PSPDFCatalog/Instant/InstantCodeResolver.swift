//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import Foundation

class InstantCodeResolver {

    enum Failure: Error {
        case invalidCode
        case internalError
    }

    enum Result {
        case success(InstantDocumentInfo)
        case failure(Error)
    }

    typealias APICallbackCompletionHandler = (_ result: Result) -> Void

    var callbackQueue: DispatchQueue? = DispatchQueue.main

    func resolve(_ url: URL, completion: @escaping APICallbackCompletionHandler) {
        let session = URLSession.shared

        var request = URLRequest.init(url: url)
        request.addValue("application/vnd.instant-example+json", forHTTPHeaderField: "Accept")

        let task = session.dataTask(with: request) { data, response, error in
            let result = self.processResponse(data: data, response: response, error: error)
            self.callback(completion, with: result)
        }
        task.resume()
    }

    private func processResponse(data: Data?, response: URLResponse?, error: Error?) -> Result {
        if let error = error {
            return .failure(error)
        }

        let httpResponse = response as! HTTPURLResponse

        switch httpResponse.statusCode {
        case 200:
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data) {
                if let document = InstantDocumentInfo(json: json) {
                    return .success(document)
                }
            }
            return .failure(Failure.internalError)
        case 400:
            return .failure(Failure.invalidCode)
        default:
            return .failure(Failure.internalError)
        }
    }

    private func callback(_ completion: @escaping APICallbackCompletionHandler, with result: Result) {
        callbackQueue?.async { completion(result) } ?? completion(result)
    }

}

extension InstantCodeResolver.Failure: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .invalidCode:
            return NSLocalizedString("Invalid Document Code.", comment: "Instant Invalid Document Code Error Description")
        case .internalError:
            return NSLocalizedString("Internal Error.", comment: "Instant Internal Error Description")
        }
    }

}

extension InstantDocumentInfo {
    enum JSONKeys: String {
        case serverUrl, url, documentId, jwt
    }

    init?(json: Any) {
        guard let dictionary = json as? [String: Any] else {
            return nil
        }

        guard let serverUrlString = dictionary[JSONKeys.serverUrl.rawValue] as? String else {
            return nil
        }

        guard let serverURL = URL(string: serverUrlString) else {
            return nil
        }

        guard let urlString = dictionary[JSONKeys.url.rawValue] as? String else {
            return nil
        }

        guard let url = URL(string: urlString) else {
            return nil
        }

        guard let identifier = dictionary[JSONKeys.documentId.rawValue] as? String else {
            return nil
        }

        guard let jwt = dictionary[JSONKeys.jwt.rawValue] as? String else {
            return nil
        }

        self.init(serverURL: serverURL, url: url, identifier: identifier, jwt: jwt)
    }

}
