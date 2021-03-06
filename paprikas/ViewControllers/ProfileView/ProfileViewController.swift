//
//  ProfileViewController.swift
//  paprikas
//
//  Created by 박소현 on 2021/01/04.
//

import UIKit

class ProfileViewController: BaseViewController {

    @IBOutlet weak var noContentLabel: UILabel!
    let presenter = ProfilePresenter(profileService: ProfileService())
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(view: self)
        self.noContentLabel.text = CONSTANT_KO.NO_CONTENT
    }
    @IBOutlet weak var profileCollectionView: UICollectionView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = false
        profileCollectionView.delegate = self
        profileCollectionView.dataSource = self
        presenter.loadProfileInfoData()
        presenter.loadProfileFeedData()
    }
    @objc func followOrSetBtnClicked(sender: Any) {
        presenter.followOrSetBtnAction()
    }
}
extension ProfileViewController: ProfileView {
    func setNocontentLabel(method: Bool) {
        self.noContentLabel.isHidden = method
    }

    func setProfileFeed() {
        self.profileCollectionView.reloadData()
    }

    func setProfileData(profileData: ProfileInfoDate) {
        self.navigationItem.title = profileData.user?.nickname
        self.profileCollectionView.reloadData()
    }
    func goToContentDetail(contentId: Int) {
        goToContentDetailVC(contentId: contentId)
    }

}
extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - Profile Header Methods

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CONSTANT_VC.PROFILE_HEADER_CELL, for: indexPath) as! ProfileHeaderCell
        presenter.configureHeader(headerView: headerView)
        let showFollowerTap = goToFollowTap(target: self, action: #selector(goToFollowVC(param:)))
        showFollowerTap.userId = headerView.tag
        showFollowerTap.isFollowing = false
        headerView.followerInfoView.addGestureRecognizer(showFollowerTap)

        let showFollowingTap = goToFollowTap(target: self, action: #selector(goToFollowVC(param:)))
        showFollowingTap.userId = headerView.tag
        showFollowingTap.isFollowing = true
        headerView.followingInfoView.addGestureRecognizer(showFollowingTap)

        headerView.followOrSettingBtn.addTarget(self, action: #selector(followOrSetBtnClicked(sender:)), for: .touchUpInside)
        return headerView
    }

    // MARK: - Profile Feed Methods

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = profileCollectionView.dequeueReusableCell(withReuseIdentifier: CONSTANT_VC.PROFILE_COLLECTION_FEED_CELL, for: indexPath) as! ProfileCollectionFeedCell
        presenter.configureCell(cell, forRowAt: indexPath)
        return cell
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        profileCollectionView.bounces = profileCollectionView.contentOffset.y > 0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectCollectionViewRowAt(indexPath: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width/3)-1
        let cellsize = CGSize(width: width, height: width)
        return cellsize
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfRows(in: section)
    }
}
