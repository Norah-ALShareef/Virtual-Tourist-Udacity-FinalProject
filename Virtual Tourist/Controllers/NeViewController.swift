// hi , Icreated this viewController to allow the user select defrient  pins from the map desplyed in Photoselected Class
import UIKit
import MapKit
import CoreData
class NeViewController: UIViewController, NSFetchedResultsControllerDelegate{
    
    // IBOutlet------------------------------------------------------------------
    @IBOutlet weak var homeSweetHome: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collictionView: UICollectionView!
    @IBOutlet weak var activityIndecator: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var NewColictonTaped: UIBarButtonItem!
    
    // variables------------------------------------------------------------------
    var pin: Pin!
    var fechResultController: NSFetchedResultsController<Photo>!
    var fechResultControllerPin: NSFetchedResultsController<Pin>!
    var pageNumber = 0
    var Delet = false
    
    var context: NSManagedObjectContext{
        return DataController.sharedDataController.viewContext
    }
    var doWehavePhoto: Bool {
        return (fechResultController.fetchedObjects?.count ?? 0) != 0
    }
    
    // Overeide Functions ------------------------------------------------------------------
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchResultController()
        setupFetchResultControllerPin()
        showResult()
        print(pageNumber)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fechResultController = nil
    }
    
    // Functions ------------------------------------------------------------------
    func setupFetchResultController(){
        
        let fetchRequst: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequst.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false) ]
        
        fetchRequst.predicate = NSPredicate(format:"pin == %@", pin)
        
        fechResultController = NSFetchedResultsController(fetchRequest: fetchRequst, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fechResultController.delegate = self
        
        do {
            try fechResultController.performFetch()
            if doWehavePhoto{
                updateUI(processing: false)
                print("yes we have photo")
            } else {
                
                newColictionTabed(self)
            }
        } catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
    }
    //------------------------------------------------------------------
    func setupFetchResultControllerPin(){
        print("entered fech requst")
        let fetchRequst: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequst.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false) ]
        fechResultControllerPin = NSFetchedResultsController(fetchRequest: fetchRequst, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fechResultControllerPin.delegate = self
        
        do {
            try fechResultControllerPin.performFetch()
            updatemapView()
        } catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    //------------------------------------------------------------------
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        //Delet
        if let indexpath = indexPath, type == .delete && !Delet{
            collictionView.deleteItems(at: [indexpath])
            return
        }
        // insert
        if let indexpath = indexPath, type == .insert {
            collictionView.insertItems(at: [indexpath])
            return
        }
        //udate
        if type != .update{
            collictionView.reloadData()
        }
    }
    // ------------------------------------------------------------------
    func updatemapView(){
        guard let pins = fechResultControllerPin.fetchedObjects else {
            return
        }
        for pin in pins{
            if mapView.annotations.contains(where: { pin.compare(to: $0.coordinate)}){
                continue
            }
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            mapView.addAnnotation(annotation)
        }
    }
    //------------------------------------------------------------------
    func showResult(){
        
        guard let location = pin else { return  }
        let latitude = location.latitude
        let longitude = location.longtude
        print(latitude)
        print(longitude)
        let cordinte = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // creat annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = cordinte
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: cordinte, span: MKCoordinateSpan(latitudeDelta: 3.00, longitudeDelta: 3.00))
        mapView.setRegion(region, animated: true)
    }
    //------------------------------------------------------------------
    func updateUI(processing: Bool){
        
        collictionView.isUserInteractionEnabled = !processing
        if processing {
            NewColictonTaped.title = " "
            activityIndecator.startAnimating()
            self.statusLabel.isHidden = false
        }else {
            activityIndecator.stopAnimating()
            activityIndecator.hidesWhenStopped = true
            NewColictonTaped.title = " New Collection"
        }
    }
    //------------------------------------------------------------------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("enter prepare function")
        if segue.identifier == "showMore" {
            let photosVC = segue.destination as! photoSelectedLocationColectionView
            photosVC.pin = sender as? Pin
            
        }
    }
    
    // IBActions ------------------------------------------------------------------
    @IBAction func newColictionTabed(_ sender: Any) {
        
        updateUI(processing: true)
        print(pageNumber)
        pageNumber += 1
        
        if doWehavePhoto {
            Delet = true
            for photo in fechResultController.fetchedObjects!{
                context.delete(photo)
            }
            try? context.save()
            Delet = false
        }
        FlickrAPI.getPhotosUrls(with: pin.coordinate, pageNumber: pageNumber) { (urls, error, message) in
            DispatchQueue.main.async {
                self.updateUI(processing: false)
                guard (error == nil) && (message == nil) else {
                    
                    self.alert(titel: "Error", message: error?.localizedDescription ?? message)
                    return
                }
                guard let urls = urls, !urls.isEmpty else {
                    
                    print("enterd gaurd")
                    self.statusLabel.isHidden = false
                    return
                }
                for url in urls{
                    let photo = Photo(context: self.context)
                    photo.imageUrl = url
                    photo.pin = self.pin
                    self.statusLabel.isHidden = true
                    
                }
                
                try? self.context.save()
                
            }
        }
        // TO RETREVE DIFFRENT PHOTO IN ECH TIME
        print(pageNumber)
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
}

//extension--------------------------------------------------------------------
extension NeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat((collectionView.frame.size.width / 2) - 10), height: CGFloat(150))
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fechResultController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print ("i enterd the cell ")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell2", for: indexPath) as! CollectionViewCell
        let photo = fechResultController.object(at: indexPath)
        cell.imageView.setPhoto(photo)
        return cell
    }
    
    // for deletion
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fechResultController.object(at: indexPath)
        context.delete(photo)
        try? context.save()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collictionView.reloadData()
    }
    
    
}
//--------------------------------------------------------------------
extension NeViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // pring pin
        print("pring the pin function")
        let pin = fechResultControllerPin.fetchedObjects?.filter{
            $0.compare(to: view.annotation!.coordinate)
            }.first!
        
        performSegue(withIdentifier: "showMore", sender: pin)
    }
 
}
// The End ^_^ --------------------------------------------------------------------

