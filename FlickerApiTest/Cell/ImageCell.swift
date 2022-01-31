//
//  ImageCellCollectionViewCell.swift
//  FlickerApiTest
//
//  Created by  Егор Шуляк on 26.01.22.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    static let reuseID = String(describing: ImageCell.self)
    static let nib = UINib(nibName: String(describing: ImageCell.self), bundle: nil)
    
    @IBOutlet var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView?.image = nil
//        indicator.isHidden = true
    }

}
