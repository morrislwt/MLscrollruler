//
//  RulerFramework.swift
//  ScrollRuler
//
//  Created by Morris on 2018/6/1.
//  Copyright © 2018年 Morris. All rights reserved.
//

import UIKit

extension Double {
    
    func floor(nearest: Double) -> Double {
        let number = Double(Int(self / nearest))
        return number * nearest
    }
}
protocol RulerDelegate: NSObjectProtocol {
    ///刻度尺代理方法
    func setupRuler(ruler: ScrollFrame,figure:Double)
}

class ScrollFrame: UIView,UIScrollViewDelegate{
    weak var delegate: RulerDelegate?
    
    var scrollView = UIScrollView()
    var middleLine = UIView()
    var rulerLine = CAShapeLayer()
    let lines = UIBezierPath()
    let layerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollView.delegate = self
        
        setupLayer()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        scrollView.addSubview(layerView)
        layerView.layer.addSublayer(rulerLine)
        addSubview(scrollView)
        addSubview(middleLine)

        
    }
    override func layoutSubviews() {
        super.layoutSubviews()

        scrollView.layer.cornerRadius = 10
        scrollView.contentSize = CGSize(width: 2800, height: 100)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.frame = bounds
        scrollView.bounces = true
        middleLine.frame = CGRect(x: scrollView.frame.width / 2, y: 0, width: 1, height: 20)
        layerView.frame = CGRect(x: scrollView.frame.width / 2, y: 0, width: scrollView.frame.width, height: 100)
        
    }
    func setupLayer(){
        let minKg = 0.0
        let maxKg = 100.1
        let interval = 0.5
        
        for kg in stride(from: minKg, to: maxKg, by: interval) {
            let isIntegar = floor(kg) == kg
            let height = (isIntegar) ? 20.0 : 10.0
            let oneLine = UIBezierPath()
            oneLine.move(to: CGPoint(x: kg * 25, y: 0))
            oneLine.addLine(to: CGPoint(x: kg * 25, y: height))
            lines.append(oneLine)
            
            if (isIntegar) {
                let label = UILabel(frame: CGRect(x: kg * 25, y: 0, width: 40, height: 21))
                label.center = CGPoint(x: kg * 25, y: height + 15)
                label.font = UIFont(name: "HelveticaNeue",size: 10.0)
                label.textAlignment = .center
                label.text = "\(kg)"
                layerView.addSubview(label)
            }
        }
        rulerLine.path = lines.cgPath
        rulerLine.lineWidth = 0.5
    }
    func closestOffset(){
        let x = Double(scrollView.contentOffset.x / 25)
        let closeToPoint5 = x.floor(nearest: 0.5)
        let point:CGPoint = CGPoint(x: closeToPoint5 * 25, y: 0.0)
        scrollView.setContentOffset(point, animated: true)
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        closestOffset()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        closestOffset()
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let x:Double = Double(scrollView.contentOffset.x / 25 + 0.5/25)
        let floorX = x.floor(nearest: 0.5)
        print(scrollView.contentOffset.x)
        var figure:Double = x.floor(nearest: 0.5)
        if floorX < 0 {
            figure = 0.0
        }else if floorX > 100 {
            figure = 100.0
        }
        guard floorX <= 100, floorX >= 0 else { return }
        delegate?.setupRuler(ruler: self,figure: figure)
    }
}


