//
//  GitHubService.swift
//  RxGithub
//
//  Created by Oron Ben Zvi on 2/21/17.
//  Copyright © 2017 Oron Ben Zvi. All rights reserved.
//

import RxSwift

enum GitHub {
    case userSearch(query: String, token: String)
    
    var url: String {
        switch self {
        case .userSearch(let query, let token):
            return "https://api.github.com/search/users?q=\(query)&access_token=\(token)"
        }
    }
}

protocol GitHubServicing {
    func userSearch(query: String) -> Observable<GitHubUserSearch>
}

class GitHubService: GitHubServicing {
    private let network: Networking
    
    init(network: Networking) {
        self.network = network
    }
    
    func userSearch(query: String) -> Observable<GitHubUserSearch> {
        let url = GitHub.userSearch(query: query, token: Keys.GitHubAccessToken).url
        return network.request(method: .get, url: url, parameters: nil, type: GitHubUserSearch.self)
    }
}
