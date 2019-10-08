CC=gcc
SRC=airport-bssid/main.m
FRAMEWORKS:= -framework Foundation -framework CoreWLAN
LIB:= -lobjc
CFLAGS=-Wall -Werror -v
TARGET=Build/airport-bssid

$(TARGET): builddir $(OBJECTS)
	$(CC) -o $(OBJECTS) $@ $(CFLAGS) $(LIB) $(FRAMEWORKS) -o $(TARGET) $(SRC)

builddir:
	mkdir -p Build

.m.o:
	$(CC) -c -Wall $< -o $@

clean:
	rm -f $(TARGET)

all: $(SRC) $(TARGET)
