//
//  ViewController.swift
//  FlickerApiTest
//
//  Created by  Егор Шуляк on 26.01.22.
//

import UIKit

class ImageListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private let cache = NSCache<NSString, UIImage>()
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchField: UITextField!
    
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
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseID, for: indexPath) as? ImageCell else { fatalError("Wrong cell") }
         let key = NSString(string: dataSource[indexPath.row].id)
        if let cachedImage = self.cache.object(forKey: key) {
            cell.imageView.image = cachedImage
        } else {
            self.flickerApi.loadImage(image: self.dataSource[indexPath.row]) { [weak self] image in
                guard let self = self, let image = image else { return }
                guard let cell = self.collectionView.cellForItem(at: indexPath) as? ImageCell else { return }
                cell.imageView.image = image
                self.cache.setObject(image, forKey: key)
            }
        }
        return cell
    }

    //MARK: - collectionView delegate
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let destination = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ImageInfoViewController.self)) as? ImageInfoViewController else { return }
        destination.imageData = dataSource[indexPath.row]
        present(destination, animated: true, completion: nil)
    }
    
     func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: FooterCollectionReusableView.reuseID, for: indexPath) as! FooterCollectionReusableView
            footer.configure()
         if flickerApi.prepareToLoad {
             footer.loadIndicator.startAnimating()
             if let text = searchField.text?.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "%20"), !text.isEmpty {
                 flickerApi.getSearchData(text: text, page: nextPage) { [weak self] imagesData in
                     guard let self = self else { return }
                     self.dataSource += imagesData
                     footer.loadIndicator.stopAnimating()
                     self.flickerApi.prepareToLoad = imagesData.isEmpty ? false : true
                 }
             } else {
                 flickerApi.getFeedData(page: nextPage) { [weak self] imagesData in
                     guard let self = self else { return }
                     self.dataSource += imagesData
                     footer.loadIndicator.stopAnimating()
                     self.flickerApi.prepareToLoad = imagesData.isEmpty ? false : true
                 }
             }
         } else if dataSource.isEmpty{
             footer.loadIndicator.stopAnimating()
             showMessage(toastWith: "Images not found")
         }
            return footer
     }
    
    private func showMessage(toastWith message : String) {
        
        let yPostition = self.view.frame.size.height - 44 - 16

        let frame = CGRect(x: self.view.frame.size.width/2 - 64, y: yPostition, width: 150, height: 44)
        let toast = UILabel(frame: frame)
        toast.backgroundColor = .black.withAlphaComponent(0.7)
        toast.textColor = .white
        toast.textAlignment = .center;
        toast.font = UIFont.systemFont(ofSize: 12)
        toast.text = message
        toast.alpha = 1.0
        toast.layer.cornerRadius = 10;
        toast.clipsToBounds  =  true
        self.view.addSubview(toast)

        UIView.animate(withDuration: 3, delay: 0.1, options: .curveEaseInOut, animations: {
            toast.alpha = 0.0
        }, completion: {(isCompleted) in
            toast.removeFromSuperview()
        })
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

extension ImageListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dataSource = []
        nextPage = 1
        flickerApi.prepareToLoad = true
        textField.resignFirstResponder()
        return false
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        dataSource = []
        nextPage = 1
        flickerApi.prepareToLoad = true
        return true
    }
}
