//
//  TaskViewController.swift
//  Lesson 2.13 ToDo CoreData
//
//  Created by Kostya on 16.04.2022.
//

import UIKit

class TaskViewController: UIViewController {
    
    var delegate: TaskTableViewCellDelegate?
    
    lazy var taskTextView: UITextView = {
        let taskTextView = UITextView()
        taskTextView.translatesAutoresizingMaskIntoConstraints = false
        taskTextView.sizeToFit()
        taskTextView.isScrollEnabled = false
        taskTextView.layer.borderWidth = 1
        taskTextView.layer.borderColor = UIColor.black.cgColor
        taskTextView.layer.cornerRadius = 10
        taskTextView.font = .boldSystemFont(ofSize: 24)
        taskTextView.textColor = .black
        taskTextView.backgroundColor = .white
        
        return taskTextView
    }()
    
    lazy var deadline: UIDatePicker = {
        let deadline = UIDatePicker()
        deadline.translatesAutoresizingMaskIntoConstraints = false
        deadline.preferredDatePickerStyle = .inline
        deadline.datePickerMode = .date
        deadline.date = Date.now
        return deadline
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(taskTextView)
        view.addSubview(deadline)
        
        title = "Редактирование задачи"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        
        setConstraints()
        
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            taskTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            taskTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            taskTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            deadline.topAnchor.constraint(equalTo: taskTextView.bottomAnchor, constant: 20),
            deadline.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            deadline.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    @objc private func doneButtonTapped(){
        delegate?.saveTaskChanges(taskName: taskTextView.text, deadline: deadline.date)
        navigationController?.popViewController(animated: true)
    }
}
