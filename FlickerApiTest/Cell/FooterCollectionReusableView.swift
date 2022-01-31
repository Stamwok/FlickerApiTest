//
//  FooterCollectionReusableView.swift
//  FlickerApiTest
//
//  Created by  Егор Шуляк on 30.01.22.
//

import UIKit

class FooterCollectionReusableView: UICollectionReusableView {
    
    static let reuseID = String(describing: FooterCollectionReusableView.self)
    
    var loadIndicator: UIActivityIndicatorView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        loadIndicator.frame = bounds
    }
    
    public func configure() {
        loadIndicator = UIActivityIndicatorView()
        self.addSubview(loadIndicator)
        loadIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        loadIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        loadIndicator.layoutIfNeeded()
    }
    
}
