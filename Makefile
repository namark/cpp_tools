
CPPFLAGS	+= --std=c++1z
override CPPFLAGS	+= -MMD -MP
override CPPFLAGS	+= -I./include
override CPPFLAGS	+= $(shell cat .cxxflags 2> /dev/null | xargs)
LDLIBS		+= -lstdc++fs

ifneq ($(shell cat COPYRIGHT 2> /dev/null),)
COPYRIGHT ?= COPYRIGHT
else
COPYRIGHT ?= /dev/null
endif

PREFIX	:= $(DESTDIR)/usr/local
INCDIR	:= $(PREFIX)/include
BINDIR	:= $(PREFIX)/bin

SOURCES	:= $(wildcard *.cpp)
SCRIPTS	:= $(shell find -name *.sh)
MAKETMP	:= $(wildcard make_templates/*)
INCLUDE	:= $(MAKETMP:%=$(INCDIR)/%)
TEMPDIR	:= temp
DISTDIR := out
OUT		:= $(SOURCES:%.cpp=$(DISTDIR)/%)
TARGET	:= $(OUT:$(DISTDIR)/%=$(BINDIR)/%)
TARGET	+= $(SCRIPTS:%.sh=$(BINDIR)/%)
OBJECTS	:= $(SOURCES:%.cpp=$(TEMPDIR)/%.o)
DEPENDS	:= $(OBJECTS:.o=.d)

build: $(OUT)

$(DISTDIR)/%: $(TEMPDIR)/%.o | $(DISTDIR)
	$(CXX) $(LDFLAGS) $< $(LDLIBS) -o $@

$(TEMPDIR)/%.o: %.cpp | $(TEMPDIR)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -o $@ -c $<

$(TEMPDIR):
	@mkdir -p $@

$(DISTDIR):
	@mkdir -p $@

clean:
	@rm $(DEPENDS) 2> /dev/null || true
	@rm $(OBJECTS) 2> /dev/null || true
	@rmdir -p $(TEMPDIR) 2> /dev/null || true
	@echo Temporaries cleaned!

distclean: clean
	@rm $(OUT) 2> /dev/null || true
	@rmdir -p $(DISTDIR) 2> /dev/null || true
	@echo All clean!

install: $(TARGET) $(INCLUDE)
	@echo Install complete!

$(INCDIR)/make_templates/%: ./make_templates/% $(COPYRIGHT)
	@mkdir -p $(@D)
	cat $(COPYRIGHT) > $@ 2> /dev/null || true
	cat $< >> $@

$(BINDIR)/%: $(DISTDIR)/% | $(BINDIR)
	install --strip $< $@

$(BINDIR)/%: ./%.sh | $(BINDIR)
	install $< $@

$(BINDIR):
	@mkdir -p $@

uninstall:
	-rm $(TARGET)
	-rm $(INCLUDE)
	@rmdir -p $(BINDIR) 2> /dev/null || true
	@rmdir -p $(shell dirname $(INCLUDE)) 2> /dev/null || true
	@echo Uninstall complete!

-include $(DEPENDS)

.PRECIOUS : $(OBJECTS)
.PHONY : clean distclean uninstall
