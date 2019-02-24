//
//  ViewController.swift
//  TsaChat1819
//
//  Created by Marro Gros Gabriel on 25/01/2019.
//  Copyright © 2019 Marro Gros Gabriel. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var bottomConstaint: NSLayoutConstraint!
    
    @IBOutlet weak var editingText: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    private var cloudKitHelper: CloudKitHelperProtocol?
    
    private var originalBottomConstraint: CGFloat = 0
    
    var context: NSManagedObjectContext!
    var fileUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cloudKitHelper = MeMessageHelper()
        originalBottomConstraint = bottomConstaint.constant
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAnimation(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAnimation(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        
        view.addGestureRecognizer(recognizer)
        
        editingText.text = ""
        editingText.layer.cornerRadius = 9.9


        
        sendButton.isEnabled = false
        
        
        
        startDownloading()
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
    }
    
    func startDownloading() {
        
        let date = UserDefaults.standard.value(forKey: MeMessageHelper.LastDateKey) as? Date
        cloudKitHelper?.downloadMessages(from: date, in: context) { [weak self] lastDate in
            if lastDate != nil {
                UserDefaults.standard.set(lastDate, forKey: MeMessageHelper.LastDateKey)
            }
            
            
            DispatchQueue.main.async {
                self?.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    @objc func refreshControlAction(_ sender: UIRefreshControl) {
        startDownloading()
    }
    
    @objc func tapAction(_ recognizer: UITapGestureRecognizer) {
        editingText.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollToBottom()
    }
    
    @objc func keyboardAnimation(_ notification: Notification) {
        let userInfo = notification.userInfo!
        
        let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect)
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        
        let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber
        
        let animationCurve = UIView.AnimationOptions(rawValue:curve.uintValue << 16)
        
        let height = view.bounds.size.height - convertedKeyboardEndFrame.origin.y
        
        bottomConstaint.constant = originalBottomConstraint - height
        
        UIView.animate(withDuration: animationDuration,
                       delay: 0.0,
                       options: [.beginFromCurrentState, animationCurve],
                       animations: {
                        self.view.layoutIfNeeded()
        }, completion: nil)
        
        scrollToBottom()
    }
    
    func scrollToBottom() {
        if let numSections = frc.sections?.count,
            numSections > 0,
            frc.sections![numSections-1].numberOfObjects > 0 {
            let num = frc.sections![numSections-1].numberOfObjects
            let lastIP = IndexPath(row:num-1, section:numSections-1)
            tableView.scrollToRow(at: lastIP, at: .bottom, animated: true)
        }
    }
    
    
    lazy var frc: NSFetchedResultsController<MEMessage>! = {
        
        let request = MEMessage.fetchRequest() as NSFetchRequest<MEMessage>
        let dateOrder = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [ dateOrder ]
        
        let _frc = NSFetchedResultsController(fetchRequest: request,
                                              managedObjectContext: context,
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
        
        _frc.delegate = self
        
        try? _frc.performFetch()
        
        return _frc
    }()
    
    @IBAction func sendAction(_ sender: Any) {
        
        guard !editingText.text.isEmpty else {
            sendButton.isEnabled = false
            return
        }
        
        cloudKitHelper?.sendMessage(editingText.text,
                                    in: context) { (done) in
                                        // nothing to do
        }
        
        editingText.text = ""
        sendButton.isEnabled = false
        editingText.resignFirstResponder()
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary;
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        var imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL
        if let resizedImage = image?.resizeRectImage(targetSize: CGSize(width: 400, height: 400)){
            imageUrl = saveImageLocally(image: resizedImage) as URL
        }
        
        if let fileUrl = imageUrl {
            
            cloudKitHelper?.sendImageMessage(fileUrl: fileUrl,
                                             in: context) { (done) in
                                                
            }
        }
       
        editingText.text = ""
        sendButton.isEnabled = false
        editingText.resignFirstResponder()
        dismiss(animated:true, completion: nil)
    }
}

private func saveImageLocally(image: UIImage) -> NSURL{
    let cacheDirectoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as NSString
    var imageURL: NSURL!
    let tempImageName = "temp_image.jpg"
    let imageData = image.pngData()! as NSData
    let path = cacheDirectoryPath.appendingPathComponent(tempImageName)
    imageURL = NSURL(fileURLWithPath: path)
    imageData.write(to: imageURL as URL, atomically: true)
    return imageURL
}

extension ViewController: UITextViewDelegate {
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        sendButton.isEnabled = textView.text.count > 0
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer:sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer:sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.endUpdates()
        
        scrollToBottom()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let section = frc.sections?.first {
            return section.numberOfObjects
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = frc.object(at: indexPath)        
        // MARK: - TO-DO user image
        
        return configureCell(message: message, tableView: tableView, indexPath: indexPath)
    }
    
    private func configureCell(message: MEMessage,tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let isUserCode = message.userCode == Constants.MY_USER_CODE
        let messageType = message.messageType
        var cellReturn = UITableViewCell()
        
        switch (messageType, isUserCode) {
        case (Constants.TEXT_MESSAGE_TYPE, true):
            cellReturn = getTextCell(message: message, tableView: tableView, indexPath: indexPath, identifier: Constants.RIGHT_TEXT_MESSAGE)
        case (Constants.IMAGE_MESSAGE_TYPE, true):
            cellReturn = getImageCell(message: message, tableView: tableView, indexPath: indexPath, identifier: Constants.RIGHT_IMAGE_MESSAGE)
        case (Constants.TEXT_MESSAGE_TYPE, false):
            cellReturn = getTextCell(message: message, tableView: tableView, indexPath: indexPath, identifier: Constants.LEFT_TEXT_MESSAGE)
        case (Constants.IMAGE_MESSAGE_TYPE, false):
            cellReturn = getImageCell(message: message, tableView: tableView, indexPath: indexPath, identifier: Constants.RIGHT_IMAGE_MESSAGE)
        default:
            debugPrint("Unexpected combination of message type and user ")        }
        return cellReturn
    }
    
    private func getImageCell(message: MEMessage, tableView: UITableView, indexPath: IndexPath, identifier: String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ImageMessageCell
           cell.imageMessage.image = UIImage(named: "image_placeholder")
        if let imageUrl = message.assetUrl {
            if let data = NSData(contentsOf: imageUrl){
                cell.imageMessage.image = UIImage(data: data as Data)
            }
        }
        return cell
    }
    
    private func getTextCell(message: MEMessage, tableView: UITableView, indexPath: IndexPath, identifier: String) -> UITableViewCell {
        let   cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MessageCell
        cell.messageText.text = message.text
        return cell
    }
    
}


