#include <stdio.h>
#include <stdlib.h>

#include "src/detect.h"
#include "src/c_api.h"

// static const char *DICT_PATH = "./dict/jieba.dict.utf8";
// static const char *HMM_PATH = "./dict/hmm_model.utf8";
// static const char *USER_DICT = "./dict/user.dict.utf8";

// init will take a few seconds to load dicts.
struct MixSegment *mix_engine(const char *DICT_PATH, const char *HMM_PATH, const char *USER_DICT)
{
    return NewMixSegment(DICT_PATH, HMM_PATH, USER_DICT);
}

const char **result(struct VectorBase *basev)
{
    return SegmentCut(basev);
}

struct VectorBase *vector_result(struct MixSegment *handle, const char *code)
{
    return GetSegmentVector(handle, code);
}

void free_basev(struct VectorBase *basev)
{
    FreeVectorBase(basev);
}

void free_mix(struct MixSegment *handle)
{
    FreeMixSegment(handle);
}

void free_char(const char **pointer)
{
    FreeCharPP(pointer);
}

size_t get_vector_size(struct VectorBase *basev)
{
    return GetVectorSize(basev);
}

const char *detect_enc(const char *filepath)
{
    return filecoding(filepath);
}

///HMM

struct HMMSegment *hmm_engine(const char *HMM_PATH)
{
    return NewHMMSegment(HMM_PATH);
}

void free_hmm(struct HMMSegment *handle)
{
    FreeHMMSegment(handle);
}

struct VectorBase *hmm_vector_result(struct HMMSegment *handle, const char *code)
{
    return GetHMMSegmentVector(handle, code);
}

///MP

struct MPSegment *mp_engine(const char *dict_path, const char *user_path)
{
    return NewMPSegment(dict_path, user_path);
}

void free_mp(struct MPSegment *handle)
{
    FreeMPSegment(handle);
}

struct VectorBase *mp_vector_result(struct MPSegment *handle, const char *code)
{
    return GetMPSegmentVector(handle, code);
}


///QU

struct QuerySegment *qu_engine(const char *DICT_PATH, const char *HMM_PATH, size_t q_max)
{
    return NewQuerySegment(DICT_PATH, HMM_PATH, q_max);
}

void free_qu(struct QuerySegment *handle)
{
    FreeQuerySegment(handle);
}

struct VectorBase *qu_vector_result(struct QuerySegment *handle, const char *code)
{
    return GetQuerySegmentVector(handle, code);
}

////Tag

struct PosTagger *tag_engine(const char *DICT_PATH, const char *HMM_PATH, const char *USER_PATH)
{
    return NewPosTagger(DICT_PATH, HMM_PATH, USER_PATH);
}

void free_tag(struct PosTagger *handle)
{
    FreePosTagger(handle);
}

struct VectorVectorBase *tag_vector_vector_result(struct PosTagger *handle, const char *code)
{
    return GetPosTaggerVectorVector(handle, code);
}

const char **tagger_char(struct VectorVectorBase *basev)
{
    return TaggerChar(basev);
}

const char **tagger_tag(struct VectorVectorBase *basev)
{
    return TaggerTag(basev);
}

size_t get_vector_vector_size(struct VectorVectorBase *basev)
{
    return GetVectorVectorSize(basev);
}

void free_vector_vector_base(struct VectorVectorBase *basev)
{
    return FreeVectorVectorBase(basev);
}


////Key

size_t get_vector_num_size(struct VectorNumBase *basev)
{
    return GetVectorNumSize(basev);
}

void free_vector_num_base(struct VectorNumBase *basev)
{
    return FreeVectorNumBase(basev);
}

void free_num_p(const double *pointer)
{
    FreeNumP(pointer);
}

///Key main

struct KeywordExtractor *key_engine(const char *dict_path, const char *hmm_path, const char *idf_path, const char *stop_path)
{
    return NewKeywordExtractor(dict_path, hmm_path, idf_path, stop_path);
}

void free_key(struct KeywordExtractor *handle)
{
    FreeKeywordExtractor(handle);
}

struct VectorNumBase *key_vector_num_result(struct KeywordExtractor *handle, const char *code, size_t topn)
{
    return GetKeywordExtractorVectorNum(handle, code, topn);
}

const char **keyword_char(struct VectorNumBase *basev)
{
    return KeywordExtractorChar(basev);
}

const double *keyword_num(struct VectorNumBase *basev)
{
    return KeywordExtractorNum(basev);
}

//// Get Simhash hash

struct Simhasher *sim_engine(const char *dict_path, const char *hmm_path, const char *idf_path, const char *stop_path)
{
    return NewSimhasher(dict_path, hmm_path, idf_path, stop_path);
}

void free_sim(struct Simhasher *handle)
{
    FreeSimhasher(handle);
}

struct VectorNumBase *sim_vector_num_result(struct Simhasher *handle, const char *code, size_t topn)
{
    return GetSimhasherVectorNum(handle, code, topn);
}

const unsigned long long int simhasher_res(struct VectorNumBase *basev)
{
    return SimhasherRes(basev);
}

const unsigned long long int distance(const struct Simhasher *segment, unsigned long long int lhs, unsigned long long int rhs)
{
    return Distance(segment, lhs, rhs);
}
