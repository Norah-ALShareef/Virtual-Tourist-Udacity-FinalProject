// i created this file so that i can edit to the data model
import Foundation
import UIKit
import CoreData

extension Photo {
    
    func set(image: UIImage){
        print("set image in Photo class ")
        self.imageData = image.pngData()
        
    }
    
    func getImage() -> UIImage? {
        
        print("get image in Photo class ")
        
        var imagechiking = imageData
        let imagepro : UIImage
        
        if imagechiking == nil {
            return nil
        }else {
            print("enter the chiking function")
            imagepro = UIImage(data: imagechiking!)!
            
            
        }
        
        return imagepro
    }
    // to set the data
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}

