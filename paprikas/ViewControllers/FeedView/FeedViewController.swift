//
//  FeedViewController.swift
//  paprikas
//
//  Created by 박소현 on 2021/01/04.
//

import UIKit
import Alamofire
import Toast_Swift
import ImageSlideshow

class FeedViewController: BaseViewController {

    @IBOutlet weak var feedCollectionView: UICollectionView!
    @IBOutlet weak var noContentLabel: UILabel!

    let presenter = FeedPresenter(FeedService: FeedService())

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(view: self)

        feedCollectionView.delegate = self
        feedCollectionView.dataSource = self
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        feedCollectionView.refreshControl = refreshControl
        handleRefresh()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        print("FeedVC - viewWillAppear")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        print("FeedVC - viewWillDisappear")
    }
    // MARK: - selector Methods
    @objc func handleRefresh() {
        print("FeedVC - handleRefresh")
        presenter.refreshData()
    }

    @objc func likeBtnClicked(sender: UIButton) {
        sender.isSelected.toggle()
        presenter.sendLikeAction(isLike: sender.isSelected, index: sender.tag)
    }
}
extension FeedViewController: FeedView {
    func stopNetworking() {
        print("stop Feed networking")
        self.feedCollectionView.reloadData()
        self.feedCollectionView?.refreshControl?.endRefreshing()
    }

    func goToContentDetail(contentId: Int) {
        goToContentDetailVC(contentId: contentId)
    }
    func finUploadContent() {
        self.makeToast(message: NOTIFICATION.TOAST.UPLOAD_SUCCESS)
        handleRefresh()
        self.feedCollectionView.contentOffset.y = 0
    }
    func noContentLabelSet(method: Bool) {
        self.noContentLabel.isHidden = method
    }
}
extension FeedViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - collectionView Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfRows(in: section)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectCollectionViewRowAt(indexPath: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        let height = width + 255
        let cellsize = CGSize(width: width, height: height)
        return cellsize
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = feedCollectionView.dequeueReusableCell(withReuseIdentifier: CONSTANT_VC.FEED_COLLECTION_CELL, for: indexPath) as! FeedCollectionViewCell
        presenter.configureCell(cell, forRowAt: indexPath)
        cell.likeBtn.tag = indexPath.row
        cell.likeBtn.addTarget(self, action: #selector(likeBtnClicked(sender: )), for: .touchUpInside)

        let newCommentTap = goToCommentTap(target: self, action: #selector(goToCommentVC(param:)))
        newCommentTap.contentId = cell.tag
        newCommentTap.isWrite = true
        cell.commentBtn.addGestureRecognizer(newCommentTap)

        let showCommentTap = goToCommentTap(target: self, action: #selector(goToCommentVC(param:)))
        showCommentTap.contentId = cell.tag
        showCommentTap.isWrite = false
        cell.commentCountLabel.isUserInteractionEnabled = true
        cell.commentCountLabel.addGestureRecognizer(showCommentTap)

        let userProfileTap = goToProfileTap(target: self, action: #selector(goToProfileVC(param:)))
        userProfileTap.userId = cell.userDetailView.tag
        cell.userDetailView.isUserInteractionEnabled = true
        cell.userDetailView.addGestureRecognizer(userProfileTap)

        return cell
    }
}
