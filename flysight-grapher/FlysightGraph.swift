//
//  FlysightGraph.swift
//  flysight-grapher
//
//  Created by richö butts on 9/5/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

import Charts

@objc protocol FlysightGraphDelegate {
    @objc optional func chartValueNoLongerSelected(_ chartView: FlysightGraph)
}


open class FlysightGraph: LineChartView {

    @objc weak var myChartViewDelegate: FlysightGraphDelegate?

    private var touchesMoved = false

    // Haptic Feedback
    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    private let selectionGenerator = UISelectionFeedbackGenerator()

    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // This is here to prevent the UITapGesture from blocking touches moved from firing
        if gestureRecognizer.isKind(of: NSUITapGestureRecognizer.classForCoder()){
            return false
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }

    override open func nsuiTouchesBegan(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?) {
        impactGenerator.impactOccurred()
        selectionGenerator.prepare()
        // adds the highlight to the graph when tapped
        super.nsuiTouchesBegan(touches, withEvent: event)
        touchesMoved = false
        if let touch = touches.first {
            let h = getHighlightByTouchPoint(touch.location(in: self))

            if h === nil || h == self.lastHighlighted {
                lastHighlighted = nil
                highlightValue(nil, callDelegate: true)
            }
            else {
                lastHighlighted = h
                highlightValue(h, callDelegate: true)
            }
        }
    }

    open override func nsuiTouchesEnded(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?) {
        super.nsuiTouchesEnded(touches, withEvent: event)
        myChartViewDelegate?.chartValueNoLongerSelected?(self) // remove the highlight
    }

    open override func nsuiTouchesCancelled(_ touches: Set<NSUITouch>?, withEvent event: NSUIEvent?) {
        super.nsuiTouchesCancelled(touches, withEvent: event)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // if a tap turns into a panGesture touches cancelled is called this prevents the highlight from being moved
            if !self.touchesMoved {
                self.myChartViewDelegate?.chartValueNoLongerSelected?(self)
            }
        }
    }

    override open func nsuiTouchesMoved(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?) {
        super.nsuiTouchesMoved(touches, withEvent: event)
        touchesMoved = true

        if let touch = touches.first {
            let h = getHighlightByTouchPoint(touch.location(in: self))

            if h === nil {
                lastHighlighted = nil
                highlightValue(nil, callDelegate: true)
            }
            else if h == self.lastHighlighted {
                return
            }
            else {
                lastHighlighted = h
                highlightValue(h, callDelegate: true)
                selectionGenerator.selectionChanged()
            }
        }
    }
}
