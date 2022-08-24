
export simhash
export ham_distance

function simhash_segment_lines(code::String,engine::SegmentWorker)
    
    # nlines = copy(engine.lines)
    fileopen = open(code,"r")

    	tempresult = Array{String}(undef,0)

    	try
            temparray = readlines(fileopen)

    	  	if length(temparray) != 0
    		    tempresult = simhash_segment_words(join(temparray),engine)
	    	end

    	finally
	    		close(fileopen)
	    end # end try

	    return tempresult
    # end  # end if else
end




function simhash_segment_words(code::String,engine::SegmentWorker) 

	if engine.symbol == false
		code = replace(code,r"[^\u2e80-\u3000\u3021-\ufe4fa-zA-Z0-9]"=>" ")
    end
    topn = copy(engine.topn)
    tempvector = ccall(sim_vector_num_result_key,Ptr{Nothing},(Ptr{Nothing},Ptr{UInt8},Int),engine.private.worker,pointer(code),topn)
    
    sz = ccall(get_vector_num_size_key,UInt32,(Ptr{Nothing},),tempvector)
    res_char = ccall(keyword_char_key,Ptr{Ptr{UInt8}},(Ptr{Nothing},),tempvector)
    res_num  = ccall(keyword_num_key,Ptr{Float64},(Ptr{Nothing},),tempvector)
    res_hash = ccall(simhasher_res_key,Culonglong,(Ptr{Nothing},),tempvector)

    temparray_char = Base.unsafe_wrap(Array,res_char,sz)
    temparray_num = Base.unsafe_wrap(Array,res_num,sz)
    result_char =  Array{String}(undef,sz)
    result_num = Array{Float64}(undef,sz)
    
    for num in 1:sz 
          result_char[num] = Base.unsafe_string(temparray_char[num])
          result_num[num] = copy(temparray_num[num])
    end

    ccall(free_vector_num_base_key,Nothing,(Ptr{Nothing},),tempvector)
    ccall(free_char_key,Nothing,(Ptr{Ptr{UInt8}},),res_char)
    ccall(free_num_p_key,Nothing,(Ptr{Float64},),res_num)

	if engine.symbol == false
		tempbool = .!(result_char .== " ")
		result_char = result_char[ tempbool ]
		result_num  = result_num[ tempbool ]
    end

    result = ([result_char result_num],res_hash)

    return result
end # cut_words

function simhash(code::String,engine::SegmentWorker)
	
	if engine.private.worker_type != "simhash"
		error("""worker's type is not "simhash".""")
	end

    if isfile(code) 

        encoding = copy(engine.encoding)

        if engine.detect==true
            code = transcode(code,encoding,engine.detect)
        end

        simhash_segment_lines(code,engine)
    else

    	 return simhash_segment_words(code,engine)
    end

end # segment()

function ham_distance(codel::String,coder::String,engine::SegmentWorker)
    result_left  = simhash(codel,engine)
    result_right = simhash(coder,engine)
    distance     = ccall(distance_key,Culonglong,(Ptr{Nothing},Culonglong,Culonglong),engine.private.worker,result_left[2],result_right[2])
    return (result_left,result_right,distance)
end
