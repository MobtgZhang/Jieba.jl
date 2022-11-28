# Jieba.jl



["结巴"中文分词]的 Julia 版本，支持最大概率法（Maximum Probability），隐式马尔科夫模型（Hidden Markov Model），索引模型（QuerySegment），混合模型（MixSegment），共四种分词模式，同时有词性标注，关键词提取，文本Simhash相似度比较等功能。项目使用了[CppJieba]进行开发。

Jieba.jl 的使用方法与 jiebaR 类似，如果你熟悉 jiebaR，应该可以很快上手。Jieba.jl 和 jiebaR 的分词速度是相近的，它们底层调用的都是 CppJieba。

本项目Julia Jieba库是基于v1.7.3版本，Julia标准库接口较为完善，在调用Julia库的时候基本没有问题。

## 特性
+ 支持 Linux，Mac，Windows 操作系统。
+ 支持多种分词模式、中文姓名识别、关键词提取、词性标注以及文本Simhash相似度比较等功能。
+ 支持加载自定义用户词库，设置词频、词性。
+ 同时支持简体中文、繁体中文分词。
+ 支持自动判断编码模式。
+ 安装简单，无需复杂设置。
+ 基于MIT协议。

你还可以试试在Julia里写中文 [Chinese.jl](https://github.com/qinwf/Chinese.jl)。

## 安装

可以通过Github安装,系统需要安装 gcc >= 4.6 或 Clang 编译包。在Windows 下请不要使用 Rtools 下的 MinGW，请使用 JuliaLang 官方推荐的 MinGW 版本：

```julia
Pkg.add(url="https://github.com/mobtgzhang/Jieba.jl.git")
Pkg.build("Jieba")

using Jieba
```

## 使用示例

### 分词

Julia.jl 提供了四种分词模式，可以通过`worker()` `初始化分词()` 来初始化分词引擎，使用`segment()` `分词()`进行分词。

```julia
using Jieba

##  接受默认参数，建立分词引擎

测试引擎 = 初始化分词()
#cutter = worker()
```

可以使用`segment()` `分词()` 函数，或者`<=`运算符号进行分词，julia.jl中未实现`[`分词符号。

```julia
测试引擎 <= "江州市长江大桥参加了长江大桥的通车仪式"   ### <= 分词运算符
```

```julia
["江州", "市长", "江大桥", "参加", "了", "长江大桥", "的", "通车", "仪式"]

```

支持对文件进行分词：

```julia
测试引擎 <= "./temp.dat"  ### 自动判断输入文件编码模式，默认文件输出在同目录下。

## segment( "./temp.dat" , cutter )
```

在加载分词引擎时，可以自定义词库路径，同时可以启动不同的引擎，不需要写完所有参数，提供与默认参数不同的参数即可：

```julia

分词初始化(引擎类型= "混合", 默认编码 = "UTF-8",读取行数 = 1000000, 检查编码 = true, 保留符号 = false,
           输出路径 = " ", 写入文件 = true, 关键词数 = 5, dict = DICTPATH,hmm = HMMPATH,user = USERPATH,
           最大索引长度 = 20, stop_words = STOPPATH, idf = IDFPATH) 

worker( worker_type = "mix", encoding = "UTF-8", lines = 100000, output = " ", detect = true, symbol = false,
        write_file = true, topn =5,dict = DICTPATH, hmm = HMMPATH, user = USERPATH, qmax = 20, stop_words = STOPPATH, idf = IDFPATH)

```

Julia.jl 提供了四种分词模式：

最大概率法（MPSegment），负责根据Trie树构建有向无环图和进行动态规划算法，是分词算法的核心。

隐式马尔科夫模型（HMMSegment）是根据基于人民日报等语料库构建的HMM模型来进行分词，主要算法思路是根据(B,E,M,S)四个状态来代表每个字的隐藏状态。 HMM模型由dict/hmm_model.utf8提供。分词算法即viterbi算法。

混合模型（MixSegment）是四个分词引擎里面分词效果较好的类，结它合使用最大概率法和隐式马尔科夫模型。

索引模型（QuerySegment）先使用混合模型进行切词，再对于切出来的较长的词，枚举句子中所有可能成词的情况，找出词库里存在。

可以通过`.` 符号重设一些`worker`的参数设置，如 ` WorkerName.symbol = true ` ` 引擎名.保留符号 = true `，在输出中保留标点符号。一些参数在初始化的时候已经确定，无法修改， 可以通过`WorkerName.private` `引擎名.固定元素`来获得这些信息。

```julia
cutter.encoding
测试引擎.编码

cutter.detect = false
测试引擎.保留符号 = false
```

可以自定义用户词库，推荐使用[深蓝词库转换]构建分词词库，它可以快速地将搜狗细胞词库等输入法词库转换为 Jieba.jl 的词库格式。

系统词典共有三列，第一列为词项，第二列为词频，第三列为词性标记。

用户词典有两列，第一列为词项，第二列为词性标记。用户词库默认词频为系统词库中的最大词频，如需自定义词频率，可将新词添加入系统词库中。

词典中的词性标记采用ictclas的标记方法。

### 词性标注
可以使用 `<=` 或者 `tagger()` 来进行分词和词性标注，词性标注使用混合模型模型分词，标注采用和 ictclas 兼容的标记法。

```julia
words  = "我爱北京天安门"
tagworker = worker("tag") # 测试引擎 = 初始化引擎("标记")
tagworker <= words
```

```julia
["江州" "ns"; "市长" "n"; "江大桥" "20000"; "参加" "v"; "了" "ul"; "长江大桥" "ns"; "的" "uj"; "通车" "n"; "仪式" "n"]
```

### 关键词提取
关键词提取所使用逆向文件频率（IDF）文本语料库可以切换成自定义语料库的路径，使用方法与分词类似。`topn`参数为关键词的个数。

```julia
keys = worker("keywords") # 测试引擎 = 初始化引擎("关键词")
keys.topn = 2  # 测试引擎.关键词数 = 2 
```

```julia
julia> keys.topn  # 测试引擎.关键词数
2
```

```julia
keys <= "我爱北京天安门"
# keys <= "一个文件路径.txt"
```

```julia
2x2 Array{Any,2}:
 "天安门"  8.9954
 "北京"   4.6674
```
### Simhash 与海明距离
对中文文档计算出对应的simhash值。simhash是谷歌用来进行文本去重的算法，现在广泛应用在文本处理中。Simhash引擎先进行分词和关键词提取，后计算Simhash值和海明距离，返回的类型为多元组。

```julia
simhasher = worker("simhash") # 测试引擎 = 初始化引擎("simhash")
simhasher.topn = 2 # 测试引擎.关键词数 = 2 
simhasher <= "江州市长江大桥参加了长江大桥的通车仪式"
```

 ```julia
(
2x2 Array{Any,2}:
 "长江大桥"  22.3853 
 "江州"     8.69667,

0xb2c6a622481d8eb2)

```

```julia
distance("江州市长江大桥参加了长江大桥的通车仪式" , "hello world!", simhasher) #海明距离(.....)
```

```julia
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
### 删除引擎

Julia 目前无法像 R 一样 `rm（）` 对象，只能将较大的对象用较小的对象替换。如果需要删除引擎，可以使用 `delete_worker（）` `删除引擎（）` 函数。通过 `show(Jieba.workerlist)` `show(Jieba.引擎列表)`可以获得所有初始化的引擎。

## 计划支持

+ 支持 Windows , Linux , Mac 操作系统并行分词。
+ 简单的自然语言统计分析功能。

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
Pkg.clone("https://github.com/seekasia/JiebaData.jl.git")
Pkg.clone("https://github.com/seekasia/Jieba.jl.git")
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

```julia
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

```julia
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

```julia
2x2 Array{Any,2}:
 "天安门"  8.9954
 "北京"   4.6674
```

### Simhash Distance
Simhash worker can do keyword extraction and find
the keywords from two inputs, and then computes Hamming distance between them.

 ```julia
(
2x2 Array{Any,2}:
 "长江大桥"  22.3853 
 "江州"     8.69667,

0xb2c6a622481d8eb2)

```

```julia
distance("江州市长江大桥参加了长江大桥的通车仪式" , "hello world!", simhasher)
```

```julia
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

[https://github.com/seekasia/Jieba.jl](https://github.com/seekasia/Jieba.jl)

["结巴"中文分词]:https://github.com/fxsjy/jieba
[Cppjieba]:https://github.com/aszxqw/cppjieba
[Rtools]:http://mirrors.xmu.edu.cn/CRAN/bin/windows/Rtools
[深蓝词库转换]:https://github.com/studyzy/imewlconverter
[imewlconverter]:https://github.com/studyzy/imewlconverter
