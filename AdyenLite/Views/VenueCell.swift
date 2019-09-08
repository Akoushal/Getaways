//
//  VenueCell.swift
//  AdyenLite
//
//  Created by Koushal, KumarAjitesh on 2019/09/08.
//  Copyright © 2019 Koushal, KumarAjitesh. All rights reserved.
//

import UIKit
import SDWebImage

class VenueCell: UITableViewCell {
    
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        self.selectionStyle = .none
    }
    
    func configure(listObj: Venue) {
        guard let name = listObj.name,
            let category = listObj.mainCategory?.name,
            let address = listObj.location?.address,
            let city = listObj.location?.city,
            let country = listObj.location?.country,
            let imageURL = listObj.mainCategory?.iconImageURL,
            let url = URL(string: imageURL),
            let distance = listObj.location?.distance,
            let isOpen = listObj.isOpen
            else { return}
        nameLabel.text = name
        categoryLabel.text = category
        categoryImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "iconPlaceholder"))
        addressLabel.text = "\(address), \(city), \(country)"
        distanceLabel.text = "\(distance) meters"
        statusLabel.text = isOpen ? "Open" : "Closed"
        statusLabel.textColor = isOpen ? StatusColor.isOpened : StatusColor.isClosed
    }
}
