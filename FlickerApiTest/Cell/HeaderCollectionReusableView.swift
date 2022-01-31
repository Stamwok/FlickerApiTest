//
//  HeaderCollectionReusableView.swift
//  FlickerApiTest
//
//  Created by  Егор Шуляк on 30.01.22.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
    
    static let reuseID = String(describing: HeaderCollectionReusableView.self)
    static let nib = UINib(nibName: String(describing: HeaderCollectionReusableView.self), bundle: nil)
    
    var searchField: UITextField!

    override func layoutSubviews() {
        super.layoutSubviews()
        searchField.frame = .zero
    }
    
    public func configure() {
        backgroundColor = .white
        searchField = UITextField()
        searchField.placeholder = "Search"
        searchField.borderStyle = .roundedRect
        addSubview(searchField)
        
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        searchField.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        searchField.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        searchField.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        searchField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
    }
}
