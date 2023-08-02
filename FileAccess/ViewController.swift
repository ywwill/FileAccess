//
//  ViewController.swift
//  FileAccess
//
//  Created by long on 2023/8/2.
//

import Cocoa
import PDFKit
import SnapKit

class ViewController: NSViewController {

    @IBOutlet weak var topView: NSStackView!
    
    // PDF 文件的 URL
    var fileURL: URL? {
        didSet {
            setupPDFView()
        }
    }
    
    lazy var pdfView: PDFView = {
        let pdf = PDFView(frame: view.frame)
        return pdf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    private func setupPDFView() {
        if let url = fileURL {
            
            _ = url.startAccessingSecurityScopedResource()
            
            // 检查是否有访问权限
            if FileManager.default.isReadableFile(atPath: url.path) {
                print("can access")
            }
            
            let pdfDocument = PDFDocument(url: url)
            pdfView.document = pdfDocument
            pdfView.autoScales = true
            pdfView.scaleFactor = 1.0
            
            view.addSubview(pdfView, positioned: .below, relativeTo: topView)
            pdfView.snp.makeConstraints { make in
                make.top.equalTo(topView.snp.bottom)
                make.left.right.bottom.equalToSuperview()
            }
            
            url.stopAccessingSecurityScopedResource()
        }
    }
    
    // MARK: 选择文件
    @IBAction func selectFileEvent(_ sender: Any) {
        let openFilePanel = NSOpenPanel()
        openFilePanel.allowedFileTypes = ["pdf"]
        openFilePanel.allowsMultipleSelection = false
        openFilePanel.canChooseFiles = true
        openFilePanel.canCreateDirectories = false
        openFilePanel.canChooseDirectories = false
        openFilePanel.begin { (response) in
            if response == .OK {
                if let url = openFilePanel.urls.first {
                    self.storeBookMark(url: url)
                    self.fileURL = url
                }
            }
        }
    }
    
    // MARK: 访问之前保存的文件
    @IBAction func readFileEvent(_ sender: Any) {
        loadBookMark()
    }
    
    // MARK: 保存 url bookmark
    private func storeBookMark(url: URL) {
        do {
            let urlData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
           
            UserDefaults.standard.set(urlData, forKey: "save_file_url")
        } catch {
            print(error)
        }
    }
    
    // MARK: 加载保存的文件 URL
    private func loadBookMark() {
        let urlData = UserDefaults.standard.object(forKey: "save_file_url") as! Data
        
        var isStale = false
        
        do {
            let restoredURL = try URL(resolvingBookmarkData: urlData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            
            if isStale {
                // 如果数据已过期，重新请求权限
                _ = restoredURL.startAccessingSecurityScopedResource()
            }
            
            fileURL = restoredURL
        } catch {
        }
    }
}

