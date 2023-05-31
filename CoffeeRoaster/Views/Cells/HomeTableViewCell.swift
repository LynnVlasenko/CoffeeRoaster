//
//  GoodsTableViewCell.swift
//  CoffeeShop
//
//  Created by Алина Власенко on 08.05.2023.
//

import UIKit
import SkeletonView

class HomeTableViewCell: UITableViewCell {
    
    // cell identifier
    static let identifier = "HomeTableViewCell"

    // MARK: - UI Objects
    // image of good
    private let goodImage: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "logocoffee")
        img.layer.cornerRadius = 10
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    // name of good
    private let nameLbl: UILabel = {
        let label = UILabel()
        //label.text = передати в конфігурації дані з моделі name + surname
        label.font = UIFont.systemFont(ofSize: 22, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // cost of good
    private let costLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .thin)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        
        //
        isSkeletonable = true
        contentView.isSkeletonable = true
        goodImage.isSkeletonable = true
        nameLbl.isSkeletonable = true
        costLbl.isSkeletonable = true
        //
        
        addSubviews()
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Add subviews
    private func addSubviews() {
        contentView.addSubview(goodImage)
        contentView.addSubview(nameLbl)
        contentView.addSubview(costLbl)
    }
    
    // MARK: - Apply constraints
    private func applyConstraints() {
        let goodImageConstraints = [
            goodImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            goodImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            goodImage.widthAnchor.constraint(equalToConstant: 80),
            goodImage.heightAnchor.constraint(equalToConstant: 80)
        ]
        
        let nameLblConstraints = [
            nameLbl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            nameLbl.leadingAnchor.constraint(equalTo: goodImage.trailingAnchor, constant: 20),
            nameLbl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ]
        
        let costLblConstraints = [
            costLbl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            costLbl.leadingAnchor.constraint(equalTo: goodImage.trailingAnchor, constant: 20),
            costLbl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ]
        
        NSLayoutConstraint.activate(goodImageConstraints)
        NSLayoutConstraint.activate(nameLblConstraints)
        NSLayoutConstraint.activate(costLblConstraints)
    }
    
    //MARK: - Configure cell
    public func configure(with good: Good) {
        nameLbl.text = good.name
        costLbl.text = "\(good.cost) $"
        
        guard let photo = good.photo else {
            return
        }
        
        StorageManager.shared.downloadUrlForGood(path: photo) { url in
            guard let url = url else {
                return
            }
            let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data else {
                    return
                }
                DispatchQueue.main.async {
                    self.goodImage.image = UIImage(data: data)
                }
            }
            task.resume()
        }
    }
}
