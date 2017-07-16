//
//  AddEventViewController.swift
//  TM
//
//  Created by Amin Amjadi on 7/15/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import UIKit

class AddEventViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var items = ["Calendar", "Time", "List", "Invite", "Location", "Alert", "Tag", "Notes", "Starts", "Ends"]
    var getInitialScrollViewContent = true
    var initialContentSize: CGFloat?
    var tempItems = [String]()
    
    var collectionViewLayout: SpringyFlowLayout? {
        return collectionView.collectionViewLayout as? SpringyFlowLayout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true

        // Do any additional setup after loading the view.
        tempItems = items
        collectionViewLayout?.setupLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddEventViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppConstants.collectionViewCellId, for: indexPath) as! AddEventCollectionViewCell
        cell.title.text = items[indexPath.row]
        return cell
    }
    
}

extension AddEventViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offestY = scrollView.contentOffset.y
        let contentSize = scrollView.contentSize.height
        let frameSize = scrollView.frame.size.height
        if getInitialScrollViewContent == true {
            self.initialContentSize = contentSize
        }
        if offestY > contentSize - frameSize {
            self.items.append(contentsOf: tempItems)
            collectionViewLayout?.setupLayout()
        }
        else if offestY < 0 {
            self.items.insert(contentsOf: tempItems, at: 0)
            let bottom = CGPoint(x: 0, y: contentSize + offestY)
            scrollView.setContentOffset(bottom, animated: false)
            collectionViewLayout?.setupLayout()
        }
        self.collectionView.reloadData()
    }
}
