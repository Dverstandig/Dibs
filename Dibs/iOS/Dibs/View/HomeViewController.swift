//
//  HomeViewController.swift
//  Dibs
//
//  Created by Jacob Lattie on 2/27/20.
//  Copyright © 2020 Jacob Lattie. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    
//    fileprivate let collectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        layout.minimumLineSpacing = 20.0
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.translatesAutoresizingMaskIntoConstraints = false
////        cv.register(SpotCell.self, forCellWithReuseIdentifier: "spotCell")
//        cv.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
//        return cv
    //    }()
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate let refreshControl = UIRefreshControl()
    
//    fileprivate let bannerView: UIView = {
//        let bannerView = UIView(frame: .zero)
//        return bannerView
//    }()
    @IBOutlet weak var bannerView: UIView!
    
    fileprivate let colors = [UIColor.green, UIColor.yellow, UIColor.red, UIColor.green, UIColor.red, UIColor.green, UIColor.red, UIColor.green]
    
    fileprivate var spotCounts = ["0", "20", "30", "10", "20", "30", "10", "20", "30"]
    
    fileprivate var spotTags = ["CULC (test)", "Van Leer", "McCamish Pavilion", "Green", "Red", "Green", "Red", "Green"]
    
    fileprivate var spotDict = Dictionary<String, Int>()
    var thisDibsChairList: [DibsChair] = []
    
    fileprivate var spotCount: Int = 0

//    @IBOutlet weak var scrollView: UIScrollView!
    
//    @IBOutlet weak var contentView: UIView!
    
    let db = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10.0
        layout.minimumInteritemSpacing = 0.0
        layout.itemSize = CGSize(width: collectionView.frame.width/2.0, height: collectionView.frame.height/1.5)
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 100, right: 10)
        
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
//        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = refreshControl
        
        collectionView.isScrollEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dragInteractionEnabled = true
        
            
        // Do any additional setup after loading the view.
        

//        collectionView.refreshControl?.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -40).isActive = true
        collectionView.refreshControl?.translatesAutoresizingMaskIntoConstraints = false
        // get data of how many Spots from spot class (tester + db.count + add_new_cell)
        self.spotCount = 1 + self.spotDict.count + 1
        
//        collectionView.reloadData()
        print("Debug")
//        db.readTest()
//        DispatchQueue.main.async {
//            self.db.readAllChairs()
//        }
//        db.readAllChairs()
//        print(db.count)
//        self.spotDict = db.getDictOfDibsBuildings()
//        db.readAllChairs()
//        self.spotDict = db.getDictOfDibsBuildings()
//        print(self.spotDict)
        readAllChairs()
        print(self.spotDict)
    }
    
    func readAllChairs() {
        var dibsChairList = [DibsChair]()
        self.db.child("chair").observe(.value, with: { (snapshot) in
            // Get chair data
            guard let value = snapshot.value as? NSDictionary else {
                print("Invalid Firebase Read")
                return
            }
            print(".")
            print(".")
            print(".")
            let keys = value.allKeys
            print("Keys: ")
            print(keys)
            
            for key in keys {
                
                let dibsChair = DibsChair()
                
                if let chair_dict = value[key] as? NSDictionary {
                    
                    print("------")
                    
                    if let building = chair_dict["Building"] as? String {
                        print(building)
                        dibsChair.building = building
                    }
                    if let floor = chair_dict["Floor"] as? String {
                        print(floor)
                        dibsChair.floor = floor
                    }
                    if let room = chair_dict["Room"] as? String {
                        print(room)
                        dibsChair.room = room
                    }
                    if let status = chair_dict["status"] as? String {
                        print(status)
                        dibsChair.status = status
                    }
                    dibsChairList.append(dibsChair)
                    print("------")
                } else {
                    continue
                }
                
            }
            self.thisDibsChairList = dibsChairList
            self.spotDict = self.getDictOfDibsBuildings()
            print(".")
            print(".")
            print(".")
            
            if dibsChairList.isEmpty {
                print("No change in data")
            } else {
                self.spotCount += self.spotDict.count
                self.collectionView.reloadData()
            }
//            print(dibsChairList)
//            self.thisDibsChairList = dibsChairList
//            self.validRead = true
            
        }) { (error) in
            print("readAllChairs error")
            print(error.localizedDescription)
        }
        print("Here")
        print(dibsChairList)
        print(self.thisDibsChairList)
    }
        
    func getDictOfDibsBuildings() -> Dictionary<String, Int> {
        
        var buildingDict = Dictionary<String, Int>()
        
        for chair in self.thisDibsChairList {
            buildingDict[chair.building, default: 0] += 1
        }
        print(buildingDict)
        return buildingDict
    }
    
    @objc
    private func didPullToRefresh(_ sender:Any) {
        print("Refresh Data")
        print(self.spotDict)

        
        refreshControl.endRefreshing()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



// MARK: - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
extension HomeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 0.95*collectionView.frame.width
        return CGSize(width: collectionView.frame.width/2.0 - 15.0, height: collectionView.frame.width/2.0 - 15.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spotCount
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("Starting Index: \(sourceIndexPath.item)")
        print("Ending Index: \(destinationIndexPath.item)")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dibsCell", for: indexPath) as! DibsCell
        print(cell)
        if let label = cell.locationLabel {
            label.text = spotTags[indexPath.row]
        }
        if let countLabel = cell.spotCountLabel {
            countLabel.text = spotCounts[indexPath.row]
        }
        print(cell.locationLabel.text)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dibsCell", for: indexPath) as! DibsCell
        print(self.spotTags[indexPath.row])
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        scrollView.contentOffset.x = 0.0
//    }
    
}

// MARK: - UICollectionViewDragDelegate, UICollectionViewDropDelegate
extension HomeViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidEnter session: UIDropSession) {
        print("Enter")
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidExit session: UIDropSession) {
        print("Exit")
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let tag = spotTags[indexPath.row]
        let count = spotCounts[indexPath.row]
        let arr = [tag, count]
        let itemProvider = NSItemProvider(object: tag as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = arr
        print("Touched \(tag)")
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        print("Drop Delegate Method")
        var destinationPathIndex: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationPathIndex = indexPath
        } else {
            let row = collectionView.numberOfItems(inSection: 0)
            destinationPathIndex = IndexPath(item: row - 1, section: 0)
        }
        if coordinator.proposal.operation == .move {
            print("Here")
            self.reorderItems(collectionView: collectionView, coordinator: coordinator, destinationIndexPath: destinationPathIndex)
        }
    
    }
    
    fileprivate func reorderItems(collectionView: UICollectionView, coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath) {
        if let item = coordinator.items.first,
            let sourceIndexPath = item.sourceIndexPath {
            
            collectionView.performBatchUpdates({
                
                if let arr = item.dragItem.localObject as? [NSString] {
                    self.spotTags.remove(at: sourceIndexPath.item)
                    self.spotTags.insert(arr[0] as String, at: destinationIndexPath.item)
                    self.spotCounts.remove(at: sourceIndexPath.item)
                    self.spotCounts.insert(arr[1] as String, at: destinationIndexPath.item)
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                }
                
            }, completion: nil)
            
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
    }
    
}
