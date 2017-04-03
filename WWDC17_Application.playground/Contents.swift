//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport
import CoreGraphics
import XCPlayground


/*:
## What is a Heap?

A heap is a type of data stucture that can be displayed as a binary tree and stored in the form of an array.
 
Heaps are either min or max, meaning that the min (or max) value is stored at the root (first element) if the stucture.
 
![Heap Example](HeapExample.png)

The diagram above shows a max heap with the elements at each node and their index. On the left is the binary tree representation. On the right is the array stucture. 
 
 #### Note: For the purposes of this implmentation, this playground will user 0 as the root index.
 
*/


/*:
 
 ## Class: Heap
 
 We will use this class to help us create our heap.
 
 The class has an array of integers called `data` which contains the elements in out heap. It has fuctions that us to quickly do recursive insert and delete operations on the heap.
 
 It also gives us access to useful static methods to quickly access generic information relating to heap.
 
 
 
 
 */
public class Heap: NSObject, CustomPlaygroundQuickLookable {
    var data: [Int] = []
    
    /// Number of elements in heap
    var count: Int {
        get {
            return self.data.count
        }
    }
    
    /// The height of the heap. Can be found using ⌊lg(n)⌋
    var height: Int {
        get {
            return Int(floor(log2(Double(self.count))))
        }
    }
    
    /// Allows access to elements in the heap
    /// - parameter index: index of element to retrieve
    subscript(index:Int) -> Int {
        get {
            return data[index]
        }
    }
    
    override init() {
        super.init()
    }
    
    /// Inserts an element into the heap
    func insert(element: Int) {
        var d = self.data
        maxHeapInsert(element: element, into: &d)
        self.data = d
    }
    
    /// Removes the root element of the heap
    func popRoot() {
        var d = self.data
        popHeapRoot(heap: &d, isMaxHeap: true)
        self.data = d
    }
    
    /// Inserts an element into the heap preserving the max heap property
    private func maxHeapInsert(element: Int, into array: inout [Int]) {
        array.append(element) // add element to end of heap
        var i = array.count - 1 // get the index of the element we just added
        // finally we just have to swap the new element with it's parent until it's no longer smaller than it's parent
        while i > 0 && array[Heap.indexOfParent(forChildAtIndex: i)] < array[i] {
            let c = array[i]
            array[i] = array[Heap.indexOfParent(forChildAtIndex: i)]
            array[Heap.indexOfParent(forChildAtIndex: i)] = c
            i = Heap.indexOfParent(forChildAtIndex: i)
        }
    }
    
    /// Removes and returns the root element from a heap
    private func popHeapRoot(heap: inout[Int], isMaxHeap: Bool) -> Int {
        let root = heap[0] // save the root to return later
        heap[0] = heap[heap.count-1] // copy the last element to the root
        heap.removeLast() // remove the last element from the heap
        // heapify the heap depending on the kind
        if isMaxHeap {
            maxHeapify(heap: &heap, i: 0)
        } else {
            minHeapify(heap: &heap, i: 0)
        }
        return root // return the popped root
    }
    
    ///  Restores the max heap property in the array
    func maxHeapify(heap: inout[Int], i: Int) {
        let currentIndex = i // assumes the max heap property is not satified below this point
        let leftIndex = Heap.indexOfLeftChild(forParentAtIndex: currentIndex) // get the left child
        let rightIndex = Heap.indexOfRightChild(forParentAtIndex: currentIndex) // get the right child
        var largestIndex: Int!
        if leftIndex < heap.count && heap[leftIndex] > heap[currentIndex] { // if the left is larger than the current, the largest element is the left
            largestIndex = leftIndex
        } else {
            largestIndex = currentIndex // else the largest is the current
        }
        // now we have the largest between the left and current so compare it to the right
        if rightIndex < heap.count && heap[rightIndex] > heap[largestIndex] {
            largestIndex = rightIndex // if right is bigger than the current largest, make it the new largest
        }
        if largestIndex != currentIndex { // make sure the largest wasn't the current else we are done
            let currentElement = heap[currentIndex] // get the current element
            // now exchange the current element and the largest of it's 2 children
            heap[currentIndex] = heap[largestIndex]
            heap[largestIndex] = currentElement
            maxHeapify(heap: &heap, i: largestIndex) // perform recursivly until the heap is a valid max heap
        }
    }

