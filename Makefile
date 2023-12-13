SRCS:=		$(shell find . -name '*.jsonnet' | sed 's:^\./::')
MAIN=		karabiner.jsonnet
LIBS=		$(shell find lib -name '*.libsonnet')
TARGET=		karabiner.json
DESTDIR=	$(HOME)/.config/karabiner

all: build
	@:

init:
	defaults write -g InitialKeyRepeat -int 25
	defaults write -g KeyRepeat -int 1
# Disable Command+Control+D; requires reboot
	defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 70 '<dict><key>enabled</key><false/></dict>'
# F18 toggles IM
	defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 '<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>79</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>'

build: $(TARGET)

.SUFFIXES: .json .jsonnet

.jsonnet.json:
	bin/generate $< > $@

$(TARGET): $(LIBS)

diff: $(TARGET)
	diff -u $(TARGET) $(DESTDIR)/$(TARGET)

install: $(TARGET)
	install -m 600 $(TARGET) $(DESTDIR)/$(TARGET)
