//
//  ViewController.swift
//  CoffeeShop
//
//  Created by Алина Власенко on 08.05.2023.
//

import UIKit
import SkeletonView

class HomeVC: UIViewController {
    // Array for goods data
    private var goods: [Good] = []
    // Array for popular goods data
    private var popularGoods: [Good] = []
    // Array for search goods by name
    private var filteredGoods: [Good] = []
    
    private let sections = ["Popular Products","All Products"]
    // variable for hidden section
    private var firstSection = 0
    
    // MARK: - UI Objects
    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "Search"
        controller.searchBar.searchBarStyle = .minimal
        controller.searchBar.scopeButtonTitles = ["espresso", "filter", "omni"]
        return controller
    }()
    
    private let goodsTable: UITableView = {
        let table = UITableView()
        table.register(HomeTableViewCell.self,
                       forCellReuseIdentifier: HomeTableViewCell.identifier)
        table.register(PopularDoodsTableViewCell.self,
                       forCellReuseIdentifier: PopularDoodsTableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubview()
        configureNavBar()
        applyDelegates()
        fetchAllGoods()
        //checke theme
        SettingManager.shared.checkTheme()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        goodsTable.frame = view.bounds
    }
    
    
    //MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //goodsTable.isSkeletonable = true
        //goodsTable.showSkeleton(usingColor: .concrete, transition: .crossDissolve(0.25))
    }
    
    // MARK: - Add Subview
    private func addSubview() {
        view.addSubview(goodsTable)
    }
    
    // MARK: - Congifure nav bar
    private func configureNavBar() {
        // search controller
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        
        // bar buttun item group for sort by
        let editingGroup = UIBarButtonItemGroup.fixedGroup(
            // (! representativeItem image - is not displayed)
            representativeItem: UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3")),
            items: [
            UIBarButtonItem(title: "Sort by:", style: .done, target: self, action: .none),
            UIBarButtonItem(title: "Popular", style: .done, target: self, action: #selector(didTabSortByPopularButton)),
            UIBarButtonItem(title: "Less cost", style: .done, target: self, action: #selector(didTabSortByLessCostButton)),
            UIBarButtonItem(title: "More cost", style: .done, target: self, action: #selector(didTabSortByMoreCostButton))
        ]
        )
        navigationItem.centerItemGroups = [editingGroup]
    }
    
    // MARK: - Func for Sorting Action
    // sort by popular
    @objc private func didTabSortByPopularButton() {
        DispatchQueue.main.async {
            self.filteredGoods = self.goods.sorted { $0.rating > $1.rating }
            self.goodsTable.reloadData()
        }
    }
    // sort by less cost
    @objc private func didTabSortByLessCostButton() {
        DispatchQueue.main.async {
            self.filteredGoods = self.goods.sorted { $0.cost < $1.cost }
            self.goodsTable.reloadData()
        }
    }
    //sort by more cost
    @objc private func didTabSortByMoreCostButton() {
        DispatchQueue.main.async {
            self.filteredGoods = self.goods.sorted { $0.cost > $1.cost }
            self.goodsTable.reloadData()
        }
    }
    
    // MARK: - Private
    //func for fetch all goods
    private func fetchAllGoods() {
        DatabaseManager.shared.getAllGoods { [weak self] goods in
            self?.goods = goods
            self?.popularGoods = goods.sorted { $0.rating < $1.rating }.suffix(3).reversed()
            self?.filteredGoods = goods
            
            DispatchQueue.main.async {
                self?.goodsTable.reloadData()
            }
        }
    }
}


//MARK: - Skeleton ext
extension HomeVC: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return HomeTableViewCell.identifier
    }
}

// MARK: - Extension for Table
extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    //apply delegates for table
    private func applyDelegates() {
        goodsTable.delegate = self
        goodsTable.dataSource = self
    }
    // number of section
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    // title for section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    // will display header view
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        header.textLabel?.frame = CGRect(x: header.bounds.origin.x + 20,
                                         y: header.bounds.origin.y - 5,
                                         width: 300,
                                         height: header.bounds.height)
        if self.firstSection == 1 {
            if section == 0 {
                header.isHidden = true
            }
        } else {
                header.isHidden = false
        }
    }
    // number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return popularGoods.count
        } else {
            return filteredGoods.count
        }
    }
    // add cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
                
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: PopularDoodsTableViewCell.identifier,
                for: indexPath) as? PopularDoodsTableViewCell else { return UITableViewCell()}
            let good = popularGoods[indexPath.row]
            cell.configure(with: good)
            cell.backgroundColor = .secondarySystemBackground
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: HomeTableViewCell.identifier,
                for: indexPath) as? HomeTableViewCell else { return UITableViewCell()}
            let good = filteredGoods[indexPath.row]
            cell.configure(with: good)
            return cell
        }
        
    }
    // height for row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    // did select row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let vc = GoodDetailsVC()
            let goodData = popularGoods[indexPath.row]
            vc.setGood(good: goodData)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = GoodDetailsVC()
            let goodData = filteredGoods[indexPath.row]
            vc.setGood(good: goodData)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
// MARK: - Extension for searchBar
extension HomeVC: UISearchBarDelegate {
    // text Did Change
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            self.firstSection = 1
            self.popularGoods = []
            self.filteredGoods = self.goods.filter({ $0.name.contains(searchText) })
            DispatchQueue.main.async {
                self.goodsTable.reloadData()
            }
        } else {
            self.firstSection = 0
            self.popularGoods = self.goods.sorted { $0.rating < $1.rating }.suffix(3).reversed()
            self.filteredGoods = self.goods
            DispatchQueue.main.async {
                self.goodsTable.reloadData()
            }
        }
    }
    // selected Scope Button Index Did Change
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        // search "espresso", "filter", "omni"
        switch selectedScope {
        case 0:
            self.filteredGoods = self.goods.filter({ $0.type.contains("espresso") })
            DispatchQueue.main.async {
                self.goodsTable.reloadData()
            }
        case 1:
            self.filteredGoods = self.goods.filter({ $0.type.contains("filter") })
            DispatchQueue.main.async {
                self.goodsTable.reloadData()
            }
        case 2:
            self.filteredGoods = self.goods.filter({ $0.type.contains("omni") })
            DispatchQueue.main.async {
                self.goodsTable.reloadData()
            }
        default:
            self.filteredGoods = self.goods
            DispatchQueue.main.async {
                self.goodsTable.reloadData()
            }
        }
    }
    // search Bar Cancel Button Clicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.firstSection = 0
        self.popularGoods = self.goods.sorted { $0.rating < $1.rating }.suffix(3).reversed()
        self.filteredGoods = self.goods
        DispatchQueue.main.async {
            self.goodsTable.reloadData()
        }
    }
}
