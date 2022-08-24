
export 关键词

function key_关键词_lines(code::String,engine::结巴分词)
    
    # nlines = copy(engine.读取行数)
    fileopen = open(code,"r")

    	tempresult = Array{String}(undef,0)

    	try
    	  	temparray = readlines(fileopen)

    	  	if length(temparray) != 0
    		    tempresult = key_关键词_words(join(temparray),engine)
	    	end

    	finally
	    		close(fileopen)
	    end # end try

	    return tempresult
    # end  # end if else
end




function key_关键词_words(code::String,engine::结巴分词) 

	if engine.保留符号 == false
		code = replace(code,r"[^\u2e80-\u3000\u3021-\ufe4fa-zA-Z0-9]"=>" ")
    end
    topn = copy(engine.关键词数)
    tempvector = ccall(key_vector_num_result_key,Ptr{Nothing},(Ptr{Nothing},Ptr{UInt8},Int),engine.固定元素.引擎,pointer(code),topn)
    
    sz = ccall(get_vector_num_size_key,UInt32,(Ptr{Nothing},),tempvector)
    res_char = ccall(keyword_char_key,Ptr{Ptr{UInt8}},(Ptr{Nothing},),tempvector)
    res_num  = ccall(keyword_num_key,Ptr{Float64},(Ptr{Nothing},),tempvector)

    temparray_char = Base.unsafe_wrap(Array,res_char,sz)
    temparray_num = Base.unsafe_wrap(Array,res_num,sz)
    result_char =  Array{String}(undef,sz)
    result_num = Array{Float64}(undef,sz)
    
    for num in 1:sz 
          result_char[num] = Base.unsafe_string(temparray_char[num])
          result_num[num] = temparray_num[num]
    end

    ccall(free_vector_num_base_key,Nothing,(Ptr{Nothing},),tempvector)
    ccall(free_char_key,Nothing,(Ptr{Ptr{UInt8}},),res_char)
    ccall(free_num_p_key,Nothing,(Ptr{Float64},),res_num)

	if engine.保留符号 == false
		tempbool = .!(result_char .== " ")
		result_char = result_char[ tempbool ]
		result_num  = result_num[ tempbool ]
    end

    result = [result_char result_num]

    return result
end # cut_words

function 关键词(code::String,engine::结巴分词)
	
	if engine.固定元素.引擎类型 != "关键词"
		error("""引擎类型不是 "关键词".""")
	end

    if isfile(code) 

        encoding = copy(engine.编码)

        if engine.检查编码==true
            code = transcode(code,encoding,engine.检查编码)
        end

        key_关键词_lines(code,engine)
    else

    	 return key_关键词_words(code,engine)
    end

end # segment()

