//
//  HomeViewController.swift
//  Time Management
//
//  Created by Amin Amjadi on 10/12/16.
//  Copyright © 2016 MDJD. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import EventKit


class HomeViewController: UIViewController, AfterAsynchronous {
    
    var calendars = [EKEvent]() { didSet { setNeedsFocusUpdate() } }
    var reminders = [EKReminder]() { didSet { setNeedsFocusUpdate() }}
    var rowsWhichAreChecked = [NSIndexPath]()
    @IBOutlet var reminderTableView: UITableView!
    @IBOutlet weak var needPermissionView: UIView!
    @IBOutlet var noReminderView: UIVisualEffectView!
    @IBOutlet weak var secStackView: UIStackView!
    @IBOutlet weak var firstStackVIew: UIStackView!
    @IBOutlet weak var topView: CustomTopView!
    @IBOutlet weak var topViewDetail: UIStackView!
    @IBOutlet weak var dismissTopViewDetail: UIVisualEffectView!
    @IBOutlet weak var collectionViewEvents: UICollectionView!
    @IBOutlet weak var collectionViewTags: UICollectionView!
    @IBOutlet weak var topBackgroundImage: UIImageView!
    
    let listOfImages = ["barTag","entertainmentTag","meetingTag","favoriteTag","gymTag","holidayTag","partyTag","shoppingTag","studyTag","workTag"]
    let listOfColors = [UIColor.purple, UIColor.cyan, UIColor.blue, UIColor.green, UIColor.yellow, UIColor.orange, UIColor.red, UIColor.magenta, UIColor.brown, UIColor.gray]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.reminderTableView.reloadData()
        self.collectionViewEvents.reloadData()
        self.collectionViewTags.reloadData()
        
        navigationController?.isNavigationBarHidden = true
        
