//
//  CellView.swift
//  CalendarTutorial
//
//  Created by Jeron Thomas on 2016-10-15.
//  Copyright © 2016 OS-Tech. All rights reserved.
//

import JTAppleCalendar
class CellView: JTAppleDayCellView {
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var selectedView: UIView!

    @IBOutlet var notAvailible: UIView!
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    

}


