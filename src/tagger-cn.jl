
export 标记


function tag_标记_lines(code::String,engine::结巴分词,FILESMODE::Bool,output)
    
    nlines = copy(engine.lines)
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
				
	    		tempresult = tag_标记_words(join(temparray),engine,FILESMODE)
	    		
	    		numfor = 0
	    		size_of_res = length(tempresult)/2
	    		while numfor < size_of_res
	    			numfor = numfor + 1
	    			print(outputopen,tempresult[numfor,1]);print(outputopen," ");println(outputopen,tempresult[numfor,2])
	    		end

	    		nlines = numlines
	    	end
	    finally
	    		close(fileopen)
	    		close(outputopen)
	    end
	    OUT = true
	    print("输出路径: $output")
	    return output

    else 
    	FILESMODE = false
    	result = Array(String,0)
    	try
	    	while nlines == engine.lines
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
	    		push!(result,tempresult)
	    		nlines = copy(numlines)
	    	end

    	finally
	    		close(fileopen)
	    end # end try

	    return result 
    end  # end if else
end




function tag_标记_words(code::String,engine::结巴分词,FILESMODE::Bool) 

	if engine.保留符号 == false
		code = replace(code,r"[^\u2e80-\u3000\u3021-\ufe4fa-zA-Z0-9]"=>" ")
    end
    
    tempvector = ccall(tag_vector_vector_result_key,Ptr{Nothing},(Ptr{Nothing},Ptr{UInt8}),engine.固定元素.引擎,pointer(code))
    
    sz = ccall(get_vector_vector_size_key,UInt32,(Ptr{Nothing},),tempvector)
    res_char = ccall(tagger_char_key,Ptr{Ptr{UInt8}},(Ptr{Nothing},),tempvector)
    res_tag  = ccall(tagger_tag_key,Ptr{Ptr{UInt8}},(Ptr{Nothing},),tempvector)

    temparray_char = Base.unsafe_wrap(Array,res_char,sz)
    temparray_tag = Base.unsafe_wrap(Array,res_tag,sz)
    result_char =  Array{String}(undef,sz)
    result_tag =  Array{String}(undef,sz)
    
    for num in 1:sz 
          result_char[num] = Base.unsafe_string(temparray_char[num])
          result_tag[num] = Base.unsafe_string(temparray_tag[num])
    end

    ccall(free_vector_vector_base_key,Nothing,(Ptr{Nothing},),tempvector)
    ccall(free_char_key,Nothing,(Ptr{Ptr{UInt8}},),res_char)
    ccall(free_char_key,Nothing,(Ptr{Ptr{UInt8}},),res_tag)

	if engine.保留符号 == false
		tempbool = .!(result_char .== " ")
		result_char = result_char[ tempbool ]
		result_tag  = result_tag[ tempbool ]
    end

    result = [result_char result_tag]

    return result
end # cut_words


function 标记(code::String,engine::结巴分词)
	
	if engine.固定元素.引擎类型 != "标记"
		error("""引擎类型不是 "标记".""")
	end

    if isfile(code) 
        if  engine.输出路径 == " "
        	base_names = replace(code, r"\.[^\.]*$","")
        	extnames   = replace(code, base_names, "")
        	output = string(base_names, ".segment", convert(Int,round(time())),extnames)
        else 
        	output = copy(engine.输出路径)
        end
        encoding = copy(engine.编码)

        if engine.检查编码==true
            code = transcode(code,encoding,engine.检查编码)
        end

        FILESMODE = true

        tag_标记_lines(code,engine,FILESMODE,output)
    else
    	FILESMODE = false

    	 return tag_标记_words(code,engine,FILESMODE)
    end

end # segment()

