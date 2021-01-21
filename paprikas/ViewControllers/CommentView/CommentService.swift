//
//  CommentService.swift
//  paprikas
//
//  Created by 박소현 on 2021/01/18.
//

import Foundation
import Alamofire
class CommentService {

    func requestCommentList(contentId: Int, whenIfFailed: @escaping (Error) -> Void, completionHandler: @escaping (CommentList) -> Void) {
        APIClient.getCommentList(contentId: contentId) { result in
            switch result {
            case .success(let commentResult):
                completionHandler(commentResult.data!)
            case .failure(let error):
                print("error : \(error.localizedDescription)")
                whenIfFailed(error)
            }
        }
    }

    func requestRemoveComment(commentId: Int, whenIfFailed: @escaping (Error) -> Void, completionHandler: @escaping (CommentResult) -> Void) {
        // 댓글 삭제 api
    }

    func requestNewComment(contentId: Int, whenIfFailed: @escaping (Error) -> Void, completionHandler: @escaping (CommentResult) -> Void) {
        // 댓글 추가 api
    }
}
protocol CommentView: class {
    func getKeyboard()
    func stopNetworking()
}
class CommentPresenter {
    var contentId: Int?
    var isWrite = false
    var comments: CommentList?
    private let CommentService: CommentService
    private weak var CommentView: CommentView?
    init(CommentService: CommentService) {
        self.CommentService = CommentService
    }
    func attachView(view: CommentView) {
        CommentView = view
    }
    func setContentConfig(contentId: Int, isWrite: Bool) {
        self.contentId = contentId
        self.isWrite = isWrite
    }
    func getIsWrite() -> Bool {
        return isWrite
    }
    func loadCommentData() {
        if let contentId = contentId {
            CommentService.requestCommentList(contentId: contentId, whenIfFailed: { error in
                print("error : \(error)")
            }, completionHandler: { commentList in
                self.comments = commentList
                self.CommentView?.stopNetworking()
            })
        }
    }
    func addNewComment() {
        if let contentId = contentId {
            // 통신 추가
            CommentService.requestNewComment(contentId: contentId, whenIfFailed: {
                _ in
                // 통신 실패
            }, completionHandler: { _ in
            // 통신 성공
                self.loadCommentData()
            })
        }
    }

    // MARK: - TableView Methods
    func numberOfRows(in section: Int) -> Int {
        return comments?.comment?.count ?? 0
    }

    func configureCell(_ cell: CommentTableViewCell, forRowAt indexPath: IndexPath) {
        let comment = comments?.comment?[indexPath.row]
        if let commentID = comment?.com?.commentid, let text = comment?.com?.text, let userID = comment?.user?.userid, let userNickname = comment?.user?.nickname, let userPhoto = comment?.user?.userphoto, let date = comment?.date, let isWriter = comment?.isWriter {
            cell.configureWith(commentID: commentID, text: text, userID: userID, userNickname: userNickname, userPhoto: userPhoto, date: date, isWriter: isWriter)
        }
    }
    func checkEditRow(_ cell: CommentTableViewCell, forRowAt indexPath: IndexPath) -> Bool {
        let comment = comments?.comment?[indexPath.row]
        return (comment?.isWriter)!
    }

    func removeCommentCell(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        if let commentId = comments?.comment?[indexPath.row].com?.commentid {
            CommentService.requestRemoveComment(commentId: commentId, whenIfFailed: { _ in
                // 통신 실패
            }, completionHandler: { _ in
                // 통신 성공

            })
            comments?.comment?.remove(at: commentId)
        }
        tableView.deleteRows(at: [indexPath], with: .left)
        tableView.endUpdates()
    }
}
