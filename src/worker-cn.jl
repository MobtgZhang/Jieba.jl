export 分词初始化
export 引擎列表 # keep track of worker
export 删除引擎


struct 结巴分词固定元素
    引擎::Ptr{Nothing}
    词典目录::String
    模型目录::String
    用户词典目录::String
    最大索引长度::Int
    停止词目录::String
    IDF目录::String
    引擎类型::String
    编号::Int
end

Base.print(io::IO,x::结巴分词固定元素) = begin

  if x.引擎类型== "混合" || x.引擎类型== "标记" || x.引擎类型== "概率" || x.引擎类型== "关键词" || x.引擎类型== "simhash" 
      print("词典目录: "); println(x.词典目录)
  end

  if x.引擎类型== "混合" || x.引擎类型== "标记" || x.引擎类型== "hmm" || x.引擎类型== "关键词" || x.引擎类型== "simhash" 
      print("模型目录: "); println(x.模型目录)
  end

  if x.引擎类型== "混合" || x.引擎类型== "标记" || x.引擎类型== "概率" 
      print("用户词典目录: "); println(x.用户词典目录)
  end

  if x.引擎类型== "索引"
      print("最大索引长度: "); println(x.最大索引长度)
  end

  if x.引擎类型== "关键词" || x.引擎类型== "simhash"
      print("停止词目录: "); println(x.停止词目录)
      print("IDF目录: "); println(x.IDF目录)
  end

  print("编号: "); println(x.编号)
end

Base.show(io::IO,x::结巴分词固定元素) = begin


  if x.引擎类型== "混合" || x.引擎类型== "标记" || x.引擎类型== "概率" || x.引擎类型== "关键词" || x.引擎类型== "simhash" 
      print("词典目录: "); println(x.词典目录)
  end

  if x.引擎类型== "混合" || x.引擎类型== "标记" || x.引擎类型== "hmm" || x.引擎类型== "关键词" || x.引擎类型== "simhash" 
      print("模型目录: "); println(x.模型目录)
  end

  if x.引擎类型== "混合" || x.引擎类型== "标记" || x.引擎类型== "概率" 
      print("用户词典目录: "); println(x.用户词典目录)
  end

  if x.引擎类型== "索引"
      print("最大索引长度: "); println(x.最大索引长度)
  end

  if x.引擎类型== "关键词" || x.引擎类型== "simhash"
      print("停止词目录: "); println(x.停止词目录)
      print("IDF目录: "); println(x.IDF目录)
  end

  print("编号: "); println(x.编号)
end

mutable struct 结巴分词
    固定元素::结巴分词固定元素
    编码::String
    检查编码::Bool
    保留符号::Bool
    读取行数::Int
    输出路径::String
    写入文件::Bool
    关键词数::Int
    引擎状态::Bool
end

Base.print(io::IO,x::结巴分词) = begin
  print("引擎类型: "); println(x.固定元素.引擎类型)
  print("默认编码: "); println(x.编码)
  print("检查编码: "); println(x.检查编码)
  print("保留符号: "); println(x.保留符号)
  print("读取行数: "); println(x.读取行数)
  print("输出路径: "); println(x.输出路径)
  if x.固定元素.引擎类型== "关键词" || x.固定元素.引擎类型== "simhash"
      print("关键词数: "); println(x.关键词数)
  end
  print("写入文件: "); println(x.写入文件);println("");
  println("固定元素: "); println("");println(x.固定元素);
end

Base.show(io::IO,x::结巴分词) = begin
  print("引擎类型: "); println(x.固定元素.引擎类型)
  print("默认编码: "); println(x.编码)
  print("检查编码: "); println(x.检查编码)
  print("保留符号: "); println(x.保留符号)
  print("读取行数: "); println(x.读取行数)
  print("输出路径: "); println(x.输出路径)
  if x.固定元素.引擎类型== "关键词" || x.固定元素.引擎类型== "simhash"
      print("关键词数: "); println(x.关键词数)
  end
  print("写入文件: "); println(x.写入文件);println("");
  println("固定元素: "); println("");println(x.固定元素);
end

Base.print(io::IO,x::Array{Union{Nothing,结巴分词},1}) = begin
  if length(x) == 0
    return 
  end
  for 编号 in 1:length(x)
      println("编号: $编号")
      println(x[编号])
  end
end

