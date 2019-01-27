//
//  SearchViewModel.swift
//  RxGithub
//
//  Created by Oron Ben Zvi on 2/21/17.
//  Copyright © 2017 Oron Ben Zvi. All rights reserved.
//

import RxSwift
import RxCocoa

protocol SearchViewModeling {

    // MARK: - Input
    var searchText: PublishSubject<String> { get }
    var selectedCellPosition: PublishSubject<Int> { get }

    // MARK: - Output
    var cellModels: Observable<[UserCellModeling]> { get }
    var resultCountLabel: Observable<String> { get }
    var selectedProfile: Observable<GitHubUser> { get }
}

class SearchViewModel: SearchViewModeling {

    // MARK: - Input
    let searchText: PublishSubject<String> = PublishSubject<String>()
    let selectedCellPosition: PublishSubject<Int> = PublishSubject<Int>()

    // MARK: - Output
    let cellModels: Observable<[UserCellModeling]>
    let resultCountLabel: Observable<String>
    let selectedProfile: Observable<GitHubUser>

    init(
            network: Networking,
            gitHubService: GitHubServicing,
            commentService: CommentServicing
    ) {

        let searchResults = searchText
                .throttle(0.3, scheduler: MainScheduler.instance)
                .distinctUntilChanged()
                .flatMapLatest { query in
                    gitHubService.userSearch(query: query).catchErrorJustReturn(GitHubUserSearch(count: 0, users: []))
                }
                .observeOn(MainScheduler.instance)
                .startWith(GitHubUserSearch(count: 0, users: []))
                .share(replay: 1)

        cellModels = searchResults.map { userSearch in
            userSearch.users.map { user in
                UserCellModel(
                        network: network,
                        imageUrl: user.avatarUrl,
                        username: user.username
                )
            }
        }

        resultCountLabel = searchResults.map {
            "\($0.users.count) result(s)"
        }

        selectedProfile = selectedCellPosition
                .withLatestFrom(searchResults) { cell, results in
                    (cell, results)
                }
                .map { cell, results in
                    results.users[cell]
                }
    }
}