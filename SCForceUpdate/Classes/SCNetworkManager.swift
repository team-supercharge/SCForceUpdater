//
//  SCNetworkManager.swift
//  forceupdate-ios
//
//  Created by Bruno Muniz on 8/3/18.
//  Copyright © 2018 Bruno Muniz. All rights reserved.
//

import Foundation

final public class SCNetworkManager {
    private var baseUrl: String?
    private var versionAPIEndpoint: String?
    private var completionCallback: (([String: Any]) -> Void)?

    init(_ baseUrl: String, versionAPIEndpoint: String) {
        self.baseUrl = baseUrl
        self.versionAPIEndpoint = versionAPIEndpoint
    }
}

extension SCNetworkManager {
    public func fetchCurrentVersion(completion: @escaping ([String: Any]) -> Void) {
        completionCallback = completion
        let urlString = String(format: "%@/%@?%@", baseUrl!, versionAPIEndpoint!, params())
        let session = URLSession(configuration: .default)

        if let requestUrl = URL(string: urlString) {
            let task = createTask(session: session, requestUrl: requestUrl)
            task.resume()
        }
    }
}

extension SCNetworkManager {
    private func createTask(session: URLSession, requestUrl: URL) -> URLSessionDataTask {
        let task = session.dataTask(with: requestUrl) { (data, _, error) in
            if let error = error {
                print(error)
                return
            }

            guard let responseData = data else {
                print(Constants.Errors.dataLack)
                return
            }

            do {
                guard let json = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print(Constants.Errors.jsonParsing)
                        return
                }

                self.completionCallback!(json)
            } catch {
                print(Constants.Errors.jsonParsing)
                return
            }
        }

        return task
    }

    private func params() -> String {
        let params = ["platform": "ios",
                      "version": Bundle.main.versionNumber(),
                      "build_number": Bundle.main.buildNumber()]

        let parts = params.map { key, value -> String in
            if let queryKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                let queryValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                return String(format: "%@=%@", queryKey, queryValue)
            }

            return ""
        }

        return parts.joined(separator: "&")
    }
}
