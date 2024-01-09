//
//  ViewController.swift
//  HandDraw Demo
//
//  Created by 林仲景 on 2023/12/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var handDrawView: HandDrawView!
    @IBOutlet var handDrawBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handDrawView.del = self
        handDrawView.setAutolayout(view: self.view)
    }

  
    @IBAction func showHandDrawView(_ sender: Any) {
        handDrawView.showHandDrawView()
        handDrawBtn.isHidden = true
    }
    

}


extension ViewController:HandDrawViewProtocol{
    func closeHandDrawView() {
        handDrawView.hideHandDrawView()
        handDrawBtn.isHidden = false
    }
}


extension UIColor {
    convenience init(hex: String) {
        //去除非16進位字元
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        //因為16進位的顏色最大有32位元，所以用可以裝64位元的整數來裝，避免溢位
        var int = UInt64()
        //將int的記憶體位置傳入，scanHexInt64會把16進位的值轉換成10進位存在int這個記憶體位置
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        //根據hex的長度來決定rgb的每個顏色是幾bit
        //16進位的每個數字都是4 bit
        switch hex.count {
        case 3: // RGB (3 * 4 = 12-bit)，每個顏色佔4 bit
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (6 * 4 = 24-bit)，每個顏色佔8 bit
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (8 * 4 = 32-bit)，每個顏色佔8 bit
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

//0xF是四位元遮罩（0000 1111），可以保留低四位的值
//0xFF是1111 1111，用來當作遮罩,可以選擇出數字的某8個位元
/*
 &是位元 AND 運算:
 0101 0110 (一個 8 位元二進位數字)
 0000 1111 (遮罩 0xF)
 AND 運算
 0000 0110 (只保留低 4 位元)
 */

/*
 >>表示位移，>> 8表示向右位移八位
 原始數字: 10110110

 向右位移2位後: 00111011

 向左位移3位後: 11011000
 */
