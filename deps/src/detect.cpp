
/*
* Copyright (C) 2006-2010 Wu Yongwei <wuyongwei@gmail.com>
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any
* damages arising from the use of this software.
*
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute
* it freely, subject to the following restrictions:
*
* 1. The origin of this software must not be misrepresented; you must
*    not claim that you wrote the original software.  If you use this
*    software in a product, an acknowledgement in the product
*    documentation would be appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must
*    not be misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source
*    distribution.
*
*
* The latest version of this software should be available at:
*      <URL:http://wyw.dcweb.cn/>
*
*/


/**
* * * @file    tellenc.cpp
* * *
* * * Program to detect the encoding of text.  It currently supports ASCII,
* * * UTF-8, UTF-16/32 (little-endian or big-endian), Latin1, Windows-1252,
* * * CP437, GB2312, GBK, Big5, and SJIS.
* * *
* * * @version 1.15, 2010/03/28
* * * @author  Wu Yongwei
* * */

#include <algorithm>        // sort
#include <functional>       // binary_function
#include <map>              // map
#include <memory>           // pair
#include <vector>           // vector
#include <ctype.h>          // isprint
#include <errno.h>          // errno
//#include <stdio.h>          // fopen/fclose/fprintf/printf/puts
#include <stdlib.h>         // exit
#include <string.h>         // memcmp/strcmp/strerror
#include <iostream>

#ifndef _WIN32
#define __cdecl
#endif

/* The following is the way what I expected MSVC to work: treat the text
* here as in UTF-8, so it won't emit warnings for the UTF-8 comments
* below.  It seems it never really works: it is unnecessary in versions
* prior to Visual C++ 2005, and will even cause errors beginning in
* that version.  The new versions of MSVC accept the UTF-8 BOM
* character to interpret the file correctly, but the BOM causes errors
* in MSVC 6 and GCC 2/3. */

#ifndef TELLENC_BUFFER_SIZE
#define TELLENC_BUFFER_SIZE 200000
#endif

