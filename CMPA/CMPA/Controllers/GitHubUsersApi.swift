//
//  GitHubUsersController.swift
//  CMPA
//
//  Created by Morten Liebmann Andersen on 17/09/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import Foundation
import RxSwift

enum Result<T, E: Error> {
    case success(T)
    case failure(E)
}

enum GitHubServiceError: Error {
    case offline
    case githubLimitReached
    case networkError
}

struct GitHubUsersApiController {
    var appClient = AppClient()
    func getUsers(by urlString: String) -> Observable<[User]> {
        guard let url = URL(string: urlString) else {
            return .empty()
        }
        
        return appClient.get(request: URLRequest(url: url))
    }
    
    func searchUsers(by query: String) -> Observable<GitHubResponse<User>> {
        guard let url = URL(string: "https://api.github.com/search/users?q=\(query)") else {
            return .empty()
        }
        
        return appClient.get(request: URLRequest(url: url))
    }
}
