//
//  LocalizableBundle.swift
//  PerfectSteak
//
//  Created by Dajun Xian on 2023/11/21.
//

import Foundation

func L(_ key: String) -> String {
    NSLocalizedString(key, comment: "")
}

func LF(_ key: String, _ arguments: CVarArg...) -> String {
    String(format: L(key), arguments: arguments)
}

class LocalizableBundle: Bundle, @unchecked Sendable {
    static var bundle: Bundle!

    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let bundle = LocalizableBundle.bundle else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }

    static func setLanguage(_ language: String) {
        var path = Bundle.main.path(forResource: language, ofType: "lproj")
        if path == nil, let hyphenRange = language.range(of: "-") {
            let languageCode = String(language[..<hyphenRange.lowerBound])
            path = Bundle.main.path(forResource: languageCode, ofType: "lproj")
        }
        bundle = path != nil ? Bundle(path: path!) : nil
    }
}
