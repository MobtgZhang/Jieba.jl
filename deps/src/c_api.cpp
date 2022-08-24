//extern "C" {
//#include "c_api.h"
//}
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <cstdio>
#include <sstream>
#include "CppJieba/MixSegment.hpp"
#include "CppJieba/MPSegment.hpp"
#include "CppJieba/HMMSegment.hpp"
#include "CppJieba/QuerySegment.hpp"
#include "CppJieba/PosTagger.hpp"
#include "CppJieba/Simhasher.hpp"




using namespace CppJieba;
using namespace Simhash;

// string itos(double i)  // convert int to string
// {
//     stringstream s;
//     s << i;
//     return s.str();
// }

// string int64tos(uint64_t i)  // convert int to string
// {
//     stringstream s;
//     s << i;
//     return s.str();
// }

extern "C" {

    struct VectorBase ///for Segment
    {
        vector<string> *res = new vector<string>();
        size_t ressize;
    };

    size_t  GetVectorSize(struct VectorBase *basev)
    {
        return basev->ressize;
    }

    void FreeVectorBase(struct VectorBase *basev)
    {
        delete basev->res;
        delete basev;
    }

    struct VectorVectorBase /// for Tagger
    {
        vector<pair<string, string> >  *res;
        size_t ressize;

        VectorVectorBase() : res(new vector<pair<string, string> >())
        {};
    };

    size_t  GetVectorVectorSize(struct VectorVectorBase *basev)
    {
        return basev->ressize;
    }

    void FreeVectorVectorBase(struct VectorVectorBase *basev)
    {
        delete basev->res;
        delete basev;
    }

    struct VectorNumBase /// for Key
    {
        vector<pair<string, double> > *res = new vector<pair<string, double> >();
        size_t ressize;
        uint64_t hashres;
    };

    size_t  GetVectorNumSize(struct VectorNumBase *basev)
    {
        return basev->ressize;
    }

    void FreeVectorNumBase(struct VectorNumBase *basev)
    {
        delete basev->res;
        delete basev;
    }

    void FreeCharPP(const char **pointer)
    {
        delete[] pointer;
    }

    void FreeNumP(const double *pointer)
    {
        delete[] pointer;
    }
    //////////// Mixseg

    struct MixSegment *NewMixSegment(const char *dict_path, const char *hmm_path, const char *user_dict)
    {
        MixSegment *handler = new MixSegment(dict_path, hmm_path, user_dict);
        return handler;
    }
    void FreeMixSegment(struct MixSegment *handle)
    {
        delete handle;
    }

    struct VectorBase *GetSegmentVector(const struct MixSegment *segment, const char *sentence)
    {
        struct VectorBase *basev = new struct VectorBase();
        segment->cut(sentence, *(basev->res));
        basev->ressize = (*(basev->res)).size();
        return basev;
    }

    const char **SegmentCut(struct VectorBase *basev)
    {
        if ((*(basev->res)).empty())
        {
            return NULL;
        }
        const char **res = new const char *[(*(basev->res)).size()];
        for (unsigned int n = 0; n < (*(basev->res)).size(); n++ )
        {
            res[n] = (*(basev->res))[n].c_str();

        }
        return res;
    }
    //////////// HMMseg
    struct HMMSegment *NewHMMSegment(const char *hmm_path)
    {
        HMMSegment *handler = new HMMSegment(hmm_path);
        return handler;
    }
    void FreeHMMSegment(struct HMMSegment *handle)
    {
        delete handle;
    }

    struct VectorBase *GetHMMSegmentVector(const struct HMMSegment *segment, const char *sentence)
    {
        struct VectorBase *basev = new struct VectorBase();
        segment->cut(sentence, *(basev->res));
        basev->ressize = (*(basev->res)).size();
        return basev;
    }

    ////////////MPseg
    struct MPSegment *NewMPSegment(const char *dict_path, const char *user_dict)
    {
        MPSegment *handler = new MPSegment(dict_path, user_dict);
        return handler;
    }
    void FreeMPSegment(struct MPSegment *handle)
    {
        delete handle;
    }

    struct VectorBase *GetMPSegmentVector(const struct MPSegment *segment, const char *sentence)
    {
        struct VectorBase *basev = new struct VectorBase();
        segment->cut(sentence, *(basev->res));
        basev->ressize = (*(basev->res)).size();
        return basev;
    }

    //////////// QUseg

    struct QuerySegment *NewQuerySegment(const char *dict_path, const char *hmm_path, size_t maxWordLen)
    {
        QuerySegment *handler = new QuerySegment(dict_path, hmm_path, maxWordLen);
        return handler;
    }
    void FreeQuerySegment(struct QuerySegment *handle)
    {
        delete handle;
    }

    struct VectorBase *GetQuerySegmentVector(const struct QuerySegment *segment, const char *sentence)
    {
        struct VectorBase *basev = new struct VectorBase();
        segment->cut(sentence, *(basev->res));
        basev->ressize = (*(basev->res)).size();
        return basev;
    }


    //////////// Tag

    struct PosTagger  *NewPosTagger(const char *dict_path, const char *hmm_path, const char *user_path)
    {
        PosTagger *handler = new PosTagger(dict_path, hmm_path, user_path);
        return handler;
    }
    void FreePosTagger(struct PosTagger *handle)
    {
        delete handle;
    }

    struct VectorVectorBase *GetPosTaggerVectorVector(const struct PosTagger *segment, const char *sentence)
    {
        struct VectorVectorBase *basev = new struct VectorVectorBase();
        segment->tag(sentence, *(basev->res));
        basev->ressize = (*(basev->res)).size();
        return basev;
    }

    const char **TaggerChar(struct VectorVectorBase *basev)
    {
        if ((*(basev->res)).empty())
        {
            return NULL;
        }
        const char **res = new const char *[(*(basev->res)).size()];
        for (unsigned int n = 0; n < (*(basev->res)).size(); n++ )
        {
            res[n] = (*(basev->res))[n].first.c_str();

        }
        return res;
    }

    const char **TaggerTag(struct VectorVectorBase *basev)
    {
        if ((*(basev->res)).empty())
        {
            return NULL;
        }
        const char **res = new const char *[(*(basev->res)).size()];
        for (unsigned int n = 0; n < (*(basev->res)).size(); n++ )
        {
            res[n] = (*(basev->res))[n].second.c_str();

        }
        return res;
    }

    //////////// Key

    struct KeywordExtractor *NewKeywordExtractor(const char *dict_path, const char *hmm_path, const char *idf_path, const char *stop_path)
    {
        KeywordExtractor *handler = new KeywordExtractor(dict_path, hmm_path, idf_path, stop_path);
        return handler;
    }
    void FreeKeywordExtractor(struct KeywordExtractor *handle)
    {
        delete handle;
    }

    struct VectorNumBase *GetKeywordExtractorVectorNum(const struct KeywordExtractor *segment, const char *sentence, size_t topn)
    {
        struct VectorNumBase *basev = new struct VectorNumBase();
        segment->extract(sentence, *(basev->res), topn);
        basev->ressize = (*(basev->res)).size();
        return basev;
    }

    const char **KeywordExtractorChar(struct VectorNumBase *basev)
    {
        if ((*(basev->res)).empty())
        {
            return NULL;
        }
        const char **res = new const char *[(*(basev->res)).size()];
        for (unsigned int n = 0; n < (*(basev->res)).size(); n++ )
        {
            res[n] = (*(basev->res))[n].first.c_str();

        }
        return res;
    }

    const double *KeywordExtractorNum(struct VectorNumBase *basev)
    {
        if ((*(basev->res)).empty())
        {
            return NULL;
        }
        double *res = new double [(*(basev->res)).size()];
        for (unsigned int n = 0; n < (*(basev->res)).size(); n++ )
        {
            res[n] = (*(basev->res))[n].second;
        }
        return res;
    }

    //////////// Simhash
    struct Simhasher *NewSimhasher(const char *dict_path, const char *hmm_path, const char *idf_path, const char *stop_path)
    {
        Simhasher *handler = new Simhasher(dict_path, hmm_path, idf_path, stop_path);
        return handler;
    }
    void FreeSimhasher(struct Simhasher *handle)
    {
        delete handle;
    }

    struct VectorNumBase *GetSimhasherVectorNum(const struct Simhasher *segment, const char *sentence, size_t topn)
    {
        struct VectorNumBase *basev = new struct VectorNumBase();
        segment->make(sentence, topn, basev->hashres, *(basev->res));
        basev->ressize = (*(basev->res)).size();
        return basev;
    }

    const char **SimhasherChar(struct VectorNumBase *basev)
    {
        if ((*(basev->res)).empty())
        {
            return NULL;
        }
        const char **res = new const char *[(*(basev->res)).size()];
        for (unsigned int n = 0; n < (*(basev->res)).size(); n++ )
        {
            res[n] = (*(basev->res))[n].first.c_str();

        }
        return res;
    }

    const double *SimhasherNum(struct VectorNumBase *basev)
    {
        if ((*(basev->res)).empty())
        {
            return NULL;
        }
        double *res = new double [(*(basev->res)).size()];
        for (unsigned int n = 0; n < (*(basev->res)).size(); n++ )
        {
            res[n] = (*(basev->res))[n].second;
        }
        return res;
    }
    const uint64_t SimhasherRes(struct VectorNumBase *basev)
    {
        return basev->hashres;
    }

    //////////// Distance
    const uint64_t Distance(const struct Simhasher *segment, uint64_t lhs, uint64_t rhs)
    {
        return segment->distances(lhs, rhs);
    }
}
