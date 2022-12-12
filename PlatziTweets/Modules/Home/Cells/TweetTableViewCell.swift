//
//  TweetTableViewCell.swift
//  PlatziTweets
//
//  Created by Cesar Humberto Grifaldo Garcia on 11/11/22.
//

import UIKit
import Kingfisher

class TweetTableViewCell: UITableViewCell {
    
    //MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tweetImageView: UIImageView!
    @IBOutlet weak var tweetVideoButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    //MARK: - Actions
    //NOTA: Jamas mandar a llamar un viewcontroller en una celda
    @IBAction func openVideoAction(){
        guard let videoUrl = videoUrl else{
            return
        }
        
        needsToShowVideo?(videoUrl)
    }
    
    //MARK: - Properties
    private var videoUrl: URL?
    var needsToShowVideo: ((_ url: URL) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(post: TweetsGetResponse){
        tweetVideoButton.isHidden = !post.hasVideo
        nameLabel.text = post.author.names
        nicknameLabel.text = post.author.nickname
        messageLabel.text = post.text
        dateLabel.text = post.createdAt
        
        if post.hasImage {
            // configurar imagen
            tweetImageView.isHidden = false
            tweetImageView.kf.setImage(with: URL(string: post.imageUrl))
        } else {
            tweetImageView.isHidden = true
        }
        
        videoUrl = URL(string: post.videoUrl)
    }
    
}