Base.show(io::IO,x::Array{Union{Nothing,结巴分词},1}) = begin
  if length(x) == 0
    return 
  end
  for 编号 in 1:length(x)
      println("编号: $编号")
      println(x[编号])
  end
end

global 引擎列表 = Array{Union{结巴分词,Nothing}}(undef,0)
global 引擎计数 = 1

function 分词初始化(;引擎类型= "混合", 默认编码 = "UTF-8",读取行数 = 1000000, 检查编码 = true, 保留符号 = false,输出路径 = " ", 
                写入文件 = true, 关键词数 = 5, dict = DICTPATH,hmm = HMMPATH,user = USERPATH,
                最大索引长度 = 20, stop_words = STOPPATH, idf = IDFPATH,引擎计数=Jieba.引擎计数,引擎列表=Jieba.引擎列表)
    _worker_immupart = 结巴分词固定元素(
      
      if 引擎类型== "混合"
      ccall(mix_engine_key,Ptr{Nothing},(Ptr{UInt8},Ptr{UInt8},Ptr{UInt8}),
            pointer(dict),pointer(hmm),pointer(user))
      elseif 引擎类型== "概率"
      ccall(mp_engine_key,Ptr{Nothing},(Ptr{UInt8},Ptr{UInt8}),
      pointer(dict),pointer(user))
      elseif 引擎类型== "hmm"
      ccall(hmm_engine_key,Ptr{Nothing},(Ptr{UInt8},),
      pointer(hmm))
      elseif 引擎类型== "索引"
      ccall(qu_engine_key,Ptr{Nothing},(Ptr{UInt8},Ptr{UInt8},Int),
      pointer(dict),pointer(hmm),最大索引长度)
      elseif 引擎类型== "标记"
      ccall(tag_engine_key,Ptr{Nothing},(Ptr{UInt8},Ptr{UInt8},Ptr{UInt8}),
      pointer(dict),pointer(hmm),pointer(user))
      elseif 引擎类型== "关键词"
      ccall(key_engine_key,Ptr{Nothing},(Ptr{UInt8},Ptr{UInt8},Ptr{UInt8},Ptr{UInt8}),
      pointer(dict),pointer(hmm),pointer(idf),pointer(stop_words))
      elseif 引擎类型== "simhash"
      ccall(sim_engine_key,Ptr{Nothing},(Ptr{UInt8},Ptr{UInt8},Ptr{UInt8},Ptr{UInt8}),
      pointer(dict),pointer(hmm),pointer(idf),pointer(stop_words))
      end
      ,dict,hmm,user,最大索引长度,stop_words,idf,引擎类型,引擎计数
      )
    eval(quote
    	 global 引擎计数 = $引擎计数 + 1
         end
    )
    
    _worker::Union{结巴分词,Nothing} = 结巴分词(_worker_immupart,默认编码,检查编码,保留符号,读取行数,输出路径,写入文件,关键词数,false)

    push!(引擎列表,_worker)
    return _worker
end


function 删除引擎(engine::Union{结巴分词,Nothing})
	if( engine === nothing || engine.引擎状态 == true )
		return 
	end
    if engine.固定元素.引擎类型== "混合"
    ccall(free_mix_key,Nothing,(Ptr{Nothing},),engine.固定元素.引擎)
    elseif engine.固定元素.引擎类型== "概率"
    ccall(free_mp_key,Nothing,(Ptr{Nothing},),engine.固定元素.引擎)
    elseif engine.固定元素.引擎类型== "hmm"
    ccall(free_hmm_key,Nothing,(Ptr{Nothing},),engine.固定元素.引擎)
    elseif engine.固定元素.引擎类型== "索引"
    ccall(free_qu_key,Nothing,(Ptr{Nothing},),engine.固定元素.引擎)  
    elseif engine.固定元素.引擎类型== "标记"
    ccall(free_tag_key,Nothing,(Ptr{Nothing},),engine.固定元素.引擎)  
    elseif engine.固定元素.引擎类型== "关键词"
    ccall(free_key_key,Nothing,(Ptr{Nothing},),engine.固定元素.引擎)  
    elseif engine.固定元素.引擎类型== "simhash"
    ccall(free_sim_key,Nothing,(Ptr{Nothing},),engine.固定元素.引擎)  
    end
    engine.引擎状态  = true
    引擎列表[engine.固定元素.编号] = nothing
end

