// i created this file so that i can edit to the data model
import Foundation
import MapKit

extension Pin {
    
    var coordinate: CLLocationCoordinate2D{
        
        set {
            latitude = newValue.latitude
            longtude = newValue.longitude
        }
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longtude)
        }
    }
    // compare the coordinate
    func compare(to coordinate: CLLocationCoordinate2D) -> Bool {
        return (latitude == coordinate.latitude && longtude == coordinate.longitude)
        
    }
    // to set the data
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
