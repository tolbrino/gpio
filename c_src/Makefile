PRIVDIR := ../priv

LIB = $(PRIVDIR)/gpio_drv.so

OBJS = \
     gpio_drv.o \
     gpio_bcm2835.o

all : $(LIB)

override CFLAGS += -fpic -shared

$(LIB): $(OBJS)
	$(CC) -shared -fpic $(LDFLAGS) -o $@ $^

%.o: %.c
	$(CC) -c -o $@ $(CFLAGS) $<

clean:
	$(RM) -f $(LIB) $(OBJS)
