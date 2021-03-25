//
//  NoteCell.swift
//  UICollectionView-01
//
//  Created by Cheok Yan Cheng on 28/02/2021.
//

import UIKit

class NoteCell: UICollectionViewCell {

    private static let padding = CGFloat(8.0)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var smallLockImageView: UIImageView!
    @IBOutlet var micImageView: UIImageView!
    @IBOutlet var attachmentImageView: UIImageView!
    @IBOutlet var reminderImageView: UIImageView!
    @IBOutlet var pinImageView: UIImageView!
    
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet var labelLabel: UILabel!
    @IBOutlet var reminderLabel: UILabel!
    
    @IBOutlet var dateTimeContainer: UIView!
    @IBOutlet var dateTimeLabel: UILabel!
    
    @IBOutlet var topStackViewAndBodyLabelConstraint: NSLayoutConstraint!
    @IBOutlet var bodyLabelAndBottomStackViewConstraint: NSLayoutConstraint!
    @IBOutlet var bodyLabelAndBottomStackViewGreaterThanConstraint: NSLayoutConstraint!
    
    @IBOutlet var topStackViewZeroHeightConstraint: NSLayoutConstraint!
    @IBOutlet var titleLabelZeroHeightConstraint: NSLayoutConstraint!
    @IBOutlet var bodyLabelZeroHeightConstraint: NSLayoutConstraint!
    @IBOutlet var labelLabelZeroHeightConstraint: NSLayoutConstraint!
    @IBOutlet var reminderLabelZeroHeightConstraint: NSLayoutConstraint!
    @IBOutlet var bottomStackViewZeroHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // https://www.hackingwithswift.com/example-code/uikit/how-to-add-a-shadow-to-a-uiview
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.layer.shadowRadius = 2
        self.layer.masksToBounds = false
        //self.layer.shouldRasterize = true
        //self.layer.rasterizationScale = UIScreen.main.scale
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Get the most recent bounds in layoutSubviews.
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }
    
    func setup(_ plainNote: PlainNote) {
        titleLabel.text = plainNote.title
        
        smallLockImageView.isHidden = true
        micImageView.isHidden = false
        attachmentImageView.isHidden = true
        reminderImageView.isHidden = true
        if plainNote.pinned {
            pinImageView.isHidden = false
        } else {
            pinImageView.isHidden = true
        }
        
        bodyLabel.text = plainNote.body
        
        labelLabel.text = "Tag"
        reminderLabel.text = nil//"Sat"
        
        dateTimeLabel.text = "12 Feb 2019"
    }
    
    func updateLayout(_ layout: Layout) {
        switch layout {
        case .grid:
            updateGridLayout()
        case .compactGrid:
            updateCompactGridLayout()
        case .list:
            updateListLayout()
        case .compactList:
            updateCompactListLayout()
        }
    }
    
    private func updateGridLayout() {
        let isTitleLabelEmpty = String.isNullOrEmpty(titleLabel.text)
        let isBodyLabelEmpty = String.isNullOrEmpty(bodyLabel.text)
        let isLabelLabelEmpty = String.isNullOrEmpty(labelLabel.text)
        let isReminderLabelEmpty = String.isNullOrEmpty(reminderLabel.text)
        
        var titleLabelIsHidden = false
        var topStackViewIsHidden = false
        var bodyLabelIsHidden = false
        var labelLabelIsHidden = false
        var reminderLabelIsHidden = false
        var bottomStackViewIsHidden = false
        
        bodyLabelAndBottomStackViewConstraint.isActive = false
        bodyLabelAndBottomStackViewGreaterThanConstraint.isActive = true
        bodyLabel.numberOfLines = 0
        
        if isTitleLabelEmpty {
            titleLabelIsHidden = true
            titleLabelZeroHeightConstraint.isActive = true
        } else {
            titleLabelIsHidden = false
            titleLabelZeroHeightConstraint.isActive = false
        }
        
        if isBodyLabelEmpty {
            bodyLabelIsHidden = true
            bodyLabelZeroHeightConstraint.isActive = true
        } else {
            bodyLabelIsHidden = false
            bodyLabelZeroHeightConstraint.isActive = false
        }
        
        if isLabelLabelEmpty {
            labelLabelIsHidden = true
            labelLabelZeroHeightConstraint.isActive = true
        } else {
            labelLabelIsHidden = false
            labelLabelZeroHeightConstraint.isActive = false
        }
        
        if isReminderLabelEmpty {
            reminderLabelIsHidden = true
            reminderLabelZeroHeightConstraint.isActive = true
        } else {
            reminderLabelIsHidden = false
            reminderLabelZeroHeightConstraint.isActive = false
        }
      
        if titleLabelIsHidden && smallLockImageView.isHidden && micImageView.isHidden && attachmentImageView.isHidden && reminderImageView.isHidden && pinImageView.isHidden {
            topStackViewIsHidden = true
            topStackViewZeroHeightConstraint.isActive = true
        } else {
            topStackViewIsHidden = false
            topStackViewZeroHeightConstraint.isActive = false
        }
        
        dateTimeContainer.isHidden = true
        
        if labelLabelIsHidden && reminderLabelIsHidden {
            bottomStackViewIsHidden = true
            bottomStackViewZeroHeightConstraint.isActive = true
        } else {
            bottomStackViewIsHidden = false
            bottomStackViewZeroHeightConstraint.isActive = false
        }
   
        if topStackViewIsHidden || bodyLabelIsHidden {
            topStackViewAndBodyLabelConstraint.constant = 0
        } else {
            topStackViewAndBodyLabelConstraint.constant = NoteCell.padding
        }
        
        if bodyLabelIsHidden || bottomStackViewIsHidden {
            bodyLabelAndBottomStackViewConstraint.constant = 0
            bodyLabelAndBottomStackViewGreaterThanConstraint.constant = 0
        } else {
            bodyLabelAndBottomStackViewConstraint.constant = NoteCell.padding
            bodyLabelAndBottomStackViewGreaterThanConstraint.constant = NoteCell.padding
        }
        
        // We cannot have both 0 spacing when title and bottom stack view are visible.
        if topStackViewAndBodyLabelConstraint.constant == 0 && bodyLabelAndBottomStackViewConstraint.constant == 0 {
            if !topStackViewIsHidden && !bottomStackViewIsHidden {
                topStackViewAndBodyLabelConstraint.constant = NoteCell.padding
            }
        }
    }
    
    private func updateCompactGridLayout() {
        updateGridLayout()
    }
    
    private func updateListLayout() {       
        let isTitleLabelEmpty = String.isNullOrEmpty(titleLabel.text)
        let isBodyLabelEmpty = String.isNullOrEmpty(bodyLabel.text)
        let isLabelLabelEmpty = String.isNullOrEmpty(labelLabel.text)
        let isReminderLabelEmpty = String.isNullOrEmpty(reminderLabel.text)
        
        var titleLabelIsHidden = false
        var topStackViewIsHidden = false
        var bodyLabelIsHidden = false
        var labelLabelIsHidden = false
        var reminderLabelIsHidden = false
        var bottomStackViewIsHidden = false
        
        bodyLabelAndBottomStackViewConstraint.isActive = true
        bodyLabelAndBottomStackViewGreaterThanConstraint.isActive = false
        bodyLabel.numberOfLines = 0

        if isTitleLabelEmpty {          
            titleLabelIsHidden = true
            titleLabelZeroHeightConstraint.isActive = true
        } else {
            titleLabelIsHidden = false
            titleLabelZeroHeightConstraint.isActive = false
        }
        
        if isBodyLabelEmpty {           
            bodyLabelIsHidden = true
            bodyLabelZeroHeightConstraint.isActive = true
        } else {
            bodyLabelIsHidden = false
            bodyLabelZeroHeightConstraint.isActive = false
        }

        if isLabelLabelEmpty {
            labelLabelIsHidden = true
            labelLabelZeroHeightConstraint.isActive = true
        } else {         
            labelLabelIsHidden = false
            labelLabelZeroHeightConstraint.isActive = false
        }
        
        if isReminderLabelEmpty {           
            reminderLabelIsHidden = true
            reminderLabelZeroHeightConstraint.isActive = true
        } else {
            reminderLabelIsHidden = false
            reminderLabelZeroHeightConstraint.isActive = false
        }
        
        if titleLabelIsHidden && smallLockImageView.isHidden && micImageView.isHidden && attachmentImageView.isHidden && reminderImageView.isHidden && pinImageView.isHidden {
            topStackViewIsHidden = true
            topStackViewZeroHeightConstraint.isActive = true
        } else {
            topStackViewIsHidden = false
            topStackViewZeroHeightConstraint.isActive = false
        }
        
        dateTimeContainer.isHidden = false
        
        if labelLabelIsHidden && reminderLabelIsHidden {
            bottomStackViewIsHidden = true
            bottomStackViewZeroHeightConstraint.isActive = true
        } else {
            bottomStackViewIsHidden = false
            bottomStackViewZeroHeightConstraint.isActive = false
        }

        if topStackViewIsHidden || bodyLabelIsHidden {
            topStackViewAndBodyLabelConstraint.constant = 0
        } else {
            topStackViewAndBodyLabelConstraint.constant = NoteCell.padding
        }
        
        if bodyLabelIsHidden || bottomStackViewIsHidden {
            bodyLabelAndBottomStackViewConstraint.constant = 0
            bodyLabelAndBottomStackViewGreaterThanConstraint.constant = 0
        } else {
            bodyLabelAndBottomStackViewConstraint.constant = NoteCell.padding
            bodyLabelAndBottomStackViewGreaterThanConstraint.constant = NoteCell.padding
        }
        
        // We cannot have both 0 spacing when title and bottom stack view are visible.
        if topStackViewAndBodyLabelConstraint.constant == 0 && bodyLabelAndBottomStackViewConstraint.constant == 0 {
            if !topStackViewIsHidden && !bottomStackViewIsHidden {
                topStackViewAndBodyLabelConstraint.constant = NoteCell.padding
            }
        }
    }
    
    private func updateCompactListLayout() {
        let isTitleLabelEmpty = String.isNullOrEmpty(titleLabel.text)
        let isBodyLabelEmpty = String.isNullOrEmpty(bodyLabel.text)
        let isLabelLabelEmpty = String.isNullOrEmpty(labelLabel.text)
        let isReminderLabelEmpty = String.isNullOrEmpty(reminderLabel.text)
        
        var titleLabelIsHidden = false
        var topStackViewIsHidden = false
        var bodyLabelIsHidden = false
        var labelLabelIsHidden = false
        var reminderLabelIsHidden = false
        var bottomStackViewIsHidden = false
        
        bodyLabelAndBottomStackViewConstraint.isActive = true
        bodyLabelAndBottomStackViewGreaterThanConstraint.isActive = false
        bodyLabel.numberOfLines = 0

        if isTitleLabelEmpty {
            titleLabelIsHidden = true
            titleLabelZeroHeightConstraint.isActive = true
        } else {
            titleLabelIsHidden = false
            titleLabelZeroHeightConstraint.isActive = false
        }
        
        // In compact list, only either title or body can be shown.
        if isBodyLabelEmpty || !titleLabelIsHidden {
            bodyLabelIsHidden = true
            bodyLabelZeroHeightConstraint.isActive = true
        } else {
            bodyLabelIsHidden = false
            bodyLabelZeroHeightConstraint.isActive = false
        }

        if isLabelLabelEmpty {
            labelLabelIsHidden = true
            labelLabelZeroHeightConstraint.isActive = true
        } else {
            labelLabelIsHidden = false
            labelLabelZeroHeightConstraint.isActive = false
        }
        
        if isReminderLabelEmpty {
            reminderLabelIsHidden = true
            reminderLabelZeroHeightConstraint.isActive = true
        } else {
            reminderLabelIsHidden = false
            reminderLabelZeroHeightConstraint.isActive = false
        }
        
        dateTimeContainer.isHidden = false
        
        if titleLabelIsHidden && smallLockImageView.isHidden && micImageView.isHidden && attachmentImageView.isHidden && reminderImageView.isHidden && pinImageView.isHidden {
            topStackViewIsHidden = true
            topStackViewZeroHeightConstraint.isActive = true
        } else {
            topStackViewIsHidden = false
            topStackViewZeroHeightConstraint.isActive = false
        }
        
        if labelLabelIsHidden && reminderLabelIsHidden {
            bottomStackViewIsHidden = true
            bottomStackViewZeroHeightConstraint.isActive = true
        } else {
            bottomStackViewIsHidden = false
            bottomStackViewZeroHeightConstraint.isActive = false
        }

        if topStackViewIsHidden || bodyLabelIsHidden {
            topStackViewAndBodyLabelConstraint.constant = 0
        } else {
            topStackViewAndBodyLabelConstraint.constant = NoteCell.padding
        }
        
        if bodyLabelIsHidden || bottomStackViewIsHidden {
            bodyLabelAndBottomStackViewConstraint.constant = 0
            bodyLabelAndBottomStackViewGreaterThanConstraint.constant = 0
        } else {
            bodyLabelAndBottomStackViewConstraint.constant = NoteCell.padding
            bodyLabelAndBottomStackViewGreaterThanConstraint.constant = NoteCell.padding
        }
        
        // We cannot have both 0 spacing when title and bottom stack view are visible.
        if topStackViewAndBodyLabelConstraint.constant == 0 && bodyLabelAndBottomStackViewConstraint.constant == 0 {
            if !topStackViewIsHidden && !bottomStackViewIsHidden {
                topStackViewAndBodyLabelConstraint.constant = NoteCell.padding
            }
        }
    }
}
