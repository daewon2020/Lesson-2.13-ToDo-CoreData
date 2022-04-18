//
//  TaskTableViewSectionHeader.swift
//  Lesson 2.13 ToDo CoreData
//
//  Created by Kostya on 16.04.2022.
//

import UIKit

class TaskTableViewSectionHeader: UITableViewHeaderFooterView {
    
    var delegate: TaskTableViewCellDelegate?
    
    lazy var headerLabel: UILabel = {
        let label =  UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: "headerID")
        
        contentView.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        contentView.addSubview(headerLabel)

        setConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstrains() {
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            headerLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