    /// Restore the min heap property in the array
    func minHeapify(heap: inout[Int], i: Int) {
        // See `maxHeapify` for inline comments
        let currentIndex = i
        let leftIndex = Heap.indexOfLeftChild(forParentAtIndex: currentIndex)
        let rightIndex = Heap.indexOfRightChild(forParentAtIndex: currentIndex)
        var smallestIndex: Int!
        if leftIndex < heap.count && heap[leftIndex] < heap[currentIndex] {
            smallestIndex = leftIndex
        } else {
            smallestIndex = currentIndex
        }
        if rightIndex < heap.count && heap[rightIndex] < heap[smallestIndex] {
            smallestIndex = rightIndex
        }
        if smallestIndex != currentIndex {
            let currentElement = heap[currentIndex]
            heap[currentIndex] = heap[smallestIndex]
            heap[smallestIndex] = currentElement
            minHeapify(heap: &heap, i: smallestIndex)
        }
    }

    
    /// Get the index of the left child of the node at index
    static func indexOfLeftChild(forParentAtIndex index: Int) -> Int {
        return index*2+1
    }
    
    /// Get the index of the right child of the node at index
    static func indexOfRightChild(forParentAtIndex index: Int) -> Int {
        return index*2+1
    }
    
    /// Get the index of the right child of the node at index
    static func indexOfParent(forChildAtIndex index: Int) -> Int {
        return (index-1)/2
    }

    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return PlaygroundQuickLook(reflecting: self.data)
    }

    
    //
    ///
    // MARK: UI Rendering
    // Below are some specific methods we use in this playground to display the heap
    ///
    //
    
    let xSpacing: CGFloat = 20
    let ySpacing: CGFloat = 100
    var view = UIView()
    
    var width: CGFloat {
        get {
            return CGFloat(pow(2, Double(self.height+1)))*(xSpacing*3)
        }
    }
    
    func viewPointForNode(at index: Int, totalNodes: Int) -> CGPoint {
        view.backgroundColor = .white
        var xPos: CGFloat = 0.0
        var yPos: CGFloat = 50.0
        let parentIndex = Heap.indexOfParent(forChildAtIndex: index)
        let level = floor(log2(Double(index)+1.0))
        if view.subviews.count > parentIndex {
            let parentView = view.subviews[parentIndex]
            var xOffset: CGFloat = (index == Heap.indexOfLeftChild(forParentAtIndex: parentIndex) ? -xSpacing : xSpacing)
            xOffset = xOffset*CGFloat(pow(2, Double(height+1)-level))
            xPos = parentView.frame.origin.x + xOffset
            yPos = parentView.frame.origin.y + ySpacing
        } else {
            xPos = CGFloat(width)/2.0
        }
        return CGPoint(x: xPos, y: yPos)
    }
    
    public func previewView() -> UIView {
        guard count > 0 else {
            return view
        }
        for s in view.subviews {
            s.removeFromSuperview()
        }
        view =  UIView(frame: CGRect(x: 0, y: 0, width: Double(width), height: Double(height+1)*Double(ySpacing)+50))
        for i in 0...count-1 {
            let point = viewPointForNode(at: i, totalNodes: count)
            let nodeView = UILabel(frame: CGRect(x: point.x, y: point.y, width: 50, height: 50))
            nodeView.text = "\(data[i])"
            nodeView.layer.masksToBounds = true
            nodeView.layer.cornerRadius = 25
            nodeView.layer.borderWidth = 4
            nodeView.layer.borderColor = UIColor.blue.cgColor
            nodeView.textAlignment = .center
            nodeView.textColor = .blue
            nodeView.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightBold)
            view.addSubview(nodeView)
        }
        return view
    }
    
    public func quickLook() -> PlaygroundQuickLook {
        return PlaygroundQuickLook(reflecting: self.previewView())
        
    }

}

