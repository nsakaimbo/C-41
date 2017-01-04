Porting Objective-C to Swift
====

The goal of this project was to develop a greater fluency with Objective-C and understanding Swift/Objective-C interoperability by migrating an existing Objective-C codebase to Swift. 

The candidate app is Ash Furrow's [C-41](https://itunes.apple.com/ca/app/c-41/id789924103?mt=8), an application to "help people develop film at home by providing a series of 'recipes' for photographers to use." It's a small enough app that it's easy enough to reason about, and in addition provides examples of what good MVVM architecture is supposed to look like (with some Reactive Cocoa thrown into the mix).

I've learned a lot about Objective-C and Swift interoperability through this project, including a better understanding of:

- [x] Setting up an Objective-C bridging header, and working with the automatically-generated Swift header file

- [x] Static vs dynamic libraries

- [x] Objective-C class extensions and categories

- [x] Objective-C properties and instance variables

- [x] How to make Objective-C enums more Swift-friendly

- [x] Translating Objective-C #define preprocessor macros to Swift (in this specific case, the `RAC` macro provided with ReactiveCocoa)

- [x] Swift interoperability with the Objective-C runtime (e.g. for Key-Value Observing, which ReactiveCocoa heavily relies on)

![Screenshot](https://raw.github.com/ashfurrow/C-41/master/screenshot.png)

Building 
----------------

If necessary, [update](http://guides.cocoapods.org/using/getting-started.html#updating-cocoapods) to the latest version of CocoaPods.

Clone the repository, then run `pod install`, opening the generated Xcode workspace. 


License
----------------

Licensed under MIT 'cause why not. 

Colour palette from [ColourLovers](http://www.colourlovers.com/palette/1916536/SUNSET_ANGELS).
