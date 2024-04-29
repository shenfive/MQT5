//
//  MQ.swift
//  
//
//  Created by 申潤五 on 2024/4/24.
//

import UIKit
import CoreImage
import SwiftUI

open class NTQRobject: NSObject {
    private override init() {}
    public static func getUIImage(_ string:String,_ correctionLevel:String = "H") -> (UIImage?,String) {
        let plistName = "NCCCQR"
        var format = PropertyListSerialization.PropertyListFormat.xml // Format of the Property List.
        var plistData: [String: AnyObject] = [:]  // Our data
        let plistPath: String? = Bundle.main.path(forResource: plistName, ofType: "plist")! // the path of the data
        let plistXML = FileManager.default.contents(atPath: plistPath!)!
        do { // convert the data to a dictionary and handle errors.
            plistData = try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &format) as! [String:AnyObject]
        } catch {
            print("Error reading plist: \(error), format: \(format)")
        }
        
        guard let setData = plistData as? Dictionary<String, Any> else{
            return (nil,"API Key 無法讀取")
        }
        
        print(setData)
        
        let apiKey = setData["QRAPIKey"] as? String ?? ""
        
        if !checkAPIKey(key: apiKey){
            return (nil,"API Key 無效")
        }
        let theString = "{\"APIKey\":\"\(apiKey)\",\"userData\":\"\(string)\"}"
        let data = theString.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            
            filter.setValue(correctionLevel, forKey: "inputCorrectionLevel")
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return (UIImage(data:UIImage(ciImage: output).pngData() ?? Data()),"成功")
            }else{
                return (nil,"字串編碼失敗")
            }
        }else{
            return (nil,"字串編碼失敗")
        }
    }
    

    @available(iOS 13.0, *)
    public static func getSwiftUIImage(_ string:String,_ correctionLevel:String = "H") -> (Image?,String) {
        let value = getUIImage(string, correctionLevel)
        if let uiimage = value.0{
            return (Image(uiImage: uiimage),value.1)
        }else{
            return (nil,value.1)
        }
    }
    
    
    private static func checkAPIKey(key:String) -> Bool{
        
        return key.count > 0
    }
    
}

