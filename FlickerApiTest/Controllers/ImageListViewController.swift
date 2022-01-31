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
    var nextPage = 1
    var dataSource: [ImageInfo] = [] {
        didSet {
                collectionView.reloadData()
                nextPage += 1
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(ImageCell.nib, forCellWithReuseIdentifier: ImageCell.reuseID)
        self.collectionView.register(FooterCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: FooterCollectionReusableView.reuseID)
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
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: FooterCollectionReusableView.reuseID, for: indexPath) as! FooterCollectionReusableView
            footer.configure()
            footer.loadIndicator.startAnimating()
            flickerApi.getFeedData(page: nextPage) { [weak self] image in
                guard let self = self else { return }
                self.dataSource += image
                footer.loadIndicator.stopAnimating()
            }
            return footer
    }
}

    // MARK: - collection view layout delegate
extension ImageListViewController: UICollectionViewDelegateFlowLayout {
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sizeOfSquare = view.bounds.width / 3
        return CGSize(width: sizeOfSquare, height: sizeOfSquare)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 50)
    }
}

