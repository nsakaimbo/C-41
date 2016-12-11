//
//  ASHTextFieldCell.swift
//  C-41
//
//  Created by Nicholas Sakaimbo on 12/11/16.
//  Copyright © 2016 Ash Furrow. All rights reserved.
//

import UIKit

class ASHTextFieldCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
