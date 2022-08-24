
export worker
#export worker_list # keep track of worker
export delete_worker

struct SegmentWorker_immupart
    worker::Ptr{Nothing}
    dict::String
    hmm::String
    user::String
    qmax::Int
    stop_words::String
    idf::String
    worker_type::String
    num::Int
end

Base.print(io::IO,x::SegmentWorker_immupart) = begin

  if x.worker_type == "mix" || x.worker_type == "tag" || x.worker_type == "mp" || x.worker_type == "keywords" || x.worker_type == "simhash" 
      print("dict_path : "); println(x.dict)
  end

  if x.worker_type == "mix" || x.worker_type == "tag" || x.worker_type == "hmm" || x.worker_type == "keywords" || x.worker_type == "simhash" 
      print("hmm_path  : "); println(x.hmm)
  end

  if x.worker_type == "mix" || x.worker_type == "tag" || x.worker_type == "mp" 
      print("user_path : "); println(x.user)
  end

  if x.worker_type == "query"
      print("qmax      : "); println(x.qmax)
  end

  if x.worker_type == "keywords" || x.worker_type == "simhash"
      print("stop_words: "); println(x.stop_words)
      print("idf_path  : "); println(x.idf)
  end

  print("worker_id : "); println(x.num)
end

Base.show(io::IO,x::SegmentWorker_immupart) = begin

  if x.worker_type == "mix" || x.worker_type == "tag" || x.worker_type == "mp" || x.worker_type == "keywords" || x.worker_type == "simhash" 
      print("dict_path : "); println(x.dict)
  end

  if x.worker_type == "mix" || x.worker_type == "tag" || x.worker_type == "hmm" || x.worker_type == "keywords" || x.worker_type == "simhash" 
      print("hmm_path  : "); println(x.hmm)
  end

  if x.worker_type == "mix" || x.worker_type == "tag" || x.worker_type == "mp" 
      print("user_path : "); println(x.user)
  end

  if x.worker_type == "query"
      print("qmax      : "); println(x.qmax)
  end

  if x.worker_type == "keywords" || x.worker_type == "simhash"
      print("stop_words: "); println(x.stop_words)
      print("idf_path  : "); println(x.idf)
  end

  print("worker_id : "); print(x.num)
end

mutable struct SegmentWorker
    private::SegmentWorker_immupart
    encoding::String
    detect::Bool
    symbol::Bool
    lines::Int
    output::String
    write::Bool
    topn::Int
    freed::Bool
end

Base.print(io::IO,x::SegmentWorker) = begin
  print("Worker Type     : "); println(x.private.worker_type)
  print("Default Encoding: "); println(x.encoding)
  print("Detect Encoding : "); println(x.detect)
  print("Keep Symbol     : "); println(x.symbol)
  print("Max Readlines   : "); println(x.lines)
  print("Output Path     : "); println(x.output)
  if x.private.worker_type == "keywords" || x.private.worker_type == "simhash"
      print("Keywords Numbers: "); println(x.topn)
  end
  print("Write File      : "); println(x.write);println("");
  println("Fix Settings    : "); println("");println(x.private);
end

Base.show(io::IO,x::SegmentWorker) = begin
  print("Worker Type     : "); println(x.private.worker_type)
  print("Default Encoding: "); println(x.encoding)
  print("Detect Encoding : "); println(x.detect)
  print("Keep Symbol     : "); println(x.symbol)
  print("Max Readlines   : "); println(x.lines)
  print("Output Path     : "); println(x.output)
  if x.private.worker_type == "keywords" || x.private.worker_type == "simhash"
      print("Keywords Numbers: "); println(x.topn)
  end
  print("Write File      : "); println(x.write);println("");
  println("Fix Settings    : "); println("");println(x.private);
end

Base.print(io::IO,x::Array{Union{Nothing,SegmentWorker},1}) = begin
  if length(x) == 0
    return 
  end
  for num in 1:length(x)
      println("Numbers : $num")
      println(x[num])
  end
end

Base.show(io::IO,x::Array{Union{Nothing,SegmentWorker},1}) = begin
  if length(x) == 0
    return 
  end
  for num in 1:length(x)
      println("Numbers : $num")
      println(x[num])
  end
end

