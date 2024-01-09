//
//  HandDrawView.swift
//  HandDraw Demo
//
//  Created by 林仲景 on 2023/12/23.
//

import UIKit

protocol HandDrawViewProtocol:AnyObject {
    func closeHandDrawView()
}

class HandDrawView: UIView {


    @IBOutlet var contentView: UIView!
    
    @IBOutlet var drawImageView: UIImageView!
    
    @IBOutlet var cleanBtn: UIButton!
    @IBOutlet var nextBtn: UIButton!
    @IBOutlet var previousBtn: UIButton!
    @IBOutlet var colorWell: UIColorWell!

    
    weak var del:HandDrawViewProtocol?
    
    var penPoint:CGFloat = 5
    let panGesture = UIPanGestureRecognizer()
    let tapGesture = UITapGestureRecognizer()
    var previousPoint:CGPoint = CGPoint()
    var pointList:[CGPoint] = []
    var annotationIndex:Int = -1
    var pointDataList:[AnnotationPointData] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit(){
        //load Xib
        Bundle.main.loadNibNamed("HandDrawView", owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        //add gesture
        self.addGestureRecognizer(panGesture)
        self.addGestureRecognizer(tapGesture)
        panGesture.addTarget(self, action: #selector(triggerPanGesture))
        tapGesture.addTarget(self, action: #selector(triggerTapGesture(sender: )))
        
        updateUI()
    }
    
    func hideHandDrawView(){
        self.isHidden = true
    }
    
    func showHandDrawView(){
        self.isHidden = false
    }
    
    func drawAnnotation(currentIndex:Int? = nil){
        UIGraphicsBeginImageContextWithOptions(drawImageView.frame.size, false, 1)
        let context = UIGraphicsGetCurrentContext()!
        //draw exist line
        var drawPointDataList = pointDataList
        if let currentIndex{
            drawPointDataList = drawPointDataList.filter({ $0.index <= currentIndex })
        }
        for pointData in drawPointDataList{
            let path = UIBezierPath()
            for (index,point) in pointData.pointList.enumerated(){
                if index == 0{
                    path.move(to: point)
                }else{
                    path.addLine(to: point)
                }
            }
            context.addPath(path.cgPath)
            context.setLineWidth(pointData.penPoint)
            context.setStrokeColor(pointData.color?.cgColor ?? UIColor.black.cgColor)
            context.drawPath(using: .stroke)
        }
        
        //draw current line
        if !pointList.isEmpty{
            let path2 = UIBezierPath()
            path2.move(to: pointList.first!)
            for point in pointList{
                path2.addLine(to: point)
            }
            //先add，draw才有效果
            context.addPath(path2.cgPath)
            context.setLineWidth(penPoint)
            context.setStrokeColor(colorWell.selectedColor?.cgColor ?? UIColor.black.cgColor)
            context.drawPath(using: .stroke)
        }
        
        drawImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        print(drawImageView.image?.cgImage?.height)
        UIGraphicsEndImageContext()
    }
    
    
    func initDrawSetting(){
        pointList = []
        pointDataList = []
        annotationIndex = -1
        drawImageView.image = nil
        colorWell.selectedColor = nil
    }
    
    func updateUI(){
        updateNextPreviousBtnUI()
        updateCleanBtnUI()
    }
    
    func updateCleanBtnUI(){
        if pointDataList.isEmpty{
            cleanBtn.isEnabled = false
            cleanBtn.alpha = 0.5
        }else{
            cleanBtn.isEnabled = true
            cleanBtn.alpha = 1
        }
    }
    
    func updateNextPreviousBtnUI(){
        if pointDataList.isEmpty{
            nextBtn.alpha = 0.5
            nextBtn.isEnabled = false
            previousBtn.alpha = 0.5
            previousBtn.isEnabled = false
        }
        
        //nextBtn UI
        if annotationIndex < pointDataList.count-1{
            nextBtn.isEnabled = true
            nextBtn.alpha = 1
        }else if annotationIndex == pointDataList.count-1{
            nextBtn.alpha = 0.5
            nextBtn.isEnabled = false
        }
        //previousBtn UI
        if annotationIndex > -1{
            previousBtn.isEnabled = true
            previousBtn.alpha = 1
        }else if annotationIndex == -1{
            previousBtn.alpha = 0.5
            previousBtn.isEnabled = false
        }
        
    }
    
    func setAutolayout(view:UIView){
        NSLayoutConstraint.activate(
            [
             self.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             self.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
             self.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
             self.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            ]
        )
    }
    
    @IBAction func close(_ sender: Any) {
        initDrawSetting()
        penPoint = 5
        del?.closeHandDrawView()
        updateUI()
    }
    
    @IBAction func tap10PointPen(_ sender: Any) {
        penPoint = 10
    }
    
    @IBAction func tap5PointPen(_ sender: Any) {
        penPoint = 5
    }
    
    @IBAction func tap3PointPen(_ sender: Any) {
        penPoint = 3
    }
    
    @IBAction func tapNextBtn(_ sender: Any) {
        guard annotationIndex < pointDataList.count-1 else {return}
        self.annotationIndex += 1
        drawAnnotation(currentIndex: self.annotationIndex)
        updateUI()
    }
    
    
    @IBAction func tapPreviousBtn(_ sender: Any) {
        guard annotationIndex > -1 else {return}
        self.annotationIndex -= 1
        drawAnnotation(currentIndex: self.annotationIndex)
        updateUI()
    }
    
    
    @IBAction func tapClean(_ sender: Any) {
        initDrawSetting()
        updateUI()
    }
    
    
    
}

extension HandDrawView{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let currentPoint = touches.first?.location(in: drawImageView){
            pointList.append(currentPoint)
        }
    }
    
    @objc func triggerPanGesture(sender:UIPanGestureRecognizer){
        switch sender.state{
        case .began:
            if annotationIndex < pointDataList.count-1{
                pointDataList.removeAll { $0.index > annotationIndex }
            }
            let currentPoint = sender.location(in: drawImageView)
            annotationIndex += 1
            pointList.append(currentPoint)
        case .changed:
            let currentPoint = sender.location(in: drawImageView)
            pointList.append(currentPoint)
        case .ended:
            let pointData = AnnotationPointData(index: annotationIndex, pointList: pointList, penPoint: penPoint, color: colorWell.selectedColor)
            pointDataList.append(pointData)
            pointList = []  //clean drawing points
        default:
            break
        }
        drawAnnotation()
        updateUI()
    }
    
    @objc func triggerTapGesture(sender:UITapGestureRecognizer){
        pointList = []
    }
    
    
}