// Create the heap
var heap: Heap = Heap()
// fill the heap
let dataSource = [2,4,10,7,8,10,5,12,4]
for i in dataSource {
    heap.insert(element: i)
}

/// A class for interacting with the heap and visually displaying it.
public class InteractionResponder : NSObject {
    var submitButton: UIButton = {
       let b = UIButton(frame: CGRect(x: 0, y: 0, width: 260, height: 35))
        b.setTitle("GO!", for: .normal)
        b.setTitleColor(.blue, for: .normal)
        b.layer.borderColor = UIColor.blue.cgColor
        b.layer.borderWidth = 1.0
        b.layer.cornerRadius = 4
        b.layer.masksToBounds = true
        return b
    }()
    
    var stepperValueLabel: UILabel = {
        let l = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 35))
        return l
    }()
    
    var actionSegmentedControl: UISegmentedControl = {
        let s = UISegmentedControl(frame: CGRect(x: 0, y: 0, width: 300, height: 35))
        s.insertSegment(withTitle: "Heap Insert", at: 0, animated: false)
        s.insertSegment(withTitle: "Pop Root", at: 1, animated: false)
        return s
    }()
    
    var valueSteper: UIStepper = {
        let s = UIStepper()
        s.maximumValue = 99
        s.minimumValue = 0
        return s
    }()

    var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 40
        stackView.alignment = .top
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    var actionBar = UIStackView()
    
    var _heap: Heap = Heap()
    var heap: Heap {
        get {
           return _heap
        }
        set {
            _heap = newValue
            drawInteractionView()
        }
    }
    
    convenience init(heap: Heap) {
        self.init()
        self.heap = heap
        submitButton.addTarget(self, action: #selector(self.actionCommit), for: .touchUpInside)
        valueSteper.addTarget(self, action: #selector(self.stepperValueChanged(sender:)), for: .valueChanged)
        actionBar = UIStackView()
        actionBar.addArrangedSubview(actionSegmentedControl)
        actionBar.addArrangedSubview(stepperValueLabel)
        actionBar.addArrangedSubview(valueSteper)
        actionBar.addArrangedSubview(submitButton)
        actionBar.spacing = 20
        actionBar.distribution = .equalSpacing
        stackView.insertSubview(UIView(), at: 0)
        stackView.addArrangedSubview(actionBar)
        valueSteper.sendActions(for: .valueChanged)
    }
    
    override init() {
        super.init()
    }
    
    func drawInteractionView() {
        for s in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(s)
        }
        let heapView = heap.previewView()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: max(heapView.frame.width, actionBar.frame.width), height: heapView.frame.height))
        stackView.frame = view.frame
        stackView.addArrangedSubview(heapView)
        actionBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 60)
        stackView.sizeToFit()
        stackView.addArrangedSubview(actionBar)
        actionSegmentedControl.selectedSegmentIndex = 0
        view.addSubview(stackView)
        view.backgroundColor = .white
        view.sizeToFit()
        // sometimes the assistant editor viewer is buggy on the size. So you can see the full view above ⬆️
        // you can still use the controls in the assistant editor to interact with the heap.
        PlaygroundPage.current.liveView = view
        
    }

    func stepperValueChanged(sender: UIStepper) {
        let value = Int(sender.value)
        stepperValueLabel.text = "\(value)"
    }
    
    func actionCommit() {
        switch actionSegmentedControl.selectedSegmentIndex {
        case 0:
            guard let i = Int(stepperValueLabel.text ?? "") else {
                return
            }
            let h = heap
            h.insert(element: i)
            self.heap = h
            break
        case 1:
            guard heap.count > 0 else {return}
            let h = heap
            h.popRoot()
            heap = h
        default:
            break
        }
    }
}
let r = InteractionResponder(heap: heap)

r.drawInteractionView()