extern "C" {

    using namespace std;

    typedef unsigned short uint16_t;
    typedef pair<uint16_t, size_t> char_count_t;

    struct freq_analysis_data_t
    {
        uint16_t    dbyte;
        const char *enc;
    };

    struct greater_char_count :
            public binary_function<const char_count_t &,
            const char_count_t &,
            bool>
    {
        result_type operator()(first_argument_type lhs, second_argument_type rhs)
        {
            if (lhs.second > rhs.second)
            {
                return true;
            }
            return false;
        }
    };

    enum UTF8_State
    {
        UTF8_INVALID,
        UTF8_1,
        UTF8_2,
        UTF8_3,
        UTF8_4,
        UTF8_TAIL
    };

    static const size_t MAX_CHAR = 256;
    static const unsigned char NON_TEXT_CHARS[] = { 0, 26, 127, 255 };
    static const char NUL = '\0';
    static const char DOS_EOF = '\x1A';
    static const int EVEN = 0;
    static const int ODD  = 1;

    static UTF8_State utf8_char_table[MAX_CHAR];

    static freq_analysis_data_t freq_analysis_data[] =
    {
        { 0xe4e4, "windows-1252" },         // "????" (Finnish)
        { 0x8220, "cp437" },                // "?? " (French)
        { 0x8263, "cp437" },                // "??c" (French)
        { 0x8265, "cp437" },                // "??e" (French)
        { 0x8272, "cp437" },                // "??r" (French)
        { 0x8520, "cp437" },                // "?? " (French)
        { 0x8172, "cp437" },                // "??r" (German)
        { 0x8474, "cp437" },                // "??t" (German)
        { 0xc4c4, "cp437" },                // "??????"
        { 0xcdcd, "cp437" },                // "??????"
        { 0xdbdb, "cp437" },                // "??????"
        { 0xa1a1, "gbk" },                  // "???"
        { 0xa1a3, "gbk" },                  // "???"
        { 0xa3ac, "gbk" },                  // "???"
        { 0xa3ba, "gbk" },                  // "???"
        { 0xb5c4, "gbk" },                  // "???"
        { 0xc1cb, "gbk" },                  // "???"
        { 0xd2bb, "gbk" },                  // "???"
        { 0xcac7, "gbk" },                  // "???"
        { 0xb2bb, "gbk" },                  // "???"
        { 0xb8f6, "gbk" },                  // "???"
        { 0xc8cb, "gbk" },                  // "???"
        { 0xd5e2, "gbk" },                  // "???"
        { 0xd3d0, "gbk" },                  // "???"
        { 0xced2, "gbk" },                  // "???"
        { 0xc4e3, "gbk" },                  // "???"
        { 0xcbfb, "gbk" },                  // "???"
        { 0xcbfd, "gbk" },                  // "???"
        { 0xc9cf, "gbk" },                  // "???"
        { 0xbfb4, "gbk" },                  // "???"
        { 0xd6ae, "gbk" },                  // "???"
        { 0xbfc9, "gbk" },                  // "???"
        { 0xbaf3, "gbk" },                  // "???"
        { 0xd6d0, "gbk" },                  // "???"
        { 0xd0d0, "gbk" },                  // "???"
        { 0xb1d2, "gbk" },                  // "???"
        { 0xb3f6, "gbk" },                  // "???"
        { 0xb7d1, "gbk" },                  // "???"
        { 0xb8d0, "gbk" },                  // "???"
        { 0xbef5, "gbk" },                  // "???"
        { 0xc4ea, "gbk" },                  // "???"
        { 0xd4c2, "gbk" },                  // "???"
        { 0xc8d5, "gbk" },                  // "???"
        { 0xa140, "big5" },                 // "???"
        { 0xa141, "big5" },                 // "???"
        { 0xa143, "big5" },                 // "???"
        { 0xa147, "big5" },                 // "???"
        { 0xaaba, "big5" },                 // "???"
        { 0xa446, "big5" },                 // "???"
        { 0xa440, "big5" },                 // "???"
        { 0xac4f, "big5" },                 // "???"
        { 0xa4a3, "big5" },                 // "???"
        { 0xa448, "big5" },                 // "???"
        { 0xa7da, "big5" },                 // "???"
        { 0xa741, "big5" },                 // "???"
        { 0xa54c, "big5" },                 // "???"
        { 0xa66f, "big5" },                 // "???"
        { 0xadd3, "big5" },                 // "???"
        { 0xa457, "big5" },                 // "???"
        { 0xa662, "big5" },                 // "???"
        { 0xbba1, "big5" },                 // "???"
        { 0xa65e, "big5" },                 // "???"
        { 0x8140, "sjis" },                 // "???"
        { 0x8141, "sjis" },                 // "???"
        { 0x8142, "sjis" },                 // "???"
        { 0x8145, "sjis" },                 // "???"
        { 0x8146, "sjis" },                 // "???"
        { 0x815b, "sjis" },                 // "???"
        { 0x82b5, "sjis" },                 // "???"
        { 0x82bd, "sjis" },                 // "???"
        { 0x82c8, "sjis" },                 // "???"
        { 0x82c9, "sjis" },                 // "???"
        { 0x82cc, "sjis" },                 // "???"
        { 0x82dc, "sjis" },                 // "???"
        { 0x82f0, "sjis" },                 // "???"
        { 0x8367, "sjis" },                 // "???"
        { 0x8393, "sjis" },                 // "???"
        { 0x89ef, "sjis" },                 // "???"
        { 0x906c, "sjis" },                 // "???"
        { 0x9094, "sjis" },                 // "???"
        { 0x93fa, "sjis" },                 // "???"
        { 0x95f1, "sjis" },                 // "???"
    };

    static size_t nul_count_byte[2];
    static size_t nul_count_word[2];

    static bool is_binary = false;
    static bool is_valid_utf8 = true;
    static bool is_valid_latin1 = true;

    bool verbose = false;

    static inline bool is_non_text(char ch)
    {
        for (size_t i = 0; i < sizeof(NON_TEXT_CHARS); ++i)
        {
            if (ch == NON_TEXT_CHARS[i])
            {
                return true;
            }
        }
        return false;
    }

    void init_utf8_char_table()
    {
        int ch = 0;
        utf8_char_table[ch] = UTF8_INVALID;
        ++ch;
        for (; ch <= 0x7f; ++ch)
        {
            utf8_char_table[ch] = UTF8_1;
        }
        for (; ch <= 0xbf; ++ch)
        {
            utf8_char_table[ch] = UTF8_TAIL;
        }
        for (; ch <= 0xc1; ++ch)
        {
            utf8_char_table[ch] = UTF8_INVALID;
        }
        for (; ch <= 0xdf; ++ch)
        {
            utf8_char_table[ch] = UTF8_2;
        }
        for (; ch <= 0xef; ++ch)
        {
            utf8_char_table[ch] = UTF8_3;
        }
        for (; ch <= 0xf4; ++ch)
        {
            utf8_char_table[ch] = UTF8_4;
        }
        for (; ch <= 0xff; ++ch)
        {
            utf8_char_table[ch] = UTF8_INVALID;
        }
    }

    static void init_char_count(char_count_t char_cnt[])
    {
        for (size_t i = 0; i < MAX_CHAR; ++i)
        {
            char_cnt[i].first = i;
            char_cnt[i].second = 0;
        }
    }

    //  static void print_char_cnt(const char_count_t char_cnt[])
    //  {
    //    for (size_t i = 0; i < MAX_CHAR; ++i)
    //    {
    //      unsigned char ch = (unsigned char)char_cnt[i].first;
    //      if (char_cnt[i].second == 0)
    //      break;
    //      printf("%.2x ('%c'): %-6u    ", ch,
    //      isprint(ch) ? ch : '?', char_cnt[i].second);
    //    }
    //    printf("\n");
    //  }

    //  static void print_dbyte_char_cnt(const vector<char_count_t> &dbyte_char_cnt)
    //  {
    //    for (vector<char_count_t>::const_iterator it = dbyte_char_cnt.begin();
    //    it != dbyte_char_cnt.end(); ++it)
    //    {
    //      printf("%.4x: %-6u        ", it->first, it->second);
    //    }
    //  }

    static const char *check_ucs_bom(const unsigned char *const buffer)
    {
        const struct
        {
            const char *name;
            const char *pattern;
            size_t pattern_len;
        } patterns[] =
        {
            { "ucs-4",      "\x00\x00\xFE\xFF",     4 },
            { "ucs-4le",    "\xFF\xFE\x00\x00",     4 },
            { "utf-8",      "\xEF\xBB\xBF",         3 },
            { "utf-16",     "\xFE\xFF",             2 },
            { "utf-16le",   "\xFF\xFE",             2 },
            { NULL,         NULL,                   0 }
        };
        for (size_t i = 0; patterns[i].name; ++i)
        {
            if (memcmp(buffer, patterns[i].pattern, patterns[i].pattern_len)
                    == 0)
            {
                return patterns[i].name;
            }
        }
        return NULL;
    }

    static const char *check_dbyte(uint16_t dbyte)
    {
        for (size_t i = 0;
                i < sizeof freq_analysis_data / sizeof(freq_analysis_data_t);
                ++i)
        {
            if (dbyte == freq_analysis_data[i].dbyte)
            {
                return freq_analysis_data[i].enc;
            }
        }
        return NULL;
    }

    static const char *check_freq_dbytes(const vector<char_count_t> &dbyte_char_cnt)
    {
        size_t max_comp_idx = 10;
        if (max_comp_idx > dbyte_char_cnt.size())
        {
            max_comp_idx = dbyte_char_cnt.size();
        }
        for (size_t i = 0; i < max_comp_idx; ++i)
        {
            if (const char *enc = check_dbyte(dbyte_char_cnt[i].first))
            {
                return enc;
            }
        }
        return NULL;
    }

    const char *tellenc2(const unsigned char *const buffer, const size_t len)
    {
        char_count_t char_cnt[MAX_CHAR];
        map<uint16_t, size_t> mp_dbyte_char_cnt;
        size_t dbyte_cnt = 0;
        size_t dbyte_hihi_cnt = 0;

        if (len >= 4)
        {
            if (const char *result = check_ucs_bom(buffer))
            {
                return result;
            }
        }
        else if (len == 0)
        {
            return "unknown";
        }

        init_char_count(char_cnt);

        unsigned char ch;
        int last_ch = EOF;
        int utf8_state = UTF8_1;
        for (size_t i = 0; i < len; ++i)
        {
            ch = buffer[i];
            char_cnt[ch].second++;

            // Check for binary data (including UTF-16/32)
            if (is_non_text(ch))
            {
                if (!is_binary && !(ch == DOS_EOF && i == len - 1))
                {
                    is_binary = true;
                }
                if (ch == NUL)
                {
                    // Count for NULs in even- and odd-number bytes
                    nul_count_byte[i & 1]++;
                    if (i & 1)
                    {
                        if (buffer[i - 1] == NUL)
                        {
                            // Count for NULs in even- and odd-number words
                            nul_count_word[(i / 2) & 1]++;
                        }
                    }
                }
            }

            // Check for UTF-8 validity
            if (is_valid_utf8)
            {
                switch (utf8_char_table[ch])
                {
                case UTF8_INVALID:
                    is_valid_utf8 = false;
                    break;
                case UTF8_1:
                    if (utf8_state != UTF8_1)
                    {
                        is_valid_utf8 = false;
                    }
                    break;
                case UTF8_2:
                    if (utf8_state != UTF8_1)
                    {
                        is_valid_utf8 = false;
                    }
                    else
                    {
                        utf8_state = UTF8_2;
                    }
                    break;
                case UTF8_3:
                    if (utf8_state != UTF8_1)
                    {
                        is_valid_utf8 = false;
                    }
                    else
                    {
                        utf8_state = UTF8_3;
                    }
                    break;
                case UTF8_4:
                    if (utf8_state != UTF8_1)
                    {
                        is_valid_utf8 = false;
                    }
                    else
                    {
                        utf8_state = UTF8_4;
                    }
                    break;
                case UTF8_TAIL:
                    if (utf8_state > UTF8_1)
                    {
                        utf8_state--;
                    }
                    else
                    {
                        is_valid_utf8 = false;
                    }
                    break;
                }
            }

            // Check whether non-Latin1 characters appear
            if (is_valid_latin1)
            {
                if (ch >= 0x80 && ch < 0xa0)
                {
                    is_valid_latin1 = false;
                }
            }

            // Construct double-bytes and count
            if (last_ch != EOF)
            {
                uint16_t dbyte_char = (last_ch << 8) + ch;
                mp_dbyte_char_cnt[dbyte_char]++;
                dbyte_cnt++;
                if (last_ch > 0xa0 && ch > 0xa0)
                {
                    dbyte_hihi_cnt++;
                }
                last_ch = EOF;
            }
            else if (ch >= 0x80)
            {
                last_ch = ch;
            }
        }

        // Get the character counts in descending order
        sort(char_cnt, char_cnt + MAX_CHAR, greater_char_count());

        //   if (verbose)
        //   {
        //     print_char_cnt(char_cnt);
        //   }

        // Get the double-byte counts in descending order
        vector<char_count_t> dbyte_char_cnt;
        for (map<uint16_t, size_t>::iterator it = mp_dbyte_char_cnt.begin();
                it != mp_dbyte_char_cnt.end(); ++it)
        {
            dbyte_char_cnt.push_back(*it);
        }
        sort(dbyte_char_cnt.begin(),
             dbyte_char_cnt.end(),
             greater_char_count());

        //    if (verbose)
        //    {
        //      print_dbyte_char_cnt(dbyte_char_cnt);
        //      printf("\n");
        //      printf("%u characters\n", len);
        //      printf("%u double-byte characters\n", dbyte_cnt);
        //      printf("%u double-byte hi-hi characters\n", dbyte_hihi_cnt);
        //      printf("%u unique double-byte characters\n", dbyte_char_cnt.size());
        //    }

        if (!is_valid_utf8 && is_binary)
        {
            // Heuristics for UTF-16/32
            if        (nul_count_byte[EVEN] > 4 &&
                       (nul_count_byte[ODD] == 0 ||
                        nul_count_byte[EVEN] / nul_count_byte[ODD] > 20))
            {
                return "utf-16";
            }
            else if (nul_count_byte[ODD] > 4 &&
                     (nul_count_byte[EVEN] == 0 ||
                      nul_count_byte[ODD] / nul_count_byte[EVEN] > 20))
            {
                return "utf-16le";
            }
            else if (nul_count_word[EVEN] > 4 &&
                     (nul_count_word[ODD] == 0 ||
                      nul_count_word[EVEN] / nul_count_word[ODD] > 20))
            {
                return "ucs-4";   // utf-32 is not a built-in encoding for Vim
            }
            else if (nul_count_word[ODD] > 4 &&
                     (nul_count_word[EVEN] == 0 ||
                      nul_count_word[ODD] / nul_count_word[EVEN] > 20))
            {
                return "ucs-4le"; // utf-32le is not a built-in encoding for Vim
            }
            else
            {
                return "binary";
            }
        }
        else if (dbyte_cnt == 0)
        {
            // No characters outside the scope of ASCII
            return "ascii";
        }
        else if (is_valid_utf8)
        {
            // Only valid UTF-8 sequences
            return "UTF-8";
        }
        else if (const char *enc = check_freq_dbytes(dbyte_char_cnt))
        {
            if (strcmp(enc, "gbk") == 0 && dbyte_hihi_cnt == dbyte_cnt)
            {
                // Special case for GB2312: no high-byte followed by a low-byte
                return "gb2312";
            }
            return enc;
        }
        else if (dbyte_hihi_cnt * 100 / dbyte_cnt < 5)
        {
            // Mostly a low-byte follows a high-byte
            return "windows-1252";
        }
        return NULL;
    }

    const char *tellenc(const char *const buffer, const size_t len)
    {
        const char *enc = tellenc2((const unsigned char *const)buffer, len);
        if (is_valid_latin1 && enc && strcmp(enc, "windows-1252") == 0)
        {
            // Latin1 is subset of Windows-1252
            return "latin1";
        }
        else
        {
            return enc;
        }
    }


    const char *filecoding(const char *filename)
    {

        FILE *fp = fopen(filename, "rb");
        if (fp == NULL)
        {
            cout << "Can not detect, use UTF-8 instead." << std::endl;
            const char *chardefault = "UTF-8";
            return chardefault;
        }

        char buffer[TELLENC_BUFFER_SIZE];
        size_t len;
        len = fread(buffer, 1, sizeof buffer, fp);
        fclose(fp);

        init_utf8_char_table();
        if (const char *enc = tellenc(buffer, len))
        {
            return enc;
        }
        else
        {
            cout << "Can not detect, use UTF-8 instead." << std::endl;
            const char *chardefault = "UTF-8";
            return  chardefault;

        }
    }

}
