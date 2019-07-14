import UIKit
import MapKit
import CoreData

class photoSelectedLocationColectionView: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapViewMini: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var activityIndecator: UIActivityIndicatorView!
    
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchResultController()
        showResult()
        print(pageNumber)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fechResultController = nil
    }
    
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

            } else {

                    newCollectionTapped(self)
                }
        } catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
    }
    
    
    @IBAction func newCollectionTapped(_ sender: Any) {
        
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
    
    func updateUI(processing: Bool){
        
        collectionView.isUserInteractionEnabled = !processing
        if processing {
            newCollectionButton.title = " "
            activityIndecator.startAnimating()
            self.statusLabel.isHidden = false


        }else {
            activityIndecator.stopAnimating()
            activityIndecator.hidesWhenStopped = true
            newCollectionButton.title = " New Collection"

        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    
        
        //Delet
        if let indexpath = indexPath, type == .delete && !Delet{
            collectionView.deleteItems(at: [indexpath])
            return
        }
        
        // insert
        if let indexpath = indexPath, type == .insert {
            collectionView.insertItems(at: [indexpath])
            return
        }
        //udate
        if type != .update{
            collectionView.reloadData()
        }
    }
    // CollictionView ---------------------------------------------------------
 
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat((collectionView.frame.size.width / 2) - 10), height: CGFloat(150))
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fechResultController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "phorocell", for: indexPath) as! selectedPhotoCell
        print ("Colliction view cell")
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
      // END of CollictionView ---------------------------------------------------------
    
    func setupFetchResultControllerPin(){
        print("entered fech requst")
        let fetchRequst: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequst.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false) ]
        fechResultControllerPin = NSFetchedResultsController(fetchRequest: fetchRequst, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fechResultControllerPin.delegate = self
        
        do {
            try fechResultControllerPin.performFetch()
           // updatemapView()
        } catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
    }
    
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
        mapViewMini.addAnnotation(annotation)
        

        let region = MKCoordinateRegion(center: cordinte, span: MKCoordinateSpan(latitudeDelta: 0.20, longitudeDelta: 0.20))

        mapViewMini.setRegion(region, animated: true)
        
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
