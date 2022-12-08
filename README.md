# Jieba.jl

This is a package for Chinese text segmentation, keyword extraction
and speech tagging. `Jieba.jl` supports four
types of segmentation modes: Maximum Probability, Hidden Markov Model, Query Segment and Mix Segment.

## Features

+ Support Windows, Linux,and Mac.
+ Support Chinese text segmentation, keyword extraction, speech tagging and simhash computation.
+ Custom dictionary path.
+ Support simplified Chinese and traditional Chinese.
+ New words identification.
+ Auto encoding detection.
+ Fast text segmentation.
+ Easy installation.
+ MIT license.

## Installation

Install the latest development version from GitHub:

```julia
Pkg.add(url="https://github.com/mobtgzhang/Jieba.jl.git")
Pkg.build("Jieba")

using Jieba
```

## Example

### Text Segmentation

There are four segmentation models. You can use `worker()` to initialize a worker, and then use `<=` or `segment()` to do the segmentation.

```julia
using Jieba

##  Using default argument to initialize worker.
cutter = worker()

cutter <= "江州市长江大桥参加了长江大桥的通车仪式" 

```

```bash
9-element Array{UTF8String,1}:
 "江州"
 "市长"
 "江大桥" 
 "参加"
 "了" 
 "长江大桥"
 "的" 
 "通车" 
 "仪式" 
```

You can pipe a file path to cut file.

```julia
cutter <= "./temp.dat" 
```

The package uses initialized engines for word segmentation. You
can initialize multiple engines simultaneously.

```r
分词初始化(引擎类型= "混合", 默认编码 = "UTF-8",读取行数 = 1000000, 检查编码 = true, 保留符号 = false,
           输出路径 = " ", 写入文件 = true, 关键词数 = 5, dict = DICTPATH,hmm = HMMPATH,user = USERPATH,
           最大索引长度 = 20, stop_words = STOPPATH, idf = IDFPATH) 

worker( worker_type = "mix", encoding = "UTF-8", lines = 100000, output = " ", detect = true, symbol = false,
        write_file = true, topn =5,dict = DICTPATH, hmm = HMMPATH, user = USERPATH, qmax = 20, stop_words = STOPPATH, idf = IDFPATH)
```

The model public settings can be modified and got using `.` , such as ` WorkerName.symbol = true`. Some private settings are fixed when the engine is initialized, and you can get them by `WorkerName.private`.

```julia
cutter.encoding

cutter.detect = false
```

Users can specify their own custom dictionary to be included in the jiebaR default dictionary. jiebaR is able to identify new words, but adding your own new words can ensure a higher accuracy. [imewlconverter] is a good tools for dictionary construction.

There are three column in the system dictionary. The first column is the word, and the second column is the frequency of word. The third column is
speech tag using labels compatible with ictclas.

There are two column in the user dictionary. The first column is the word,
and the second column is speech tag using labels compatible with ictclas.
Frequency of every word in the user dictionary will be the maximum number of the system dictionary. If you want to provide the frequency for a new word, you can put it in the system dictionary.

### Speech Tagging
Speech Tagging function `<=` or `tagger()` uses speech tagging worker to cut word and tags each word after segmentation, using labels compatible with ictclas.  `dict` `hmm` and `user` should be provided when initializing `Jieba.jl` worker.

```julia
words  = "我爱北京天安门"
tagworker = worker("tag")
tagworker <= words
```

```bash
4x2 Array{UTF8String,2}:
 "我"    "r" 
 "爱"    "v" 
 "北京"   "ns"
 "天安门"  "ns"
```

### Keyword Extraction
Keyword Extraction worker use MixSegment model to cut word and use
 TF-IDF algorithm to find the keywords.  `dict`, `hmm`,
 `idf`, and `stop_word` should be provided when initializing  `Jieba.jl` worker.

```julia
keys = worker("keywords")
keys.topn = 2
```
```julia
julia> keys.topn
2
```

```julia
keys <= "我爱北京天安门"
# keys <= "一个文件路径.txt"
```

```bash
2x2 Array{Any,2}:
 "天安门"  8.9954
 "北京"   4.6674
```

### Simhash Distance
Simhash worker can do keyword extraction and find
the keywords from two inputs, and then computes Hamming distance between them.

 ```bash
(
2x2 Array{Any,2}:
 "长江大桥"  22.3853 
 "江州"     8.69667,

0xb2c6a622481d8eb2)

```

```julia
distance("江州市长江大桥参加了长江大桥的通车仪式" , "hello world!", simhasher)
```

```bash
((
2x2 Array{Any,2}:
 "长江大桥"  22.3853 
 "江州"     8.69667,

0xb2c6a622481d8eb2),(
2x2 Array{Any,2}:
 "hello"  11.7392
 "world"  11.7392,

0x2482942840042428),0x0000000000000017)

```

## Future Development

+ Support parallel programming on Windows , Linux , Mac.
+ Simple Natural Language Processing features.

## More Information and Issues
[https://github.com/qinwf/jiebaR](https://github.com/qinwf/jiebaR)

[https://github.com/aszxqw/cppjieba](https://github.com/aszxqw/cppjieba)

[https://github.com/mobtgzhang/Jieba.jl](https://github.com/mobtgzhang/Jieba.jl)

["结巴"中文分词]:https://github.com/fxsjy/jieba
[Cppjieba]:https://github.com/aszxqw/cppjieba
[Rtools]:http://mirrors.xmu.edu.cn/CRAN/bin/windows/Rtools
[深蓝词库转换]:https://github.com/studyzy/imewlconverter
[imewlconverter]:https://github.com/studyzy/imewlconverter
