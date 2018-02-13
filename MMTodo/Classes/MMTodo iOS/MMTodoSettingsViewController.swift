//
//  MMTodoSettingsViewController.swift
//  MMTodo-iOS
//
//  Created by Matthew Merritt on 2/13/18.
//

import UIKit

class MMTodoSettingsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var pingHostTextField: MMTextField!
    @IBOutlet weak var pingTimerTextField: MMTextField!
    @IBOutlet weak var mySQLHostTextField: MMTextField!
    @IBOutlet weak var mySQLUsernameTextField: MMTextField!
    @IBOutlet weak var mySQLPasswordTextField: MMTextField!
    @IBOutlet weak var mySQLTableTextField: MMTextField!
    @IBOutlet weak var projectTextField: MMTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        pingHostTextField.format  = .ipAddress
        pingTimerTextField.format = .decimal
        mySQLHostTextField.format = .ipAddress
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func doneButtonAction(sender: UIBarButtonItem) {
        self.dismiss(animated: true) { return }
        self.navigationController?.popViewController(animated: true)
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

