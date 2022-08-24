platform=$(shell uname)

ifeq ($(platform),Linux)
 
else ifeq ($(platform),Darwin)
 
else
        CC= gcc
endif

ifeq ($(platform),Linux)
        LIBEXT=so
else ifeq ($(platform),Darwin)
        LIBEXT=dylib
else
        LIBEXT=dll
endif

demo: libcjieba.$(LIBEXT)
	$(CC) $(CFLAGS) -O2 -shared -fPIC C_source.c $(LDFLAGS) $(LINKLIBS) -L./ -lcjieba -lstdc++ -lm -o libdemo.$(LIBEXT)

libcjieba.$(LIBEXT):
	$(CXX) -DLOGGER_LEVEL=LL_WARN -fPIC -std=c++11 -o c_api.o -c src/c_api.cpp
	$(CXX) -DLOGGER_LEVEL=LL_WARN -fPIC -std=c++11 -o detect.o -c src/detect.cpp
	ar rs libcjieba.$(LIBEXT) c_api.o detect.o

clean:
	-rm libdemo.$(LIBEXT)

.PHONY: \
	demo
