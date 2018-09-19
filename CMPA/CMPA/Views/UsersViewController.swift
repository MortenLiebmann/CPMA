//
//  ViewController.swift
//  CMPA
//
//  Created by Morten Liebmann Andersen on 17/09/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct Section {
    var Name: String
    var Item: [User]
}

class UsersViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var disposeBag = DisposeBag()
    
    let dict: [String: [User]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, User>>(
            configureCell: {(_, tv, indexPath, element) in
                let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel?.text = "\(element.UserLogin!)"
                return cell
        },
            titleForHeaderInSection: {dataSource, sectionIndex in
                return dataSource[sectionIndex].model
        }
        )
        
        let controller = GitHubUsersApiController()
        let users = searchBar.rx.text.orEmpty.asObservable()
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map {$0}
            .flatMap {query -> Observable<GitHubResponse<User>> in
                if query.isEmpty {
                    return .empty()
                }
                return controller.getUsers(by: query)
            }
            .map{ $0.Items ?? []}
            .map {users in
                return Dictionary(grouping: users, by: { $0.UserType! })
            }.map{users in
                users.map({ (key, users) -> SectionModel<String, User> in
                    return SectionModel(model: key, items: users)
                })}
        
        users
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(User.self)
            .subscribe { (event) in
                switch event {
                case .next(let user):
                    self.advanceToRepositories(with: user)
                    break
                default: break
                }
            }
            .disposed(by: disposeBag)
    }
    
    func advanceToRepositories(with user: User) {
        guard let storyboard = storyboard else { return }
        guard let vc = storyboard.instantiateViewController(withIdentifier: "RepositoriesView") as? RepositoriesViewController else { return }
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Segueing")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension UsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
}