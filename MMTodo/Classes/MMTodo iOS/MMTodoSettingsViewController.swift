//
//  MMTodoSettingsViewController.swift
//  MMTodo-iOS
//
//  Created by Matthew Merritt on 2/13/18.
//

import UIKit

class MMTodoSettingsViewController: UIViewController {

    @IBOutlet weak var pingHostTextField: MMTextField!
    @IBOutlet weak var pingTimerTextField: MMTextField!
    @IBOutlet weak var pingPortTextField: MMTextField!
    @IBOutlet weak var mySQLHostTextField: MMTextField!
    @IBOutlet weak var mySQLUsernameTextField: MMTextField!
    @IBOutlet weak var mySQLPasswordTextField: MMTextField!
    @IBOutlet weak var mySQLDatabaseTextField: MMTextField!
    @IBOutlet weak var mySQLTableTextField: MMTextField!
    @IBOutlet weak var projectTextField: MMTextField!
    @IBOutlet weak var isShakable: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        pingHostTextField.format                  = .ipAddress
        pingHostTextField.keyboardType            = .decimalPad

        pingPortTextField.format                  = .decimal
        pingPortTextField.keyboardType            = .decimalPad

        pingTimerTextField.format                 = .decimal
        pingTimerTextField.keyboardType           = .decimalPad
        pingTimerTextField.decimalPoints          = 2

        mySQLHostTextField.format                 = .ipAddress
        mySQLHostTextField.keyboardType           = .decimalPad
        mySQLUsernameTextField.autocorrectionType = .no
        mySQLDatabaseTextField.autocorrectionType = .no
        mySQLTableTextField.autocorrectionType    = .no
        projectTextField.autocorrectionType       = .no
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        pingHostTextField.text      = MMTodoModel.shared.settings.pingHost
        pingPortTextField.text      = MMTodoModel.shared.settings.pingPort.description
        pingTimerTextField.text     = MMTodoModel.shared.settings.pingTimer.description

        mySQLHostTextField.text     = MMTodoModel.shared.settings.mySqlHost
        mySQLUsernameTextField.text = MMTodoModel.shared.settings.mySqlUsername
        mySQLPasswordTextField.text = MMTodoModel.shared.settings.mySqlPassword
        mySQLDatabaseTextField.text = MMTodoModel.shared.settings.mySqlDatabase
        mySQLTableTextField.text    = MMTodoModel.shared.settings.mySqlTable

        projectTextField.text       = MMTodoSettings.shared.project

        isShakable.isOn             = MMTodoSettings.shared.isShakable

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func doneButtonAction(sender: UIBarButtonItem) {

        view.endEditing(true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
            } else {
                self.dismiss(animated: true) { return }
            }
        }
    }
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}

// MARK: - Actions
extension MMTodoSettingsViewController {

    @IBAction func isShakableAction(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isShakable")
    }

    @IBAction func refreshButtonAction(_ sender: UIBarButtonItem) {
        Swift.print("Refresh DB Connection")

        if MMTodoModel.shared.isConnected {
            Swift.print("We are already connected, so stop connection and listening")
            MMTodoModel.shared.listen(on: false)
        }

        Swift.print("Start to listen now")
        MMTodoModel.shared.listen()
    }
}

// MARK: - UITextFieldDelegate
extension MMTodoSettingsViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {

        switch textField {
        case pingHostTextField:
            UserDefaults.standard.set(pingHostTextField.text, forKey: "pingHost")

        case pingPortTextField:
            UserDefaults.standard.set(Float(pingPortTextField.text ?? "80"), forKey: "pingPort")

        case pingTimerTextField:
            UserDefaults.standard.set(Float(pingTimerTextField.text ?? "15"), forKey: "pingTimer")

        case mySQLHostTextField:
            UserDefaults.standard.set(mySQLHostTextField.text, forKey: "MySQLHost")

        case mySQLUsernameTextField:
            UserDefaults.standard.set(mySQLUsernameTextField.text, forKey: "MySQLUsername")

        case mySQLPasswordTextField:
            UserDefaults.standard.set(mySQLPasswordTextField.text, forKey: "MySQLPassword")

        case mySQLDatabaseTextField:
            UserDefaults.standard.set(mySQLDatabaseTextField.text, forKey: "MySQLDatabase")

        case mySQLTableTextField:
            UserDefaults.standard.set(mySQLTableTextField.text, forKey: "MySQLTable")

        case projectTextField:
            UserDefaults.standard.set(projectTextField.text, forKey: "project")

        default:
            Swift.print("another textField")
        }

        MMTodoModel.shared.settings.save()
    }

}

