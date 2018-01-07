# CutThai

if you find javascript library for Thai word segmentation in production. I **strongly** recommend [wordcut](https://github.com/veer66/wordcut) This repository is use for describe how Thai word segmentation work.

This work is base on document of [wordcut](https://github.com/veer66/wordcut) that you can found on [meduim](https://medium.com/@vsatayamas/wordcut-ภาคอธิบาย-d3b3a617e946#.7sfq26b7t) (Thai language)

## Algorithm

### 1. Find wordlist

this work is use Dictionary base you must have some Thai wordlist.
you can found some Thai wordlist from
- [LibThai](http://linux.thai.net/projects/libthai)
- [Thai National Corpus](http://www.arts.chula.ac.th/~ling/TNC/category.php?id=58&)

### 2. Build word Trie
convert wordlist from step 1 into trie to increase speed of searching.
read more about trie: [Wikipedia - Trie](https://en.wikipedia.org/wiki/Trie)
Note: This step is difference from [wordcut](https://github.com/veer66/wordcut), it using Binary search

### 3.Create wordgraph
Wordgraph is [graph](https://en.wikipedia.org/wiki/Graph_(discrete_mathematics)). use to determine position to word Segmentation where vertex is position to segmentation and Edge is word. create edge by compare input with trie.

### 4.Find shortest path
Find shortest path from start vertex to end vertex by using SPFA
read more about SPFA: [Wikipedia - SPFA](https://en.wikipedia.org/wiki/Shortest_Path_Faster_Algorithm)

### 5.Segmentation sentense to array
use shortest path from step 4 to segmentation sentense and convert to array


## Usage

CutThai isn't recommend to use in production. but you can download lastest release from [Releases](https://github.com/pureexe/cutthai/releases)

by using Node.js or CommonJS
``` javascript
var CutThai = require("cutthai")
```

by using normal browser
``` html
<script src="path/to/cutthai.min.js"></script>
```

run some segmentation
```  javascript
var cutthai = new CutThai(function(err){
  if(err){
    throw err;
  }
  console.log(cutthai.cut("ฉันกินข้าว"));
});
```

### Thank
[wordcut](https://github.com/veer66/wordcut) - for Algorithm to Thai word segmentaion
[LibThai](http://linux.thai.net/projects/libthai) - for Thai word dictionary

**Note:** This document isn't complete yet. need to improve gramma add more picture to describe Algorithm. add more instruction to build.
