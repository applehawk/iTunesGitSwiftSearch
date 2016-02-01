//
//  SearchCellTableViewCell.swift
//  iTunesSearchSwift
//
//  Created by Hawk on 30/01/16.
//  Copyright © 2016 Hawk. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    @IBOutlet weak var title : UILabel?
    @IBOutlet weak var thumbnail : UIImageView?
    @IBOutlet weak var author : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
