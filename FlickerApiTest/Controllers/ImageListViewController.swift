//
//  ViewController.swift
//  FlickerApiTest
//
//  Created by  Егор Шуляк on 26.01.22.
//

import UIKit

class ImageListViewController: UICollectionViewController {
    
    private let cache = NSCache<NSNumber, UIImage>()
    
    var flickerApi = FlickerApi()
    var dataSource: [Image] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(ImageCell.nib, forCellWithReuseIdentifier: ImageCell.reuseID)
        flickerApi.getFeedData { images in
            self.dataSource = images
        }
    }
    
    // MARK: - collection view data source delegate
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseID, for: indexPath) as? ImageCell else { fatalError("Wrong cell") }
        return cell
    }

    //MARK: - collectionView delegate
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ImageCell else { return }
        let itemNumber = NSNumber(value: indexPath.row)
        if let cachedImage = self.cache.object(forKey: itemNumber) {
            cell.imageView.image = cachedImage
        } else {
            cell.indicator.startAnimating()
            self.flickerApi.loadImage(image: self.dataSource[Int(truncating: itemNumber)]) { [weak self] image in
                guard let self = self, let image = image else { return }
                guard let cell = self.collectionView.cellForItem(at: indexPath) as? ImageCell else { return }
                cell.imageView.image = image
                self.cache.setObject(image, forKey: itemNumber)
                cell.indicator.stopAnimating()
                cell.indicator.isHidden = true
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let destination = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ImageInfoViewController.self)) as? ImageInfoViewController else { return }
        destination.imageData = dataSource[indexPath.row]
        present(destination, animated: true, completion: nil)
    }
}

    // MARK: - collection view layout delegate
extension ImageListViewController: UICollectionViewDelegateFlowLayout {
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sizeOfSquare = view.bounds.width / 3
        return CGSize(width: sizeOfSquare, height: sizeOfSquare)
    }
}

