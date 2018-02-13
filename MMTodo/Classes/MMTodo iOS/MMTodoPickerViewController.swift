//
//  PriorityPickerViewController.swift
//  ShiftToday
//
//  Created by Matthew Merritt on 12/28/16.
//  Copyright © 2017 MerrittWare. All rights reserved.
//

import UIKit

enum MMTodoPickerType: String {
    case priority   = "Priority"
    case status     = "Statute"
    case createDate = "CreateDate"
    case dueDate    = "DueDate"
    case count

    init(hashValue: Int) {
        switch hashValue {
        case 0:
            self = .priority
        case 1:
            self = .status
        case 2:
            self = .createDate
        case 3:
            self = .dueDate
        default:
            self = .priority
        }
    }

    init(rawValue: String) {
        switch rawValue {
        case "Priority":
            self = .priority
        case "Status":
            self = .status
        case "CreateDate":
            self = .createDate
        case "DueDate":
            self = .dueDate
        default:
            self = .priority
        }
    }
}

protocol MMTodoPickerViewControllerDelegate {
    func didSelect(selection: Any, ofType pickerType: MMTodoPickerType, indexPath: IndexPath?)
    func didCancel(indexPath: IndexPath?)
}

class MMTodoPickerViewController: UIViewController {

    @IBOutlet weak var datePickerView: UIDatePicker!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var delegate: MMTodoPickerViewControllerDelegate!
    var pickerType: MMTodoPickerType!
    var pickerValue: Any!
    var indexPath: IndexPath? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        datePickerView.datePickerMode = .date
        datePickerView.isHidden = true
        pickerView.isHidden     = true

        if let pickerType = pickerType {
            switch pickerType {
            case .createDate, .dueDate:
                datePickerView.isHidden = false
                if let value = pickerValue as? Date {
                    datePickerView.setDate(value, animated: true)
                }
            case .priority:
                pickerView.isHidden = false
                if let value = pickerValue as? MMTodo.Priority {
                    pickerView.selectRow(value.hashValue, inComponent: 0, animated: true)
                }
            case .status:
                pickerView.isHidden = false
                if let value = pickerValue as? MMTodo.Status {
                    pickerView.selectRow(value.hashValue, inComponent: 0, animated: true)
                }
            default:
                Swift.print("Never!")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension MMTodoPickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let type = pickerType {
            switch type {
            case .priority:
                return MMTodo.Priority.count.hashValue
            case .status:
                return MMTodo.Status.count.hashValue
            default:
                return 0
            }
        }

        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let type = pickerType {
            switch type {
            case .priority:
                return MMTodo.Priority(hashValue: row).rawValue
            case .status:
                return MMTodo.Status(hashValue: row).rawValue
            default:
                return ""
            }
        }

        return ""
    }

//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if delegate != nil, let type = pickerType {
//            switch type {
//            case .priority:
//                delegate.didSelect(selection: Priority(hashValue: row), ofType: PickerType.priority, indexPath: indexPath)
//            case .status:
//                delegate.didSelect(selection: Status(hashValue: row), ofType: PickerType.status, indexPath: indexPath)
//            default:
//                Swift.print("Never")
//            }
//        }
//    }
}

extension MMTodoPickerViewController {

    @IBAction func datePickerAction(_ sender: UIDatePicker) {
//        Swift.print("sender: \(sender)")
//
//        guard indexPath == nil else {
//            return
//        }
//        
//        if delegate != nil, let type = pickerType {
//            switch type {
//            case .createDate:
//                delegate.didSelect(selection: sender.date, ofType: type, indexPath: indexPath)
//            case .dueDate:
//                delegate.didSelect(selection: sender.date, ofType: type, indexPath: indexPath)
//            default:
//                Swift.print("Never!")
//            }
//        }
    }

    @IBAction func cancelButtonAction(_ sender: UIBarButtonItem) {
//        if delegate != nil, let type = pickerType {
//            switch type {
//            case .createDate:
//                delegate.didCancel()
//            case .dueDate:
//                delegate.didCancel()
//            default:
//                Swift.print("Never!")
//            }
//        }

        if delegate != nil {
            delegate.didCancel(indexPath: indexPath)
        }

        dismiss(animated: true, completion: nil)
    }

    @IBAction func doneButtonAction(_ sender: UIBarButtonItem) {
        if delegate != nil, let type = pickerType {
            switch type {
            case .createDate:
                delegate.didSelect(selection: datePickerView.date, ofType: type, indexPath: indexPath)
            case .dueDate:
                delegate.didSelect(selection: datePickerView.date, ofType: type, indexPath: indexPath)
            case .priority:
                delegate.didSelect(selection: MMTodo.Priority(hashValue: pickerView.selectedRow(inComponent: 0)), ofType: MMTodoPickerType.priority, indexPath: indexPath)
            case .status:
                delegate.didSelect(selection: MMTodo.Status(hashValue: pickerView.selectedRow(inComponent: 0)), ofType: MMTodoPickerType.status, indexPath: indexPath)
            default:
                Swift.print("Never!")
            }
        }

        dismiss(animated: true, completion: nil)
    }

}
