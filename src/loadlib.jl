
export DICTPATH
export HMMPATH
export USERPATH
export libdemo

using Compat.Libdl:dlopen
using Compat.Libdl:dlsym

fnames = ["libdemo.so", "libdemo.dylib", "libdemo.dll"]
paths = [pwd(),joinpath(pwd(), "deps") ]
append!(paths, [joinpath(dir, "Jieba", "deps") for dir in Base.LOAD_PATH])
global libname = ""
found = false
for path in paths
    if !found
        for fname in fnames
            tp_libname = joinpath(path, fname)
            if isfile(tp_libname)
                global libname = tp_libname
                local found = true
                break
            end
        end
    end
end
if !isfile(libname)
    error("Library cannot be found; it may not have been built correctly.\n Try include(\"build.jl\") from within the deps directory.")
end

const libdemo = libname

libkey = dlopen(libdemo)

const mix_engine_key    = dlsym(libkey,:mix_engine)
const vector_result_key = dlsym(libkey,:vector_result)
const get_vector_size_key = dlsym(libkey,:get_vector_size)
const result_key = dlsym(libkey,:result)
const free_basev_key = dlsym(libkey,:free_basev)
const free_char_key = dlsym(libkey,:free_char)
const free_mix_key = dlsym(libkey,:free_mix)

const detect_enc_key = dlsym(libkey,:detect_enc)

#MP
const mp_engine_key    = dlsym(libkey,:mp_engine)
const mp_vector_result_key = dlsym(libkey,:mp_vector_result)
const free_mp_key = dlsym(libkey,:free_mp)

#HMM
const hmm_engine_key    = dlsym(libkey,:hmm_engine)
const hmm_vector_result_key = dlsym(libkey,:hmm_vector_result)
const free_hmm_key = dlsym(libkey,:free_hmm)

#QU
const qu_engine_key    = dlsym(libkey,:qu_engine)
const qu_vector_result_key = dlsym(libkey,:qu_vector_result)
const free_qu_key = dlsym(libkey,:free_qu)

#Key

const key_engine_key    = dlsym(libkey,:key_engine)
const key_vector_num_result_key = dlsym(libkey,:key_vector_num_result)
const free_key_key = dlsym(libkey,:free_key)
const keyword_char_key = dlsym(libkey,:keyword_char)
const keyword_num_key = dlsym(libkey,:keyword_num)

const get_vector_num_size_key = dlsym(libkey,:get_vector_num_size)
const free_vector_num_base_key = dlsym(libkey,:free_vector_num_base)

const free_num_p_key = dlsym(libkey,:free_num_p)

#Tag

const tag_engine_key    = dlsym(libkey,:tag_engine)
const tag_vector_vector_result_key = dlsym(libkey,:tag_vector_vector_result)
const free_tag_key = dlsym(libkey,:free_tag)
const tagger_char_key = dlsym(libkey,:tagger_char)
const tagger_tag_key = dlsym(libkey,:tagger_tag)
const get_vector_vector_size_key = dlsym(libkey,:get_vector_vector_size)
const free_vector_vector_base_key = dlsym(libkey,:free_vector_vector_base)

#Sim

const sim_engine_key    = dlsym(libkey,:sim_engine)
const sim_vector_num_result_key = dlsym(libkey,:sim_vector_num_result)
const free_sim_key = dlsym(libkey,:free_sim)

const simhasher_res_key = dlsym(libkey,:simhasher_res)
const distance_key = dlsym(libkey,:distance)


# Get the 'deps' directory path
const deps_path = dirname(libname)

DICTPATH = joinpath(deps_path, "dict", "jieba.dict.utf8")
HMMPATH  = joinpath(deps_path, "dict", "hmm_model.utf8")
USERPATH = joinpath(deps_path, "dict", "user.dict.utf8")
STOPPATH  = joinpath(deps_path, "dict", "stop_words.utf8")
IDFPATH = joinpath(deps_path, "dict", "idf.utf8")

if !isfile(DICTPATH)
    error("Can not find system dictionary.")
end

if !isfile(HMMPATH)
    error("Can not find HMM model.")
end

if !isfile(USERPATH)
    error("Can not find user dictionary.")
end

if !isfile(STOPPATH)
    error("Can not find stop words dictionary.")
end

if !isfile(IDFPATH)
    error("Can not find IDFPATH.")
end
