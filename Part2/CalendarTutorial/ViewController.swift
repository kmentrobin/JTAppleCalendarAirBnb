//
//  ViewController.swift
//  CalendarTutorial
//
//  Created by Jeron Thomas on 2016-10-15.
//  Copyright © 2016 OS-Tech. All rights reserved.
//

import UIKit
import JTAppleCalendar


class CustomBlurryView : UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.layer.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
}


class ViewController: UIViewController {

    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    @IBOutlet weak var selectedDatesLabel: UILabel!
    
    let white = UIColor(colorWithHexValue: 0xECEAED)
    let darkPurple = UIColor(colorWithHexValue: 0x3A284C)
    let dimPurple = UIColor(colorWithHexValue: 0x574865)
    let niceRed = UIColor(colorWithHexValue: 0xFC3259)
    
    var notAvailibleDates = [Date().addingTimeInterval(3600*24), Date().addingTimeInterval(72*3600), Date().addingTimeInterval(96*3600), Date().addingTimeInterval(208*3600)]
    
    // Dates which are reserved
    
    let formatter = DateFormatter()
    let monthFormatter = DateFormatter()
    var testCalendar = Calendar.current
    let selectedFormatter = DateFormatter()

    var noDates = [String]()
    
    var firstDate: Date?
    
    var timeSorted = [TimeInterval]()
    var nearestNotAvailibleDate : Date?
    var itemSize = Double()
    
    var cellHeight = CGFloat()
    
    var todayDate = ""
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.dateFormat = "yyyy MM dd"
        monthFormatter.dateFormat = "MMMM yyyy"
        selectedFormatter.dateFormat = "dd.MM.YYYY"
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.registerCellViewXib(file: "CellView")
        // Registering your cell is manditory
        
        
        let screenWidth = self.view.frame.size.width // Get screen width to make it full screen and count required width of cell
        itemSize = Double(screenWidth) / 7
        print(itemSize)
        
        todayDate = formatter.string(from: Date())
        
        cellHeight = CGFloat(itemSize - 5) // Because we dont want our selected views will touch
        
        
        calendarView.itemSize = CGFloat(itemSize)
        calendarView.cellInset = CGPoint(x: -2.0 , y: -2.0)
        
        calendarView.allowsMultipleSelection  = true
        calendarView.rangeSelectionWillBeUsed = true
        calendarView.direction = .vertical
        calendarView.scrollingMode = .none
        
        timeSorted = notAvailibleDates.map{$0.timeIntervalSince1970}.filter{$0 > 0}.sorted(by: >)

        for noAvailbleDate in notAvailibleDates {
            let date = formatter.string(from: noAvailbleDate)
            noDates.append(date)
        }
        
