//
//  ViewController.swift
//  test_JSQMessagesViewController
//
//  Created by 荒川陸 on 2016/03/11.
//  Copyright © 2016年 riku_arakawa. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ViewController: JSQMessagesViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var messages: [JSQMessage]?
    var photoItems : [JSQPhotoMediaItem]?
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var incomingAvatar: JSQMessagesAvatarImage!
    var outgoingAvatar: JSQMessagesAvatarImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //自分のsenderId, senderDisokayNameを設定
        self.senderId = "user1"
        self.senderDisplayName = "hoge"
        
        //吹き出しの設定
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.incomingBubble = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        self.outgoingBubble = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
        
        //アバターの設定
        self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "responder.png")!, diameter: 64)
        self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "sender.JPG")!, diameter: 64)
        
        //メッセージデータの配列を初期化
        self.messages = []
        //画像配列を初期化
        self.photoItems = []
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Sendボタンが押された時に呼ばれる
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        //新しいメッセージデータを追加する
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        self.messages?.append(message)
        
        //メッセージの送信処理を完了する(画面上にメッセージが表示される)
        self.finishReceivingMessageAnimated(true)
        
        //擬似的に自動でメッセージを受信
        self.receiveAutoMessage()
        
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        showAlert()
        NSLog("\(photoItems?.count)")
    }
    
    
    func showAlert(){
        //選択肢の上に表示するアラート
        let alert = UIAlertController(title: "画像の取得先を選択",message: nil, preferredStyle: .ActionSheet)
        //選択肢設定
        let firstAction = UIAlertAction(title: "カメラ", style: .Default){
            action in
            self.precentPickerController(.Camera)
        }
        let secondAction = UIAlertAction(title: "アルバム", style: .Default){
            action in
            self.precentPickerController(.PhotoLibrary)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Default,handler : nil)
        
        //選択肢をアラートに登録
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        alert.addAction(cancelAction)
        
        //アラートを表示
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func precentPickerController(sourceType:UIImagePickerControllerSourceType){
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            picker.delegate = self
            self.presentViewController(picker, animated:true, completion:nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: NSDictionary!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //写真をJSQPhotoMediaItemの型で配列に追加
        let photoItem = JSQPhotoMediaItem(image: image)
        photoItems?.append(photoItem)
        //新しいメッセージデータを追加する
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photoItems![photoItems!.count-1])
        self.messages?.append(message)
        
        //メッセージの送信処理を完了する(画面上にメッセージが表示される)
        self.finishReceivingMessageAnimated(true)
        
        //擬似的に自動でメッセージを受信
        self.receiveAutoMessage()
    }
    
    
    //アイテムごとに参照するメッセージデータを返す
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.messages?[indexPath.item]
    }
    
    //アイテムごとのMessageBubble(背景)を返す
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingBubble
        }
        return self.incomingBubble
    }
    
    //アイテムごとにアバター画像を返す
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingAvatar
        }
        return self.incomingAvatar
    }
    
    //アイテムの総数を返す
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.messages?.count)!
    }
    
    //返信メッセージを受信する
    func receiveAutoMessage() {
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "didFinishMessageTimer:", userInfo: nil, repeats: false)
    }
    
    func didFinishMessageTimer(sender: NSTimer) {
        let message = JSQMessage(senderId: "user2", displayName: "underscore", text: "Hello!")
        self.messages?.append(message)
        self.finishReceivingMessageAnimated(true)
    }
    
}