        let tapTopView = UITapGestureRecognizer(target: self, action: #selector(topViewTapped(sender:)))
        topView.addGestureRecognizer(tapTopView)
        
        let tapTopViewDismiss = UITapGestureRecognizer(target: self, action: #selector(topViewDismiss(sender:)))
        dismissTopViewDetail.addGestureRecognizer(tapTopViewDismiss)
        
        
        //        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
        //
        //        if user != nil {
        //
        //        try! FIRAuth.auth()!.signOut()
        //
        //        FBSDKAccessToken.setCurrent(nil)
        //
        //            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        //            appDelegate.login()
        //            }
        //        }
        UserService.shared.createDirectory()
        
    }
    
    func setBackgroundImage() {
        let now = Date()
        var image: UIImage
        let six = now.dateAt(hours: 6, minutes: 0)
        let noon = now.dateAt(hours: 12, minutes: 0)
        let five = now.dateAt(hours: 17, minutes: 0)
        let eight = now.dateAt(hours: 20, minutes: 0)
        
        if now >= six && now < noon {
            image = UIImage(named: "morning")!
        }
        else if now >= noon && now < five {
            image = UIImage(named: "afternoon")!
        }
        else if now >= five && now < eight {
            image = UIImage(named: "evening")!
        } else {
            image = UIImage(named: "night")!
        }
        self.topBackgroundImage.image = image
    }
    
    override func viewWillAppear(_ animated: Bool) {
        EventStore.shared.checkEventKitAuthorizationStatus(afterCheck: self)
        setBackgroundImage()
    }
    
    @IBAction func goToSettingsButtonTapped(_ sender: UIButton) {
        let openSettingsUrl = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(openSettingsUrl!)
    }
    
    func checkReminders(nReminders: Int) {
        if nReminders == 0 {
            reminderTableView.separatorStyle = .none
            noReminderView.frame.size = reminderTableView.frame.size
            noReminderView.frame.origin = secStackView.frame.origin
            
            view.addSubview(noReminderView)
            if topViewDetail.alpha == 1 {
                self.view.bringSubview(toFront: topViewDetail)
            }
        }
        else if nReminders > 0 {
            reminderTableView.separatorStyle = .singleLine
            noReminderView.removeFromSuperview()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func topViewTapped(sender: UITapGestureRecognizer) {
        self.view.bringSubview(toFront: topViewDetail)
        
        topViewDetail.fadeIn(0.2, sizeTransformation: false)
        (self.tabBarController as! CustomTabBarController).changeCenterButtonColor(backgroundColor: #colorLiteral(red: 0.5725, green: 0.5725, blue: 0.5725, alpha: 1), tintColor: #colorLiteral(red: 0.0863, green: 0.0863, blue: 0.0863, alpha: 1))
    }
    
    func topViewDismiss(sender: UITapGestureRecognizer) {
        topViewDetail.fadeOut(0.1, sizeTransformation: false)
        (self.tabBarController as! CustomTabBarController).changeCenterButtonColor(backgroundColor: #colorLiteral(red: 0.5725, green: 0.5725, blue: 0.5725, alpha: 1), tintColor: #colorLiteral(red: 0.0902, green: 0.0902, blue: 0.0902, alpha: 1))
    }
    
    struct Storyboard {
        static let TableViewCellIdentifier = "Reminder"
        static let CollectionViewCellIdentifier = "Event"
        static let TagCollectionViewCellIdentifier = "Tag"
    }
    
    func onFinish() {
        //let tabBar = self.tabBarController as! CustomTabBarController
        let checkAuthorizationStatus = AppError.manageError.giveError(typeOfError: "Permission")
        if checkAuthorizationStatus == true {
            calendars = EventStore.shared.giveCalendarsSinceNow()
            reminders = EventStore.shared.giveReminders()
            EventStore.shared.eraseEventArrays()
            DispatchQueue.main.async {
                self.checkReminders(nReminders: self.reminders.count)
            }
            DispatchQueue.main.async() {
                self.collectionViewEvents.reloadData()
                self.reminderTableView.reloadData()
            }
            //tabBar.showTabBar()
            needPermissionView.fadeOut()
        } else {
            //tabBar.hideTabBar()
            self.view.bringSubview(toFront: needPermissionView)
            needPermissionView.fadeIn()
        }
    }
    
    
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionViewEvents {
            return calendars.count
        } else {
            return listOfImages.count-1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionViewEvents {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CollectionViewCellIdentifier, for: indexPath) as! EventCollectionViewCell
            cell.event = calendars[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.TagCollectionViewCellIdentifier, for: indexPath) as! TagsCollectionViewCell
            cell.defaultIcon.image = UIImage(named: listOfImages[indexPath.row])
            cell.defaultView.backgroundColor = listOfColors[indexPath.row]
            return cell
        }
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ReminderTableViewCell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TableViewCellIdentifier, for: indexPath) as! ReminderTableViewCell
        let reminder:EKReminder! = self.reminders[indexPath.row]
        cell.reminderLabel?.text = reminder.title
        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let dueDate = reminder.dueDateComponents?.date {
            cell.scheduleLabel?.text = formatter.string(from: dueDate)
        } else {
            cell.scheduleLabel?.text = "N/A"
        }
        
        let isRowChecked = rowsWhichAreChecked.contains(indexPath as NSIndexPath)
        
        if(isRowChecked == true)
        {
            cell.checkbox.isChecked = true
            cell.checkbox.buttonClicked(sender: cell.checkbox)
        }else{
            cell.checkbox.isChecked = false
            cell.checkbox.buttonClicked(sender: cell.checkbox)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: ReminderTableViewCell = tableView.cellForRow(at: indexPath) as! ReminderTableViewCell
        // cross checking for checked rows
        if(rowsWhichAreChecked.contains(indexPath as NSIndexPath) == false) {
            cell.checkbox.isChecked = true
            cell.checkbox.buttonClicked(sender: cell.checkbox)
            rowsWhichAreChecked.append(indexPath as NSIndexPath)
        } else {
            cell.checkbox.isChecked = false
            cell.checkbox.buttonClicked(sender: cell.checkbox)
            // remove the indexPath from rowsWhichAreCheckedArray
            if let checkedItemIndex = rowsWhichAreChecked.index(of: indexPath as NSIndexPath){
                rowsWhichAreChecked.remove(at: checkedItemIndex)
            }
        }
    }
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == self.collectionViewEvents {
            let layout = self.collectionViewEvents?.collectionViewLayout as! UICollectionViewFlowLayout
            
            let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
            
            var offset = targetContentOffset.pointee
            
            let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
            let roundedIndex = round(index)
            
            offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
            targetContentOffset.pointee = offset
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == self.collectionViewEvents {
            topView.animateTheView()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == self.collectionViewEvents {
            topView.animateTheView()
        }
    }
}

