//
//  MMTextField.swift
//  MMTodo-iOS
//
//  Created by Matthew Merritt on 2/13/18.
//

import UIKit

class MMTextField: UITextField, UITextFieldDelegate {
    enum TextFieldFormatting {
        case ipAddress
        case decimal
        case noFormatting
    }

    var format: TextFieldFormatting = .noFormatting
    var decimalPoints: Int = 0
    var maxLenth = 10

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        registerForNotifications()

    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        registerForNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    fileprivate func registerForNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.textDidChange),
                                               name: NSNotification.Name(rawValue: "UITextFieldTextDidChangeNotification"),
                                               object: self)
    }

    @objc public func textDidChange() {
        var string: String { return super.text ?? "" }

        // Allow any backspaces
        if string.isEmpty { return }

        switch format {
        case .ipAddress:
            checkForIPAddress()
        case .decimal:
            if !isNumberOrDecimal() || string.count > maxLenth || !checkDecimal() {
                super.text?.removeLast()
            }
        default:
            return
        }
    }

    func checkForIPAddress() {
        var string: String { return super.text ?? "" }

        // Ensure only digitis
        guard isNumberOrDecimal() else { super.text?.removeLast(); return }

        // Get the textField.text and add new string, then split it by '.'
        let pieces = string.components(separatedBy: CharacterSet.init(charactersIn: "."))

        // Make sure we don't have more than 4 fields
        guard pieces.count < 5 else { super.text?.removeLast(); return }

        if String(string.suffix(2)) == ".." { super.text?.removeLast(); return }
        if string.last == "." { return }

        // Interate through the fields
        for element in pieces {
            // Make sure each field is upto 3 digits
            guard element.count < 4 else { super.text?.removeLast(); return }

            // Search for valid IP field
            let newreg = "(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))"
            let predicate = NSPredicate(format: "SELF MATCHES %@", newreg)

            guard predicate.evaluate(with: element) else { super.text?.removeLast(); return }
        }
    }

    func checkDecimal() -> Bool {
        var string: String { return super.text ?? "" }
        let pieces = string.components(separatedBy: CharacterSet.init(charactersIn: "."))

        guard pieces.count > 1 else { return true }

        return pieces.last!.count <= decimalPoints
    }

    func isNumberOrDecimal() -> Bool {
        var string: String { return super.text ?? "" }

        var allowedCharacters = CharacterSet.decimalDigits

        if decimalPoints > 0 {
            allowedCharacters = allowedCharacters.union(CharacterSet.init(charactersIn: "."))
        }

        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }

}
