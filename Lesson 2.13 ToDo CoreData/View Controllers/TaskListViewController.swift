//
//  ViewController.swift
//  Lesson 2.13 ToDo CoreData
//
//  Created by Kostya on 13.04.2022.
//

import UIKit
import CoreData

//----------
//MARK: - Protocols
//----------
protocol TaskTableViewCellDelegate {
    func transferTask(cell: TaskTableViewCell)
    func saveTaskChanges(taskName: String, deadline: Date)
}


class TaskListViewController: UITableViewController {

    private let cellID = UITableViewCell()
    private let headerID = UITableViewHeaderFooterView()
    private let backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
    private let context = StorageManager.shared.persistentContainer.viewContext
    private var taskList = [[Task]]()
    private var toggleForDoneSection = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        setupTableView()
        fetchData()
    }
}
//----------
//MARK: - TableView Delegate and DataSource
//----------

extension TaskListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         setupCustomCell(indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = taskList[indexPath.section][indexPath.row]
            context.delete(task)
            
            taskList[indexPath.section].remove(at: indexPath.row)
            StorageManager.shared.saveContext()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        30
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerID") as? TaskTableViewSectionHeader else { return UITableViewHeaderFooterView()}
        switch section {
        case 0: header.headerLabel.text = "В работе"
        case 1: header.headerLabel.text =  "Выполнено"
        default: header.headerLabel.text = ""
        }
        
        header.delegate = self
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TaskTableViewCell else { return }
        let task = taskList[indexPath.section][indexPath.row]
        let taskVC = TaskViewController()
        if let deadline = task.deadline {
            taskVC.deadline.date = deadline
        }
        taskVC.taskTextView.text = cell.titleLabel.text!
        taskVC.delegate = self
        navigationController?.pushViewController(taskVC, animated: true)
    }

}

//----------
//MARK: - Private functions
//----------

extension TaskListViewController {
    
    private func setupTableView() {
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: "cellID")
        tableView.register(TaskTableViewSectionHeader.self, forHeaderFooterViewReuseIdentifier: "headerID")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    private func setupNavigationController() {
        title = "Список задач"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.backgroundColor = backgroundColor
        
        let customAppearance = UINavigationBarAppearance()
        
        customAppearance.backgroundColor = backgroundColor
        customAppearance.titleTextAttributes = [.foregroundColor : UIColor.white]
        customAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = customAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = customAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTaskAlert)
        )
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    @objc private func addTaskAlert() {
        showAlert(title: "Add new task", message: "Please enter name for new task")
    }
            
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            guard let taskName = alertController.textFields?.first?.text, !taskName.isEmpty else { return }
            self.addTask(taskName)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.addTextField { textField in
            textField.placeholder = "New task"
        }
        present(alertController, animated: true)
    }
    
    private func addTask(_ taskName: String) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return }
        task.title = taskName
        task.deadline = nil
        taskList[0].insert(task, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0 )], with: .automatic)
        
        StorageManager.shared.saveContext()
    }
    
    private func fetchData() {
        
        let fetchRequest = Task.fetchRequest()
        do {
            let unsortedTaskList = try context.fetch(fetchRequest)
            makeSortedTaskList(unsortedTaskList: unsortedTaskList)
        } catch let error {
            print("Failed to fetch data", error)
        }
    }
    
    private func makeSortedTaskList(unsortedTaskList: [Task]){
        taskList.append(unsortedTaskList.filter { !$0.done })
        taskList.append(unsortedTaskList.filter { $0.done })
    }
    
    private func setupCustomCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as? TaskTableViewCell else { return UITableViewCell() }
        
        let task = taskList[indexPath.section][indexPath.row]
        let taskTitle = task.title
        let attributeTitle = NSAttributedString(
            string: taskTitle!,
            attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
        )
        
        cell.delegate = self
        
        if let deadline = task.deadline {
            if deadline < Date.now {
                cell.subTitleLabel.textColor = .red
            } else {
                cell.subTitleLabel.textColor = .black
            }
            
            cell.subTitleLabel.text = getDateString(from: deadline)
        } else {
            cell.subTitleLabel.text = "No deadline"
            cell.subTitleLabel.textColor = .black
        }
        
        if indexPath.section == 0 {
            cell.doneButtonCell.setImage(UIImage(named: "unchecked"), for: .normal)
            cell.titleLabel.attributedText = nil
            cell.titleLabel.text = taskTitle
            cell.titleLabel.textColor = .black
        } else {
                cell.doneButtonCell.setImage(UIImage(named: "checked"), for: .normal)
                cell.titleLabel.attributedText = attributeTitle
                cell.titleLabel.textColor = .gray
                cell.subTitleLabel.textColor = .gray
        }
        
        return cell
    }
    
    private func getDateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        return dateFormatter.string(from: date)
    }
}

//----------
//MARK: - TaskTableViewCellDelegate
//----------

extension TaskListViewController: TaskTableViewCellDelegate {
    func saveTaskChanges(taskName: String, deadline: Date) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let task = taskList[indexPath.section][indexPath.row]
        task.deadline = deadline
        task.title = taskName
        StorageManager.shared.saveContext()
        
        tableView.reloadData()
    }
    
    func transferTask(cell: TaskTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let moveToIndex = indexPath.section == 0 ? 1 : 0
        taskList[moveToIndex].insert(taskList[indexPath.section][indexPath.row], at: 0)
        if moveToIndex == 0 {
            taskList[moveToIndex][0].done = false
        } else {
            taskList[moveToIndex][0].done = true
        }
        tableView.insertRows(at: [IndexPath(item: 0, section: moveToIndex)], with: .automatic)

        taskList[indexPath.section].remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)

        StorageManager.shared.saveContext()
    }
}

