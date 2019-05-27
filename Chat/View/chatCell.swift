
import UIKit

class chatCell: UITableViewCell {
    
    
    let leftImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "jane1"))
        imageView.contentMode = .scaleAspectFill
        //imageView.layer.masksToBounds = false
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2
        return imageView
    }()
    
    let TopLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        return label
    }()
    
    let JobLabebl: UILabel = {
        let laebl = UILabel()
        laebl.text = "Job"
        //laebl.layer.borderWidth = 2
        return laebl
    }()
    
    lazy var views = [
        leftImageView
    ]

    let padding: CGFloat = 16
    let height: CGFloat = 80
   
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpLayout()
    }
    
    fileprivate func setUpLayout() {
        addSubview(leftImageView)
        leftImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: padding, left: padding, bottom: padding, right:0),size: .init(width: height, height: height))
        // leftImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3).isActive = true
        leftImageView.layer.cornerRadius = height/2
        let rightSV = UIStackView(arrangedSubviews: [TopLabel,JobLabebl])
        rightSV.axis = .vertical
        rightSV.spacing = padding
        rightSV.distribution = .fillEqually
        addSubview(rightSV)
        
        rightSV.anchor(top: topAnchor, leading: leftImageView.trailingAnchor, bottom: bottomAnchor, trailing: trailingAnchor,padding: .init(top: padding, left: padding, bottom: padding, right: padding))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
