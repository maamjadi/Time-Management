//
//  AddEventViewController.swift
//  TM
//
//  Created by Amin Amjadi on 7/15/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import UIKit
import JTAppleCalendar

class AddEventViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var detailMenuBtnView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var dimView: UIView!
    @IBOutlet var timeView: UIView!
    @IBOutlet weak var hourSelector: UIView!
    @IBOutlet weak var hourSelector2: UIView!
    @IBOutlet weak var minuteSelector: UIView!
    @IBOutlet weak var minuteSelector2: UIView!
    @IBOutlet weak var centertimeSelector: UIView!
    @IBOutlet weak var centertimeSelector2: UIView!
    @IBOutlet weak var expandChooseDateTimeBtn: UIButton!
    @IBOutlet weak var expandChooseDateTimeBtn2: UIButton!
    @IBOutlet weak var chooseDateTimeCalendar: JTAppleCalendarView!
    @IBOutlet weak var chooseDateTimeCalendar2: JTAppleCalendarView!
    @IBOutlet weak var hourTimeViewLabel: UILabel!
    @IBOutlet weak var hourTimeViewLabel2: UILabel!
    @IBOutlet weak var minuteTimeViewLabel: UILabel!
    @IBOutlet weak var minuteTimeViewLabel2: UILabel!
    @IBOutlet weak var amPMTimeViewLabel: UILabel!
    @IBOutlet weak var amPMTimeViewLabel2: UILabel!
    @IBOutlet weak var monthTimeViewLabel: UILabel!
    @IBOutlet weak var monthTimeViewLabel2: UILabel!
    @IBOutlet weak var monthCalendarTimeViewLabel: UILabel!
    @IBOutlet weak var monthCalendarTimeViewLabel2: UILabel!
    @IBOutlet weak var dateTimeViewLabel: UILabel!
    @IBOutlet weak var dateTimeViewLabel2: UILabel!
    @IBOutlet weak var dayTimeViewLabel: UILabel!
    @IBOutlet weak var dayTimeViewLabel2: UILabel!
    @IBOutlet weak var chooseDatePanelTimeView: UIStackView!
    @IBOutlet weak var chooseDatePanelTimeView2: UIStackView!
    @IBOutlet weak var startViewTabTimeView: UIView!
    @IBOutlet weak var endViewTabTimeView: UIView!
    @IBOutlet weak var moreViewTabTimeView: UIView!
    
    var items = ["Calendar", "Time", "List", "Invite", "Location", "Alert", "Tag", "Notes", "Starts", "Ends"]
    var getInitialScrollViewContent = true
    var initialContentSize: CGFloat?
    var tempItems = [String]()
    let formatter = DateFormatter()
    let date = Date()
    
    
    var collectionViewLayout: SpringyFlowLayout? {
        return collectionView.collectionViewLayout as? SpringyFlowLayout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        // Do any additional setup after loading the view.
        tempItems = items
        collectionViewLayout?.setupLayout()
        detailMenuBtnView.layer.cornerRadius = detailMenuBtnView.frame.size.width / 2
        detailMenuBtnView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        buttonReleased()
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissSubviews(sender:)))
        dimView.addGestureRecognizer(dismissTap)
        hourSelector.layer.cornerRadius = hourSelector.frame.size.width / 2
        minuteSelector.layer.cornerRadius = minuteSelector.frame.size.width / 2
        centertimeSelector.layer.cornerRadius = centertimeSelector.frame.size.width / 2
        
        setupChooseDateCalendarView()
        
        let width = self.view.frame.size.width
        endViewTabTimeView.transform = CGAffineTransform(translationX: width, y: 0)
        moreViewTabTimeView.transform = CGAffineTransform(translationX: 2*width, y: 0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        chooseDatePanelTimeView.transform = CGAffineTransform(translationX: chooseDatePanelTimeView.frame.size.width + 20, y: 0)
        chooseDatePanelTimeView2.transform = CGAffineTransform(translationX: chooseDatePanelTimeView.frame.size.width + 20, y: 0)
        chooseDatePanelTimeView.isHidden = true
        chooseDatePanelTimeView2.isHidden = true
        chooseDateTimeCalendar.scrollToDate(date, animateScroll: false)
        chooseDateTimeCalendar.selectDates(from: date, to: date)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func menuButtonAction(_ sender: UIButton) {
        if detailMenuBtnView.transform != .identity {
            UIView.animate(withDuration: 0.3, animations: {
                self.detailMenuBtnView.transform = .identity
                
                self.menuButton.setImage(UIImage(named: "addEventMainButtonDetail"), for: .normal)
            })
        }
    }
    
    @IBAction func menuButtonRelease(_ sender: UIButton, forEvent event: UIEvent) {
        menuAction(event: event)
    }
    
    @IBAction func menuButtonReleaseOutside(_ sender: UIButton, forEvent event: UIEvent) {
        menuAction(event: event)
    }
    
    func buttonReleased() {
        if detailMenuBtnView.transform == .identity {
            UIView.animate(withDuration: 0.3, animations: {
                self.detailMenuBtnView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                self.menuButton.setImage(UIImage(named: "addEventMainButton"), for: .normal)
            })
        }
    }
    
    func dismissSubviews(sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.dimView.alpha = 0
            self.timeView.transform = CGAffineTransform(scaleX: 0.1, y: 0.05)
        }, completion: {(success) in
            self.timeView.removeFromSuperview()
        })
    }
    
    func showSubviewForCollectionView(cell: UICollectionViewCell) {
        guard let validCell = cell as? AddEventCollectionViewCell else { return }
        if validCell.title.text == "Time" {
            dimView.isUserInteractionEnabled = true
            self.timeView.center = self.view.center
            self.timeView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
            timeView.layer.cornerRadius = 10
            self.view.addSubview(timeView)
            timeView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [], animations: {
                self.dimView.alpha = 0.7
                self.timeView.transform = .identity
            })
        }
    }
    
    func menuAction(event: UIEvent) {
        if let touch = event.allTouches?.first {
            let pointOfTouch = touch.location(in: self.view)
            let menuFrame = menuButton.frame
            let width = menuFrame.size.width
            let origin = menuFrame.origin
            //let detailViewOrigin = detailMenuBtnView.frame.origin
            if (pointOfTouch.y < origin.y-width && pointOfTouch.y >= 0 && pointOfTouch.x >= origin.x && pointOfTouch.x <= origin.x+width*2) {
                saveEvent()
            }
            else if (pointOfTouch.x < origin.x-width && pointOfTouch.x >= 0 && pointOfTouch.y >= origin.y && pointOfTouch.y <= origin.y+width*2) {
                self.dismiss(animated: true, completion: nil)
            }
        }
        buttonReleased()
    }
    
    func saveEvent() {
        print("Save Funtion")
    }
    
    @IBAction func timeSegmentValueChanged(_ sender: CustomSegmentControl) {
        let width = self.view.frame.size.width
        switch sender.selectedButtonIndex {
        case 0:
            UIView.animate(withDuration: 0.3, animations: {
                self.startViewTabTimeView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.endViewTabTimeView.transform = CGAffineTransform(translationX: width, y: 0)
                self.moreViewTabTimeView.transform = CGAffineTransform(translationX: 2*width, y: 0)
            })
            break
        case 1:
            UIView.animate(withDuration: 0.3, animations: {
                self.startViewTabTimeView.transform = CGAffineTransform(translationX: -width, y: 0)
                self.endViewTabTimeView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.moreViewTabTimeView.transform = CGAffineTransform(translationX: width, y: 0)
            })
            break
        case 2:
            UIView.animate(withDuration: 0.3, animations: {
                self.startViewTabTimeView.transform = CGAffineTransform(translationX: -(2*width), y: 0)
                self.endViewTabTimeView.transform = CGAffineTransform(translationX: -width, y: 0)
                self.moreViewTabTimeView.transform = CGAffineTransform(translationX: 0, y: 0)
            })
            break
        default:
            break
        }
    }
    
    @IBAction func expandChooseDateTime(_ sender: UIButton) {
        expandChooseDateTimeBtn.isHidden = true
        chooseDatePanelTimeView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.chooseDatePanelTimeView.transform = CGAffineTransform.identity
        }
    }
    
    func dismissChooseDatePanelTimeView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.chooseDatePanelTimeView.transform = CGAffineTransform(translationX: self.chooseDatePanelTimeView.frame.size.width + 20, y: 0)
        }) { (sucess) in
            self.expandChooseDateTimeBtn.isHidden = false
            self.chooseDatePanelTimeView.isHidden = true
        }
    }
    
    @IBAction func nextMonthTimeView() {
        chooseDateTimeCalendar.visibleDates { (visibleDates) in
            if let startDate = visibleDates.monthDates.first?.date {
                var components = Calendar.current.dateComponents([.year, .month, .day], from: startDate)
                
                // Change int value which you want to minus from current Date.
                components.day = 1
                components.month = components.month!+1
                let nextMonth = Calendar.current.date(from: components)
                self.chooseDateTimeCalendar.scrollToDate(nextMonth!)
            }
        }
    }
    
    @IBAction func previousMonthTimeView() {
        chooseDateTimeCalendar.visibleDates { (visibleDates) in
            if let startDate = visibleDates.monthDates.first?.date {
                var components = Calendar.current.dateComponents([.year, .month, .day], from: startDate)
                
                // Change int value which you want to minus from current Date.
                components.day = 1
                components.month = components.month!-1
                let nextMonth = Calendar.current.date(from: components)
                self.chooseDateTimeCalendar.scrollToDate(nextMonth!)
            }
        }
    }
    
    func handleChooseDateCellTimeView(cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? ChooseDateTimeCollectionViewCell else { return }
    }
    
    func handleChooseDateTextColorTimeView() {
        
    }
    
    func handleChooseDateSelectedViewTimeView() {
        
    }
    
    func selectedCellUpdateTimeView(cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? ChooseDateTimeCollectionViewCell else { return }
        formatter.dateFormat = "MMM"
        monthTimeViewLabel.text = " " + formatter.string(from: cellState.date)
        formatter.dateFormat = "dd"
        dateTimeViewLabel.text = formatter.string(from: cellState.date)
    }
    
    func setupChooseDateCalendarView() {
        chooseDateTimeCalendar.minimumLineSpacing = 0
        chooseDateTimeCalendar.minimumInteritemSpacing = 0
        
        chooseDateTimeCalendar.visibleDates { (visibleDates) in
            if let startDate = visibleDates.monthDates.first?.date {
                
                self.formatter.dateFormat = "MMMM"
                self.monthCalendarTimeViewLabel.text = self.formatter.string(from: startDate)
            }
        }
    }
    
    
    func editingTimeBegin(component: String, state: String) {
        switch component {
        case "time":
            if state == "begin" {
                
            } else {
                
            }
            break
        case "date":
            if state == "begin" {
                
            } else {
                
            }
            break
        default:
            break
        }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showSubviewForCollectionView(cell: collectionView.cellForItem(at: indexPath)!)
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
        if scrollView == collectionView {
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
}

extension AddEventViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = formatter.date(from: "2017 12 31")!
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 1)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "ChooseDateTimeCell", for: indexPath) as! ChooseDateTimeCollectionViewCell
        cell.dateOfCell.text = cellState.text
        handleChooseDateCellTimeView(cell: cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleChooseDateCellTimeView(cell: cell, cellState: cellState)
        dismissChooseDatePanelTimeView()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleChooseDateCellTimeView(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupChooseDateCalendarView()
    }
    
}
