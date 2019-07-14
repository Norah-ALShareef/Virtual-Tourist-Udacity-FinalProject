
import UIKit

let imageCache = NSCache<NSString, AnyObject>()

class customImageView: UIImageView {

    var imageUrl: URL!
    
    func setPhoto(_ newPhoto: Photo){
        print("enterd set photo functon")
            photo = newPhoto
    }
    
    private var photo: Photo! {
        didSet{
            if let image = photo.getImage(){
                print ("did call get image ")
                // hideActivityIndicatorView()
                self.image = image
                return
            }
            
            guard let url = photo.imageUrl else {
                return
            }
            print(url)
            
            loadImageUsingCache(with: url)
            
        }
    }
    
    func loadImageUsingCache(with url: URL){
        self.showActivityIndecatorView()
        print ("enterd load image using cash")
        imageUrl = url
        image = nil
        if let chachedImage = imageCache.object(forKey: url.absoluteString as NSString) as? UIImage {
            self.image = chachedImage
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let DownlodedImage = UIImage(data: data!)else {return}
            imageCache.setObject(DownlodedImage, forKey: url.absoluteString as NSString)
            DispatchQueue.main.async {
                
                self.image = DownlodedImage
                self.photo.set(image: DownlodedImage)
                try? self.photo.managedObjectContext?.save()
                self.hideActivityIndecatorView()
                
            }
            
        }.resume()
    }
    
    lazy var activityIndicatorView2: UIActivityIndicatorView = {
        
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        self.addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityIndicatorView.color = .black
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()
    
    func showActivityIndecatorView(){
        DispatchQueue.main.async {
            self.activityIndicatorView2.startAnimating()
        }
    }
    
    func hideActivityIndecatorView(){
        DispatchQueue.main.async {
            self.activityIndicatorView2.stopAnimating()
        }
    }
}

