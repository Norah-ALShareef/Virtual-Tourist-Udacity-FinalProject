
import Foundation
import MapKit
import UIKit


struct FlickrAPI {
    
    static func getPhotosUrls(with coordinate: CLLocationCoordinate2D, pageNumber: Int, complition: @escaping ([URL]?, Error?, String?) -> ()){
        
        let request = URLRequest(url: URL(string:"https://api.flickr.com/services/rest?api_key=be6f98a3fe30bc438233f3113d97e6b1&extras=url_m&page=\(pageNumber)&method=flickr.photos.search&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&accuracy=11&safe_search=1&format=json&per_page=6&nojsoncallback=1")!
        )
        let task = URLSession.shared.dataTask(with: request){(data, response, error) in
            guard (error == nil) else {
                complition(nil, error, nil)
                
                //alert(titel: "Error", message: "there is No enternet connection")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                complition(nil, nil, "Your requst other ...")
                return
            }
            
            guard let data = data else {
                complition(nil, nil, "No data was retreved")
                return
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] else {
                complition(nil, nil, "Could Not Parse THe Data")
                return
            }
            
            guard let stat = result["stat"] as? String, stat == "ok" else {
                complition(nil, nil, "Flicker is returning Error. See error code and message in \(result)")
                return
            }
            
            guard let photosDictionary = result["photos"] as? [String:Any] else {
                complition(nil, nil, "Cannot find key 'photos' in \(result)")
                return
            }
            
            guard let photoArray = photosDictionary["photo"] as? [[String:Any]] else {
                complition(nil, nil, "Cannot Find Key 'Photo' in \(photosDictionary)")
                return
            }
            
            let photosURLs = photoArray.compactMap {
                photosDictionary -> URL? in guard let url = photosDictionary["url_m"] as? String else {return nil}
                return URL(string: url)
                
            }
            complition(photosURLs, nil, nil)
            
            print(photosURLs)
        }
        task.resume()
        
    }
    
}
extension UIViewController{
    
    func alertNoInternet(titel: String, message: String?){
        
        let alert = UIAlertController(title: titel, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        DispatchQueue.main.async {
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}


