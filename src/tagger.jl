
export tagger


function tag_segment_lines(code::String,engine::SegmentWorker,FILESMODE::Bool,output)
    
    nlines = copy(engine.lines)
    fileopen = open(code,"r")

    if engine.write== true
    	outputopen = open(output,"w")
	    
	    OUT = false
	    
	    try
	    	while nlines == engine.lines
	    		temparray = Array{String}(engine.lines)
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
				
	    		tempresult = tag_segment_words(join(temparray),engine,FILESMODE)
	    		
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
	    print("Output file: $output")
	    return output

    else 
    	FILESMODE = false
    	result = Array{String}(0)
    	try
	    	while nlines == engine.lines
	    		temparray = Array{String}(engine.lines)
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




function tag_segment_words(code::String,engine::SegmentWorker,FILESMODE::Bool) 

	if engine.symbol == false
		code = replace(code,r"[^\u2e80-\u3000\u3021-\ufe4fa-zA-Z0-9]"=>" ")
    end
    
    tempvector = ccall(tag_vector_vector_result_key,Ptr{Nothing},(Ptr{Nothing},Ptr{UInt8}),engine.private.worker,pointer(code))
	
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

	if engine.symbol == false
		tempbool = .!(result_char .== " ")
		result_char = result_char[ tempbool ]
		result_tag  = result_tag[ tempbool ]
    end

    result = [result_char result_tag]

    return result
end # cut_words


function tagger(code::String,engine::SegmentWorker)
	
	if engine.private.worker_type != "tag"
		error("""worker's type is not "tag".""")
	end

    if isfile(code) 
        if  engine.output == " "
        	base_names = replace(code, r"\.[^\.]*$","")
        	extnames   = replace(code, base_names, "")
        	output = string(base_names, ".segment", convert(Int,round(time())), extnames)
        else 
        	output = copy(engine.output)
        end
        encoding = copy(engine.encoding)

        if engine.detect==true
            code = transcode(code,encoding,engine.detect)
        end

        FILESMODE = true

        tag_segment_lines(code,engine,FILESMODE,output)
    else
    	FILESMODE = false

    	 return tag_segment_words(code,engine,FILESMODE)
    end

end # segment()

