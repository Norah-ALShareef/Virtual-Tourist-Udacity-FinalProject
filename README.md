# Virtual-Tourist-Udacity-FinalProject
This App downloads and stores images from Flickr. 
The app allows users to drop pins on a map, as if they were stops on a tour. 
Users will then be able to download pictures for the location and persist both the pictures, and the association of the pictures with the pin.

<img width="454" alt="minPage" src="https://user-images.githubusercontent.com/40995452/61463650-86422a00-a97d-11e9-9a35-0eca1ac0d652.png">


## Installation 

- clone this projet by adding this line to your Trminal

`https://github.com/Norah-ALShareef/Virtual-Tourist-Udacity-FinalProject.git`

- creat an account on [Flikr](https://www.flickr.com)

## implemntation

This project containe 3 ViewControolers : 
- `mainPage(MapView).swift` This view contain mapKit function and FetchedResult functions onse the user taps the location `IBAction` will call it function and adds a pin to the map onse that pin has been taped it will perform the Fetched and move to the `photoSelectedLocationColectionView`.
- `photoSelectedLocationColectionView` Here tha magic will happen two Fetche function has been performed `NSFetchedResultsController<Photo>!` &  `NSFetchedResultsController<Pin>!` and collectionViw functions to show the pics  related to the pin and delet thim.
- `NeViewController`  same as photoSelectedLocationColectionView 

## Requirements 

- xcode 10
- Swift 5
- flickr Key

## Copyright 

Copyright (c) 2019 Norah Alshareef
