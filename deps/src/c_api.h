#ifndef CJIEBA_C_API_H
#define CJIEBA_C_API_H
///Str
struct VectorBase {};
struct MixSegment *NewMixSegment(const char *dict_path, const char *hmm_path, const char *user_dict);
void FreeMixSegment(struct MixSegment *);
const char **SegmentCut(struct VectorBase *);
struct VectorBase *GetSegmentVector(const struct MixSegment *segment, const char *sentence);
size_t  GetVectorSize(struct VectorBase *);
void FreeVectorBase(struct VectorBase *);
void FreeCharPP(const char **pointer);

struct VectorVectorBase {}; /// for Tagger
size_t GetVectorVectorSize(struct VectorVectorBase *);
void FreeVectorVectorBase(struct VectorVectorBase *);

struct VectorNumBase {}; /// for Key
size_t GetVectorNumSize(struct VectorNumBase *);
void FreeVectorNumBase(struct VectorNumBase *);
void FreeNumP(const double *pointer);


///HMM
struct HMMSegment *NewHMMSegment(const char *hmm_path);
void FreeHMMSegment(struct HMMSegment *handle);
struct VectorBase *GetHMMSegmentVector(const struct HMMSegment *segment, const char *sentence);

///MP
struct MPSegment *NewMPSegment(const char *dict_path, const char *user_dict);
void FreeMPSegment(struct MPSegment *handle);
struct VectorBase *GetMPSegmentVector(const struct MPSegment *segment, const char *sentence);

///QU
struct QuerySegment *NewQuerySegment(const char *dict_path, const char *hmm_path, size_t maxWordLen);
struct VectorBase *GetQuerySegmentVector(const struct QuerySegment *segment, const char *sentence);
void FreeQuerySegment(struct QuerySegment *handle);

///Pos
struct PosTagger  *NewPosTagger(const char *dict_path, const char *hmm_path, const char *user_path);
void FreePosTagger(struct PosTagger *handle);
struct VectorVectorBase *GetPosTaggerVectorVector(const struct PosTagger *segment, const char *sentence);
const char **TaggerChar(struct VectorVectorBase *basev);
const char **TaggerTag(struct VectorVectorBase *basev);

///Key
struct KeywordExtractor *NewKeywordExtractor(const char *dict_path, const char *hmm_path, const char *idf_path, const char *stop_path);
void FreeKeywordExtractor(struct KeywordExtractor *handle);
struct VectorNumBase *GetKeywordExtractorVectorNum(const struct KeywordExtractor *segment, const char *sentence, size_t topn);
const char **KeywordExtractorChar(struct VectorNumBase *basev);
const double *KeywordExtractorNum(struct VectorNumBase *basev);

///Sim
struct Simhasher *NewSimhasher(const char *dict_path, const char *hmm_path, const char *idf_path, const char *stop_path);
void FreeSimhasher(struct Simhasher *handle);
struct VectorNumBase *GetSimhasherVectorNum(const struct Simhasher *segment, const char *sentence, size_t topn);
const char **SimhasherChar(struct VectorNumBase *basev);
const double *SimhasherNum(struct VectorNumBase *basev);
const unsigned long long int SimhasherRes(struct VectorNumBase *basev);
const unsigned long long int Distance(const struct Simhasher *segment, unsigned long long int lhs, unsigned long long int rhs);

#endif
