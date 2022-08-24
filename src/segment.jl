import Base: <=
export segment
export segment_text
using Printf:@sprintf

function cut_segment_lines(code::String,engine::SegmentWorker,FILESMODE::Bool,output)
    
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
				
	    		tempresult = cut_segment_words(join(temparray),engine,FILESMODE)
	    		
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
	    		result = [result,tempresult]
	    		nlines = copy(numlines)
	    	end

    	finally
	    	try
	    		close(fileopen)
			catch
				exit(1)
	    	end

	    end # end try

	    return result 
    end  # end if else
end




function cut_segment_words(code::String,engine::SegmentWorker,FILESMODE::Bool) 

	if engine.symbol == false
		code = replace(code,r"[^\u2e80-\u3000\u3021-\ufe4fa-zA-Z0-9]"=>" ")
		
    end
    
	if engine.private.worker_type == "mix"
    tempvector = ccall(vector_result_key,Ptr{Nothing},(Ptr{Nothing},Ptr{UInt8}),engine.private.worker,pointer(code))
    elseif engine.private.worker_type == "mp"
    tempvector = ccall(mp_vector_result_key,Ptr{Nothing},(Ptr{Nothing},Ptr{UInt8}),engine.private.worker,pointer(code))
    elseif engine.private.worker_type == "hmm"
    tempvector = ccall(hmm_vector_result_key,Ptr{Nothing},(Ptr{Nothing},Ptr{UInt8}),engine.private.worker,pointer(code))
    elseif engine.private.worker_type == "query"
    tempvector = ccall(qu_vector_result_key,Ptr{Nothing},(Ptr{Nothing},Ptr{UInt8}),engine.private.worker,pointer(code)) 
    end
    
    sz = ccall(get_vector_size_key,UInt32,(Ptr{Nothing},),tempvector)
    res = ccall(result_key,Ptr{Ptr{UInt8}},(Ptr{Nothing},),tempvector)

    temparray = Base.unsafe_wrap(Array,res,sz)
    result =  Array{String}(undef,length(temparray))
    
    for num in 1:sz 
          result[num] = Base.unsafe_string(temparray[num])
    end

    ccall(free_basev_key,Nothing,(Ptr{Nothing},),tempvector)
    ccall(free_char_key,Nothing,(Ptr{Ptr{UInt8}},),res)

	if engine.symbol == false
		result = result[ .!(result .== " ")]
    end

    return result
end # cut_words

function segment_text(code::String,engine::SegmentWorker)
    return cut_segment_words(code,engine,false)
end

function segment(code::String,engine::SegmentWorker)
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

        cut_segment_lines(code,engine,FILESMODE,output)
    else
    	FILESMODE = false

    	 return cut_segment_words(code,engine,FILESMODE)
    end

end # segment()

function <=(engine::SegmentWorker, code::String)
  if engine.private.worker_type == "mix" || engine.private.worker_type == "hmm" || engine.private.worker_type == "mp" || engine.private.worker_type == "query"  
  	segment(code,engine)
  elseif engine.private.worker_type == "tag"
  	tagger(code,engine)
  elseif engine.private.worker_type == "keywords"
  	keywords(code,engine)
  elseif engine.private.worker_type == "simhash"
  	simhash(code,engine)
  else 
	print_str = @sprintf("%s",engine.private.worker_type)
	throw(string("Unknown engine: ",print_str))
  end 
end

