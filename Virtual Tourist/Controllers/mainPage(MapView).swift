
import UIKit
import MapKit
import CoreData

class mainPage_MapView_: UIViewController, NSFetchedResultsControllerDelegate {
    
    //IBOutlet Functions --------------------------------------------------------------------
    @IBOutlet weak var mapView: MKMapView!
    
    //variabels --------------------------------------------------------------------
    var fechResultController : NSFetchedResultsController <Pin>!
    var context: NSManagedObjectContext{
        return DataController.sharedDataController.viewContext
    }
    
    //Override Functions --------------------------------------------------------------------
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchResultController()
    }
    //--------------------------------------------------------------------
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fechResultController = nil
    }
    //Functions --------------------------------------------------------------------
    func setupFetchResultController(){
        print("entered fech requst")
        let fetchRequst: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequst.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false) ]
        fechResultController = NSFetchedResultsController(fetchRequest: fetchRequst, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fechResultController.delegate = self
        
        do {
            try fechResultController.performFetch()
            updatemapView()
        } catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    //--------------------------------------------------------------------
    func updatemapView(){
        guard let pins = fechResultController.fetchedObjects else {
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
    //--------------------------------------------------------------------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("enter prepare function")
        if segue.identifier == "nextpage" {
            let photosVC = segue.destination as! photoSelectedLocationColectionView
            photosVC.pin = sender as? Pin
            
        }
    }
    //--------------------------------------------------------------------
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updatemapView()
    }
    
    //IBAction --------------------------------------------------------------------
    @IBAction func addPinLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state != .began{ return }
        let touchPoint = sender.location(in: mapView)
        
        let pin = Pin(context: context)
        pin.coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        try? context.save()
    }
}

//extension --------------------------------------------------------------------
extension mainPage_MapView_ :  MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // pring pin
        print("pring the pin function")
        let pin = fechResultController.fetchedObjects?.filter{
            $0.compare(to: view.annotation!.coordinate)
            }.first!
        
        performSegue(withIdentifier: "nextpage", sender: pin)
    }
}

