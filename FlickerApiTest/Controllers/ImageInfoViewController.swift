//
//  ImageInfoViewController.swift
//  FlickerApiTest
//
//  Created by  Егор Шуляк on 28.01.22.
//

import UIKit

class ImageInfoViewController: UIViewController {
    
    var imageData: ImageInfo?
    var flickerApi = FlickerApi()
    
    @IBOutlet var imageAspectRatio: NSLayoutConstraint!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var loadIndicator: UIActivityIndicatorView!
    @IBOutlet var ownerLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let imageData = imageData else { return }
        titleLabel.text = imageData.title
        loadIndicator.startAnimating()
        flickerApi.getUserInfo(userId: imageData.owner) { [weak self] user in
            guard let self = self else { return }
            self.ownerLabel.text = user
        }
        flickerApi.loadImage(image: imageData) { [weak self] image in
            guard let self = self else { return }
            self.imageData?.imageAspectRatio = self.getImageAspectRation(image: image!)
            let newConstraint = self.imageAspectRatio.constraintWithMultiplier(self.imageData!.imageAspectRatio!)
            self.imageView.removeConstraint(self.imageAspectRatio)
            self.imageView.addConstraint(newConstraint)
            self.imageAspectRatio = newConstraint
            self.imageView.updateConstraintsIfNeeded()
            self.imageView.image = image
            self.loadIndicator.stopAnimating()
            self.loadIndicator.isHidden = true
        }
    }
    
    private func getImageAspectRation(image: UIImage) -> CGFloat {
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        return imageWidth / imageHeight
    }
    
}

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}