       notAvailibleDates = notAvailibleDates.sorted(by: {$0.timeIntervalSince1970 < $1.timeIntervalSince1970})
        
        
        calendarView.registerHeaderView(xibFileNames: ["PinkSectionHeaderView"])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Function to handle the text color of the calendar


    
    func handleCellTextColor(view: JTAppleDayCellView?, cellState: CellState) {
        guard let myCustomCell = view as? CellView  else {
            return
        }
        
        if cellState.isSelected {
            myCustomCell.dayLabel.textColor = UIColor.white
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                myCustomCell.dayLabel.textColor = niceRed
            } else {
                myCustomCell.dayLabel.textColor = dimPurple
            }
        }
    }
    
    func getNearestNotAvailibleDay(selectedDay: Date){
        
        //Count nearest reserved date so you cant book trough this reservation like airbnb
        
        let selected = selectedDay.timeIntervalSince1970
        var min : Double? = nil
        var nearestDate = Date()
        
        
        for time in timeSorted {
            let difference = time - selected
            if min != nil {
                if difference < min! && difference > 0.0 {
                    min = difference
                    nearestDate = Date.init(timeIntervalSince1970: time)
                    self.nearestNotAvailibleDate = nearestDate
                }
            } else if difference > 0.0 {
                min = difference
                nearestDate = Date.init(timeIntervalSince1970: time)
                self.nearestNotAvailibleDate = nearestDate
            }
        }
        calendarView.reloadData()
        
    }
    
    func handleSelection(cell: JTAppleDayCellView?, cellState: CellState) {
        
            // Make sure you cache your colors.
            // Creating them on the fly like this example makes a laggy calendar
            let myCustomCell = cell as! CellView
            myCustomCell.isHidden = false
            myCustomCell.dayLabel.text = cellState.text
            myCustomCell.heightConstraint.constant = CGFloat(cellHeight)
            myCustomCell.widthConstraint.constant = CGFloat(cellHeight)
            myCustomCell.selectedView.clipsToBounds = true

            handleCellTextColor(view: cell, cellState: cellState)
            
            switch cellState.selectedPosition() {
            case .left, .right, .full, .middle:
                myCustomCell.selectedView.isHidden = false
                myCustomCell.notAvailible.isHidden = true
                
                myCustomCell.isUserInteractionEnabled = true
                myCustomCell.selectedView.backgroundColor = niceRed
                myCustomCell.selectedView.layer.cornerRadius = cellHeight / 2

            default:
                if testCalendar.isDateInToday(cellState.date) {
                    configureTodayDefault(cell: myCustomCell, cellState: cellState)
                } else {
                    myCustomCell.notAvailible.isHidden = true
                    myCustomCell.selectedView.layer.cornerRadius = 0
                    myCustomCell.selectedView.layer.borderWidth = 0
                    myCustomCell.isUserInteractionEnabled = true
                    myCustomCell.isHidden = false
                    myCustomCell.dayLabel.text = cellState.text
                    myCustomCell.dayLabel.textColor = niceRed
                    myCustomCell.selectedView.backgroundColor = UIColor.clear
                }
        }         // Have no selection when a cell is not selected
    }
    
    
    func configureNoAvailible(cell: JTAppleDayCellView?, cellState: CellState) {
        
        // This is how reserved or not availible cell will look like
        
        let myCustomCell = cell as! CellView
        myCustomCell.isHidden = false
        myCustomCell.dayLabel.text = cellState.text
        myCustomCell.heightConstraint.constant = CGFloat(cellHeight)
        myCustomCell.widthConstraint.constant = CGFloat(cellHeight)
        
        myCustomCell.selectedView.isHidden = true
        myCustomCell.dayLabel.textColor = UIColor.lightGray
        myCustomCell.notAvailible.isHidden = false
        myCustomCell.isUserInteractionEnabled = false
    }
    
    func configureTodayDefault(cell: JTAppleDayCellView?, cellState: CellState) {
        
        // Function to create date for today
        
        let myCustomCell = cell as! CellView
        myCustomCell.isHidden = false
        myCustomCell.dayLabel.text = cellState.text
        myCustomCell.heightConstraint.constant = CGFloat(cellHeight)
        myCustomCell.widthConstraint.constant = CGFloat(cellHeight)
        myCustomCell.selectedView.layer.cornerRadius = cellHeight / 2
        myCustomCell.selectedView.clipsToBounds = true
        myCustomCell.selectedView.isHidden = false
        
        
        switch cellState.selectedPosition() {
        case .left, .right, .full, .middle:
            myCustomCell.selectedView.backgroundColor = niceRed
            myCustomCell.notAvailible.isHidden = true
            myCustomCell.isUserInteractionEnabled = true
            
            myCustomCell.selectedView.layer.borderColor = niceRed.cgColor
            myCustomCell.selectedView.layer.borderWidth = 0
            myCustomCell.dayLabel.textColor = UIColor.white
            
        default:
        
            myCustomCell.selectedView.backgroundColor = UIColor.clear
            myCustomCell.notAvailible.isHidden = true
            myCustomCell.isUserInteractionEnabled = true
            
            myCustomCell.selectedView.layer.borderColor = niceRed.cgColor
            myCustomCell.selectedView.layer.borderWidth = 1
            myCustomCell.dayLabel.textColor = niceRed
           
        }
    }
    
    @IBAction func selectDates(_ sender: UIButton) {
        
        // Selected
    }
    
}

