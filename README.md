# GVRefreshControl
The ```GVRefreshControl``` was built on top of ```UIRefreshControl``` in order to keep the users familiarity. The implementation is really close to the original ```UIRefreshControl``` implementation.

[![N|Solid](https://images.imgbox.com/1a/99/uqxmKrSJ_o.png)](https://github.com/gbrvalerio)

## Instalation
You can install using CocoaPods by adding the following line to your ```Podfile```:
```swift
pod 'GVRefreshControl'
```
After that, simply run ```pod update```.
## Usage
On this example we will build, by hand, the demo project. Don't worry, it's short! You can start by creating a new ```Single View Application``` project.
On the ```ViewController.swift``` file, start by importing the module:
```swift
import GVRefreshControl
```
The model we will use is just an ```String``` array. Right below, we can declare our ```GVRefreshControl``` and the view we want to display while the load is happening:
```swift
var model = ["0"]
let refreshControl = GVRefreshControl()
weak var refreshingView:UIView!
```
Also, we must conform to the ```GVRefreshControlDataSource``` in order to be able to customize even more our RefreshControl:
```swift
extension ViewController : GVRefreshControlDataSource {

  func refreshControlHeight(_ refreshControl:GVRefreshControl) -> CGFloat {
    return tableView.bounds.height / 3
  }

  func refreshControl(_ refreshControl:GVRefreshControl, viewBehaviourFor progress:CGFloat) -> GVRefreshControlViewBehaviour {
    return .fixedTop
  }

}
```
And then configure it:
```swift
private func configureRefreshControl() {
  refreshControl.addTarget(self, action: #selector(self.mustUpdateData(_:)), for: .valueChanged)
  refreshControl.dataSource = self
  if #available(iOS 10.0, *) {
    tableView.refreshControl = refreshControl
  } else {
    tableView.addSubview(refreshControl)
  }
}

private func configureRefreshView() {
  let vw = UIView()
  vw.backgroundColor = .red

  refreshControl.addSubview(vw)

  //I highly recommend that, if you use a container/content view or is just a view to show while refreshing, you should constrain it to it's superview, i. e., refreshControl.contentView.
  //Even though the GVRefreshControl is subclass of UIView, its methods for adding a subview were proxied to the contentView.
  vw.translatesAutoresizingMaskIntoConstraints = false
  vw.leftAnchor.constraint(equalTo: refreshControl.contentView!.leftAnchor).isActive = true
  vw.rightAnchor.constraint(equalTo: refreshControl.contentView!.rightAnchor).isActive = true
  vw.topAnchor.constraint(equalTo: refreshControl.contentView!.topAnchor).isActive = true
  vw.bottomAnchor.constraint(equalTo: refreshControl.contentView!.bottomAnchor).isActive = true

  refreshingView = vw
}

  //method called when the refreshControll is triggered by the user.
  //inherited from default UIRefreshControl implementation
@objc func mustUpdateData(_ sender:Any) {
  UIView.animate(withDuration: 3) {
    self.refreshingView.backgroundColor = self.refreshingView.backgroundColor == .red ? .blue : .red
  }
  DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    self.model.insert("\(self.model.count)", at: 0)
    //the "endRefreshing" method must be called by hand.
    //inherited from default UIRefreshControl implementation
    self.refreshControl.endRefreshing()
    self.tableView.reloadData()
  }
}
```
After configuring the ```UITableView``` you should have something like this:

![](https://github.com/gbrvalerio/GVRefreshControl/blob/master/Resources/GVRefreshControl-tut.gif?raw=true)

## View Behaviours
The following view behaviours are avaliable:
* ```.stretches```: on every ```UIScrollView``` notification of scrolling, it's applied a ```CGAffineTransform``` of scale ```x = 1.0```and ```y = max(visiblePercentage, 0.01)``` in order to make the view fill up all of the space avaliable.
* ```.fixedTop```: on every notification of scrolling the view position is updated to stay always on top and not to follow the content.
* ```.fixedBottom```: on every notification of scrolling the view position is updated to stay always on top of the content, following it consequently.

## Contributing
Feel free to send pull requests and ask anything that I will try to answer you.

## License
This project is under the MIT license.

## Story
This project was an accident. I was first trying to implement a ```UIRefreshControl``` on a table view and saw a lot of limitations that I, at time, supposed that could be fixed easily. Even though the math is not hard for this case, I challenged myself to implement a better refresh control on top of the existing one.
After some medium to advanced debugging and the-always-present-help of this [amazing headers](https://github.com/nst/iOS-Runtime-Headers) I could figure out some of the internal behaviour of the ```UIKit```'s ```UIRefreshControl``` and "forcibly override" some behaviours by exposing same signatures to ```obj-c``` and proxying some methods with help of the ```<objc/runtime.h>``` and ```<objc/message.h>``` libraries. The result was this framework. It's not perfect but is kind of more flexible and customizable than the original version.
