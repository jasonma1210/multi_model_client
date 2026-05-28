//
//  ShareViewController.swift
//  LLM Studio Share Extension
//
//  处理从其他应用分享的内容
//

import UIKit
import Social
import MobileCoreServices
import UniformTypeIdentifiers

class ShareViewController: SLComposeServiceViewController {
    var sharedText: String?
    var sharedURL: String?

    override func isContentValid() -> Bool {
        return true
    }

    override func didSelectPost() {
        // 将分享内容传递给主应用
        if let text = sharedText ?? sharedURL {
            // 使用 App Group 在扩展和主应用之间共享数据
            if let userDefaults = UserDefaults(suiteName: "group.com.multimodel.client") {
                userDefaults.set(text, forKey: "sharedContent")
                userDefaults.synchronize()
            }
        }
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        return []
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        handleSharedContent()
    }

    private func handleSharedContent() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments else {
            return
        }

        for attachment in attachments {
            // 处理文本
            if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                attachment.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { [weak self] (item, error) in
                    if let text = item as? String {
                        DispatchQueue.main.async {
                            self?.sharedText = text
                            self?.textView.text = text
                        }
                    }
                }
            }

            // 处理 URL
            if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                attachment.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] (item, error) in
                    if let url = item as? URL {
                        DispatchQueue.main.async {
                            self?.sharedURL = url.absoluteString
                            if self?.textView.text.isEmpty == true {
                                self?.textView.text = url.absoluteString
                            }
                        }
                    }
                }
            }
        }
    }
}
