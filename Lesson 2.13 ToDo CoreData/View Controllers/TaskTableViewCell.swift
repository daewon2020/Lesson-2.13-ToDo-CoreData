//
//  TaskTableViewCell.swift
//  Lesson 2.13 ToDo CoreData
//
//  Created by Kostya on 13.04.2022.
//

import UIKit


class TaskTableViewCell: UITableViewCell {
    
    var delegate: TaskTableViewCellDelegate?
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    lazy var subTitleLabel: UILabel = {
        let subTitleLabel = UILabel()
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.font = .systemFont(ofSize: 12)
        return subTitleLabel
    }()
    
    lazy var doneButtonCell: UIButton = {
        let doneButtonCell = UIButton()
        doneButtonCell.heightAnchor.constraint(equalToConstant: 50).isActive = true
        doneButtonCell.widthAnchor.constraint(equalToConstant: 50).isActive = true
        doneButtonCell.translatesAutoresizingMaskIntoConstraints = false
        doneButtonCell.addTarget(self, action: #selector(cellButtonPressed), for: .touchUpInside)
        return doneButtonCell
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        selectionStyle = .none
        contentView.addSubview(doneButtonCell)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            doneButtonCell.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            doneButtonCell.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleLabel.leadingAnchor.constraint(equalTo: doneButtonCell.trailingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            subTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7),
            subTitleLabel.leadingAnchor.constraint(equalTo: doneButtonCell.trailingAnchor, constant: 20),
            subTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])

    }
    
    @objc func cellButtonPressed() {
        delegate?.transferTask(cell: self)
    }
    
}




