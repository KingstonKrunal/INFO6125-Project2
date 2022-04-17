//
//  ListEventCellTableViewCell.swift
//  INFO6125-Project2
//
//  Created by Krunal Shah on 2022-04-17.
//

import UIKit

class ListEventCellTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillCell(name: String, address: String, date: String) {
        nameLabel.text = name
        addressLabel.text = address
        dateLabel.text = date
    }

}
