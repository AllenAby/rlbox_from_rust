all: hello.o

clean:
	rm -rf ./src/hello/*.o

hello.o: ./src/hello/hello.cpp
	$(CXX) -std=c++17 -c -o ./src/hello/hello.o ./src/hello/hello.cpp