extension ViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, sectionHeaderSizeFor range: (start: Date, end: Date), belongingTo month: Int) -> CGSize {
        return CGSize(width: 50, height: 25)
    }
    
    
    // This setups the display of your header
    func calendar(_ calendar: JTAppleCalendarView, willDisplaySectionHeader header: JTAppleHeaderView, range: (start: Date, end: Date), identifier: String) {
        let headerCell = (header as? PinkSectionHeaderView)
        
        headerCell?.title.text = monthFormatter.string(from: range.start)
    }
    
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let startDate = formatter.date(from: "2017 02 01")! // You can use date generated from a formatter
        let endDate = formatter.date(from: "2018 03 01")! // You can also use dates created from this function
        let calendar = Calendar.current                     // Make sure you set this up to your time zone. We'll just use default here
        
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: 6,
                                                 calendar: calendar,
                                                 generateInDates: .forAllMonths,
                                                 generateOutDates: .off,
                                                 firstDayOfWeek: .monday)
        return parameters
    }
    

    
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {

        // Setup Cell text
        // Find if date is in array of our reserved nights
        
        let cellDate = formatter.string(from: date)
        let matchingTerms = noDates.filter({
            $0.range(of: cellDate, options: .caseInsensitive) != nil
        })
        
        if testCalendar.isDateInToday(date) {
            //Today date function
            configureTodayDefault(cell: cell, cellState: cellState)
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                handleCellTextColor(view: cell, cellState: cellState)
                handleSelection(cell: cell, cellState: cellState)
                
                if date < Date(){
                    configureNoAvailible(cell: cell, cellState: cellState)
                }
                
                if matchingTerms.isEmpty == false {
                    configureNoAvailible(cell: cell, cellState: cellState)
                }
                
                if nearestNotAvailibleDate != nil {
                    if date > nearestNotAvailibleDate! {
                        configureNoAvailible(cell: cell, cellState: cellState)
                    }
                }
                
            } else {
                let myCustomCell = cell as! CellView
                myCustomCell.isHidden = true
            }
        }

    }


    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        
        //Make unavailible dates after first reserved night and if selected date which is before selected it will remove last firstDate
        if firstDate != nil {
            if date < firstDate! {
                calendarView.deselectAllDates()
                calendarView.selectDates(from: date, to: date,  triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
                firstDate = date
                getNearestNotAvailibleDay(selectedDay: date)
            } else {
                calendarView.selectDates(from: firstDate!, to: date,  triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
                getNearestNotAvailibleDay(selectedDay: date)
                firstDate = nil
            }
        } else {
            calendarView.deselectAllDates()
            calendarView.selectDates(from: date, to: date,  triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
            firstDate = date
            getNearestNotAvailibleDay(selectedDay: date)
        }
        
        if testCalendar.isDateInToday(date) {
            configureTodayDefault(cell: cell, cellState: cellState)
        } else {
            handleCellTextColor(view: cell, cellState: cellState)
            handleSelection(cell: cell, cellState: cellState)
        }
        
        // Set title with selected dates
        
        let selectedDates = calendarView.selectedDates
        
        if firstDate == nil {
            self.selectedDatesLabel.text = "From \(selectedFormatter.string(from: selectedDates.first!)) - To \(selectedFormatter.string(from: selectedDates.last!))"
        } else {
            self.selectedDatesLabel.text = "\(selectedFormatter.string(from: selectedDates.first!))"
        }
    }

    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        nearestNotAvailibleDate = nil
        firstDate = nil
        calendarView.reloadData()
    }
    

    
}

extension UIColor {
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0){
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}







