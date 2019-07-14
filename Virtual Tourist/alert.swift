
import Foundation
import UIKit

extension UIViewController{
    func alert(titel: String, message: String?){
        
        let alert = UIAlertController(title: titel, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        DispatchQueue.main.async {
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}
