#lang punct "../common.rkt"

---
title: Scheme implement models
date: 2023-12-09T00:00:00+00:00
---

此前一直对 Chez Scheme 的实现非常感兴趣，好奇为何其在众多的 scheme 实现中
性能一直领先。我从源代码编译 Chez 本身，编译速度惊人（1min 左右）。尤其对比 Gambit Scheme 实现，
其编译到 C 语言之后，也确实有着很不错的执行效率，但是编译速度堪忧，编译整个 Gambit 系统至少需要一个小时（在笔者的 Mac Pro 2019 上）。

读了 R. Kent Dybvig 的 paper [Three Implementation Models for Scheme]，
了解到 scheme 主流的三种实现模型，heap-based model, stack-based model, string-based model。

其中，heap-based model 被很多 scheme 实现所使用，优点是实现容易，其最大的缺点是内存占用会比较高，且由于 Environment
也是分配在 heap 上，导致变量的寻址也会占用不少的时间。此前大家基于 heap 来实现 Scheme 而不是使用大部分
计算机架构都支持的 "true stack" 来实现，是因为，Scheme 天然支持 first-class closure，first-class
continuation 等特性，而 Closure 的创建需要将环境也一同保存下来，很自然的如果 Enrionment 分配在 heap
上面，直接保存就可以，而基于 "true stack" 的话，需要考虑 copy stack frame，要知道 stack 里面的内容不止
有变量值还有控制信息。Dybvig 通过巧妙的改造，使得 "true stack" 也适用于 Scheme 的实现，这样极大的提高了内存的分配量以及执行速度，
因为可以使用操作 stack 的指令集。另外，该模型也会使用 heap，不过只有少部分情况，主要是涉及对于 first-class continuation
的支持 (需要拷贝栈内容到 closure) 。后续文章将会详细介绍 stack-based model，与大家分享，也希望错误的
理解能被纠正。

另外， [Three Implementation Models for Scheme] 的可读性非常高，Dybvig 的文笔读起来非常舒服。paper 里面的 [代码] 都是可以执行的，
有很多抽象机的实现，非常优雅和简洁。而这很大程度上是得益于 Scheme 代码即数据的优点。Enjoy!

[Three Implementation Models for Scheme]: https://citeseerx.ist.psu.edu/document?repid=rep1&type=pdf&doi=bc896e5336120b0f4ad00feb500cd7ce70134836
[代码]: https://github.com/evalwhen/dybvig-three-imp
