//
//  BaseCollectionVC.swift
//  BrokerNewsModule
//
//  Created by Alexej Nenastev on 30/03/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

public typealias AnimatableCollectionDataSource<Item: IdentifiableType & Equatable> = RxCollectionViewSectionedAnimatedDataSource<DataSourceSection<Item>>

public final class AnimatableCollectionVC<Item: IdentifiableType & Equatable>: UIViewController, SceneView, UIScrollViewDelegate {
    
    public var disposeBag = DisposeBag()
    
    private var refreshControl: UIRefreshControl?
    public let collectionView: UICollectionView
    public let setConstraintsForCollectionViewManualy: Bool
    private var footerActivityIndicator = UIActivityIndicatorView(style: .gray)
    private let dataSource: AnimatableCollectionDataSource<Item>
    private let configurator: CollectionSceneConfigurator
    
    
    override public func loadView() {
        if setConstraintsForCollectionViewManualy {
            super.loadView()
        } else {
            self.view = collectionView
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        collectionView.allowsSelection = vm.canSelectItem
    }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        collectionView.reloadData()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for indexPath in collectionView.indexPathsForSelectedItems ?? [] {
            collectionView.deselectItem(at: indexPath, animated: animated)
        }
    }
    public convenience init(dataSource: AnimatableCollectionDataSource<Item>, configurator: CollectionSceneConfigurator) {
           self.init(dataSource: dataSource, configurator: configurator, setConstraintsForCollectionViewManualy: false)
       }
       
    public init(dataSource: AnimatableCollectionDataSource<Item>, configurator: CollectionSceneConfigurator, setConstraintsForCollectionViewManualy: Bool) {
        self.setConstraintsForCollectionViewManualy = setConstraintsForCollectionViewManualy
        self.dataSource = dataSource
        self.configurator = configurator
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: configurator.layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        if configurator.refreshControll {
            self.refreshControl = UIRefreshControl()
            if #available(iOS 10.0, *) {
                collectionView.refreshControl = refreshControl!
            } else {
                collectionView.addSubview(refreshControl!)
            }
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func bind(reactor: AnimatableCollectionReactor<Item>) {
        
        reactor.state
            .map { $0.sections }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        
        collectionView.rx.itemSelected
            .delay(configurator.selectedDelay, scheduler: MainScheduler.asyncInstance)
            .map(Reactor.Action.selected)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        if let delegate = configurator.scrollDelegate {
            collectionView.rx.setDelegate(delegate).disposed(by: disposeBag)
        }
        
        if let refresher = refreshControl {
            refresher.rx.controlEvent(.valueChanged).asObservable()
                .subscribe(onNext: { [weak self] in self?.fire(action: .loadData) })
                .disposed(by: disposeBag)
            
            bindState(\.inProgressRefreshLoading, to: refresher.rx.isRefreshing)
        }
        
        if reactor.canLoadMore {
            collectionView.rx.didScroll.subscribeNext(self, do: AnimatableCollectionVC<Item>.loadMoreIfNeed, bag: disposeBag)
            subscribeNext(reactor.state.map { $0.inProgressLoadMore }, with: AnimatableCollectionVC.setProgressMore)
        }
        
    }
    
    func setRefreshInProgress(inProgress: Bool) {
        if !inProgress && (refreshControl?.isRefreshing ?? false) { refreshControl?.endRefreshing() }
    }
    
    func setProgressMore(inProgressMore: Bool) {
        if inProgressMore { footerActivityIndicator.startAnimating() }
        else { footerActivityIndicator.stopAnimating() }
        
        footerActivityIndicator.isHidden = !inProgressMore
    }
    
    public func loadMoreIfNeed() {
        
        let scrollView = collectionView as UIScrollView
        
        if scrollView.contentSize.height < scrollView.frame.size.height { return }
        
        let currentOffset  = scrollView.contentOffset.y
        let maiximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset    = maiximumOffset - currentOffset
        
        if deltaOffset <= 0 {
            fire(action: .loadMore)
        }
    }
}
