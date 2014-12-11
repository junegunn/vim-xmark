all: xsize

xsize: main.cc
	g++ -framework ApplicationServices $^ -o $@

clean:
	rm -f xsize

.PHONY: all clean

