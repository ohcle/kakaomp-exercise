//
//  URL+.swift
//  exercise
//
//  Created by Do Yi Lee on 2022/08/30.
//

import Foundation

extension URL {
    init?(_ string: String) {
        guard string.isEmpty == false else {
            return nil
        }
        if let url = URL(string: string) {
            self = url
        } else if let urlEscapedString = string.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
                  let escapedURL = URL(string: urlEscapedString) {
            self = escapedURL
        } else {
            return nil
        }
    }
}
