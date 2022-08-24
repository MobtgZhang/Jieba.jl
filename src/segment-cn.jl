
export 分词

function cut_分词_lines(code::String,engine::结巴分词,FILESMODE::Bool,output)
    
    nlines = copy(engine.读取行数)
    fileopen = open(code,"r")

    if engine.写入文件== true
    	outputopen = open(output,"w")
	    
	    OUT = false
	    
	    try
	    	while nlines == engine.读取行数
	    		temparray = Array{String}(undef,engine.读取行数)
	            numlines = 0
	    		while numlines != nlines && !eof(fileopen)
	    		    numlines = numlines + 1
	    		    temparray[numlines] = readline(fileopen)
	    		end

			    # remove undefined
				numdefin = length(temparray)
				while !isdefined(temparray, numdefin)
					numdefin = numdefin - 1
				end
				temparray = temparray[1:numdefin]
				
	    		tempresult = cut_分词_words(join(temparray),engine,FILESMODE)
	    		
	    		for tempres in tempresult
	    			println(outputopen,tempres)
	    		end

	    		nlines = numlines
	    	end
	    finally
	    		close(fileopen)
	    		close(outputopen)
	    end
	    OUT = true
	    print("输出文件: $output")
	    return output

    else 
    	FILESMODE = false
    	result = Array(String,0)
    	try
	    	while nlines == engine.读取行数
	    		temparray = Array(String, engine.读取行数)
	            numlines = 0
	    		while numlines != nlines && !eof(fileopen)
	    		    numlines = numlines + 1
	    		    temparray[numlines] = readline(fileopen)
	    		end

			    # remove undefined
				numdefin = length(temparray)
				while !isdefined(temparray, numdefin)
					numdefin = numdefin - 1
				end
				temparray = temparray[1:numdefin]
				
	    		tempresult = cut_segment_words(join(temparray),engine,FILESMODE)
	    		result = [result,tempresult]
	    		nlines = copy(numlines)
	    	end

    	finally
	    	try
	    		close(fileopen)
			catch Exception
				
	    	end

	    end # end try

	    return result 
    end  # end if else
end




function cut_分词_words(code::String,engine::结巴分词,FILESMODE::Bool) 

	if engine.保留符号 == false
		code = replace(code,r"[^\u2e80-\u3000\u3021-\ufe4fa-zA-Z0-9]"=>" ")
    end
    
	if engine.固定元素.引擎类型 == "混合"
    tempvector = ccall(vector_result_key,Ptr{Nothing},(Ptr{Nothing},Ptr{UInt8}),engine.固定元素.引擎,pointer(code))
    elseif engine.固定元素.引擎类型 == "概率"
    tempvector = ccall(mp_vector_result_key,Ptr{Nothing},(Ptr{Nothing},Ptr{UInt8}),engine.固定元素.引擎,pointer(code))
    elseif engine.固定元素.引擎类型 == "hmm"
    tempvector = ccall(hmm_vector_result_key,Ptr{Nothing},(Ptr{Nothing},Ptr{UInt8}),engine.固定元素.引擎,pointer(code))
    elseif engine.固定元素.引擎类型 == "索引"
    tempvector = ccall(qu_vector_result_key,Ptr{Nothing},(Ptr{Nothing},Ptr{UInt8}),engine.固定元素.引擎,pointer(code)) 
    end
    
    sz = ccall(get_vector_size_key,UInt32,(Ptr{Nothing},),tempvector)
    res = ccall(result_key,Ptr{Ptr{UInt8}},(Ptr{Nothing},),tempvector)

    temparray = Base.unsafe_wrap(Array,res,sz)
    result =  Array{String}(undef,sz)
    
    for num in 1:sz 
          result[num] = Base.unsafe_string(temparray[num])
    end

    ccall(free_basev_key,Nothing,(Ptr{Nothing},),tempvector)
    ccall(free_char_key,Nothing,(Ptr{Ptr{UInt8}},),res)

	if engine.保留符号 == false
		result = result[ .!(result .== " ")]
    end

    return result
end # cut_words


function 分词(code::String,engine::结巴分词)
    if isfile(code) 
        if  engine.输出路径 == " "
        	base_names = replace(code, r"\.[^\.]*$","")
        	extnames   = replace(code, base_names, "")
        	output = string(base_names, ".segment", convert(Int,round(time())), extnames)
        else 
        	output = copy(engine.输出路径)
        end
        encoding = copy(engine.编码)

        if engine.检查编码==true
            code = transcode(code,encoding,engine.检查编码)
        end

        FILESMODE = true

        cut_分词_lines(code,engine,FILESMODE,output)
    else
    	FILESMODE = false

    	 return cut_分词_words(code,engine,FILESMODE)
    end

end # segment()

function <=(engine::结巴分词, code::String)
  if engine.固定元素.引擎类型 == "混合" || engine.固定元素.引擎类型 == "hmm" || engine.固定元素.引擎类型 == "概率" || engine.固定元素.引擎类型 == "索引"  
  	分词(code,engine)
  elseif engine.固定元素.引擎类型 == "标记"
  	标记(code,engine)
  elseif engine.固定元素.引擎类型 == "关键词"
 	关键词(code,engine)
  elseif engine.固定元素.引擎类型 == "simhash"
  	计算simhash(code,engine)
  else 
	print_str = @sprintf("%s",engine.private.worker_type)
	throw(string("Unknown engine: ",print_str))
  end 
end

