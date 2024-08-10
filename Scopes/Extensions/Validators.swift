//
//  Validators.swift
//  Scopes
//
//  Created by Michael Eisemann on 8/10/24.
//

import Foundation

extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    var isASCII: Bool {
        return self.unicodeScalars.allSatisfy { $0.isASCII }
    }
}