global workerlist = Array{Union{SegmentWorker,Nothing}}(undef,0)
global workernum = 1

function worker(;worker_type = "mix", encoding = "UTF-8", lines = 100000,output = " ",detect = true, symbol = false,write_file = true, topn =5,dict = DICTPATH,hmm = HMMPATH,user = USERPATH,
                qmax = 20, stop_words = STOPPATH, idf = IDFPATH,workernum=Jieba.workernum,workerlist=Jieba.workerlist)
    
    
                _worker_immupart = SegmentWorker_immupart(
      
      if worker_type == "mix"
      ccall(mix_engine_key,Ptr{Nothing},(Ptr{UInt8},Ptr{UInt8},Ptr{UInt8}),
            pointer(dict),pointer(hmm),pointer(user))
      elseif worker_type == "mp"
      ccall(mp_engine_key,Ptr{Nothing},(Ptr{UInt8},Ptr{UInt8}),
      pointer(dict),pointer(user))
      elseif worker_type == "hmm"
      ccall(hmm_engine_key,Ptr{Nothing},(Ptr{UInt8},),
      pointer(hmm))
      elseif worker_type == "query"
      ccall(qu_engine_key,Ptr{Nothing},(Ptr{UInt8},Ptr{UInt8},Int),
      pointer(dict),pointer(hmm),qmax)
      elseif worker_type == "tag"
      ccall(tag_engine_key,Ptr{Nothing},(Ptr{UInt8},Ptr{UInt8},Ptr{UInt8}),
      pointer(dict),pointer(hmm),pointer(user))
      elseif worker_type == "keywords"
      ccall(key_engine_key,Ptr{Nothing},(Ptr{UInt8},Ptr{UInt8},Ptr{UInt8},Ptr{UInt8}),
      pointer(dict),pointer(hmm),pointer(idf),pointer(stop_words))
      elseif worker_type == "simhash"
      ccall(sim_engine_key,Ptr{Nothing},(Ptr{UInt8},Ptr{UInt8},Ptr{UInt8},Ptr{UInt8}),
      pointer(dict),pointer(hmm),pointer(idf),pointer(stop_words))
      end
      ,dict,hmm,user,qmax,stop_words,idf,worker_type,workernum
      )
    eval(quote
    	 global workernum = $workernum + 1
         end
    )
    
     _worker::Union{SegmentWorker,Nothing} = SegmentWorker(_worker_immupart,encoding,detect,symbol,lines,output,write_file,topn,false)

    push!(workerlist,_worker)
    return _worker
end


function delete_worker(engine::Union{SegmentWorker,Nothing})
	if( engine === nothing || engine.freed == true )
		return 
	end
    if engine.private.worker_type == "mix"
    ccall(free_mix_key,Nothing,(Ptr{Nothing},),engine.private.worker)
    elseif engine.private.worker_type == "mp"
    ccall(free_mp_key,Nothing,(Ptr{Nothing},),engine.private.worker)
    elseif engine.private.worker_type == "hmm"
    ccall(free_hmm_key,Nothing,(Ptr{Nothing},),engine.private.worker)
    elseif engine.private.worker_type == "query"
    ccall(free_qu_key,Nothing,(Ptr{Nothing},),engine.private.worker)  
    elseif engine.private.worker_type == "tag"
    ccall(free_tag_key,Nothing,(Ptr{Nothing},),engine.private.worker)  
    elseif engine.private.worker_type == "keywords"
    ccall(free_key_key,Nothing,(Ptr{Nothing},),engine.private.worker)  
    elseif engine.private.worker_type == "simhash"
    ccall(free_sim_key,Nothing,(Ptr{Nothing},),engine.private.worker)  
    end
    engine.freed = true
    workerlist[engine.private.num] = nothing
end

Base.eval(Main, :(function workspace()
	               if Jieba.workernum > 1
	                   for num in 1:(Jieba.workernum - 1)
	                   Jieba.delete_worker(Jieba.workerlist[num])
	                   end
                   end
                   if Jieba.引擎计数 > 1
	                   for num in 1:(Jieba.引擎计数 - 1)
	                   Jieba.删除引擎(Jieba.引擎列表[num])
	                   end
                   end                   
	            Base.workspace()
	         end
	               )
)
