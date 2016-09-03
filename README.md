# HybridSystem

HybridSystem是一个基于Swift的iOS项目，用于iOS原生和Web App的混合开发。

## 什么是HybridSystem，她能够做什么？
HybridSystem是在iOS中通过WebView去载入Web页面来实现开发的一种开发模式，使用者可以使用iOS的UIKit来给整个项目搭建基础框架，比如UINavigationController，UIToolbar等等，然后利用HybridWebViewController来载入Web页面，Web页面即可以处于本地，也可以放置于远程。同时iOS原生和WebView之间可以实现通信，已完成一些特定的功能。

## 为什么要用Hybrid？
尽管原生的项目基本上能够满足我们大部分的需求，且在用户体验上也要比Web或者Hybrid上会做的很好，但还是有一些情况下，使用Hybrid会给我们带来更好的开发效率。
#### 跨平台快速开发
当我们除了需要开发iOS版同时需要开发Android或者WindowPhone版本时，大部分的主要内容界面可以通过Web的方式进行开发，因此避免这些内容在多平台的重复开发。
#### 热更新
通过Web的方式来实现内容页面，即使不需要再次提交App Store，也可以实现大部分页面的Update或者Bug Fix。
#### 优秀的用户体验
尽管WebApp可以满足我们很多应用的日常场景，但在动效，特别是页面之间的互动上，有着根本性的缺陷，比如页面之间的切换，无论WebApp多优秀始终和原生App有着很大的差距，而Hybrid App可以通过调用系统框架来解决这个问题，使Hybrid App在界面切换的用户体验上和原生保持一致。除此之外，Web App的页面之间通讯也非常麻烦，对于Hybrid App来说只需要Register一个Handler既可完成，非常的方便。

## HybridSystem目前计划的功能
* 界面切换（Push * Pop、Present & Dismiss）[已完成]
* 注册Handler [施工中]
* 原生UIKit的界面风格修改 [已完成]
* UINavigationBar的Item添加设置 [施工中]
* 调用硬件功能（IAP、Touch ID、3D Touch等等）[施工中]

## HybridSystem使用手册

#### Xcode
施工中...

#### Web
施工中...
