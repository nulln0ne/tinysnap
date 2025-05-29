NAME     = tinysnap
SRC      = main.m
OBJ      = $(SRC:.m=.o)
CC       = clang
CFLAGS   = -Wall -Wextra -O2
LDFLAGS  = -framework Cocoa -framework Carbon -framework ApplicationServices

PREFIX   = /usr/local
BIN      = $(PREFIX)/bin

APPNAME  = $(NAME).app
APPDIR   = $(APPNAME)/Contents
APPBIN   = $(APPDIR)/MacOS/$(NAME)
PLIST    = $(APPDIR)/Info.plist
ICON     = icon.icns
ICON_DST = $(APPDIR)/Resources/$(ICON)

LAUNCH_AGENT       = org.$(NAME).plist
LAUNCH_AGENT_PATH  = $(HOME)/Library/LaunchAgents/$(LAUNCH_AGENT)

all: $(NAME)

config.h:
	cp config.def.h config.h

$(NAME): config.h $(OBJ)
	$(CC) $(CFLAGS) -o $@ $(OBJ) $(LDFLAGS)

clean:
	rm -f $(OBJ) $(NAME)

distclean: clean
	rm -f config.h
	rm -rf "$(APPNAME)"

install: $(NAME)
	mkdir -p "$(BIN)"
	install -m 755 $(NAME) "$(BIN)/$(NAME)"

uninstall:
	rm -f "$(BIN)/$(NAME)"

.PHONY: app
app: $(APPBIN) $(PLIST) $(ICON_DST)

$(APPBIN): $(NAME)
	mkdir -p "$(APPDIR)/MacOS"
	cp -f $(NAME) "$(APPBIN)"
	chmod +x "$(APPBIN)"

$(PLIST):
	mkdir -p "$(APPDIR)"
	printf '%s\n' \
		'<?xml version="1.0" encoding="UTF-8"?>' \
		'<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' \
		'<plist version="1.0">' \
		'<dict>' \
		'  <key>CFBundleName</key><string>$(NAME)</string>' \
		'  <key>CFBundleIdentifier</key><string>org.$(NAME)</string>' \
		'  <key>CFBundleVersion</key><string>1.0</string>' \
		'  <key>CFBundleExecutable</key><string>$(NAME)</string>' \
		'  <key>CFBundleIconFile</key><string>$(ICON)</string>' \
		'  <key>LSUIElement</key><true/>' \
		'</dict>' \
		'</plist>' > "$(PLIST)"

$(ICON_DST): $(ICON)
	mkdir -p "$(APPDIR)/Resources"
	cp -f $(ICON) "$(ICON_DST)"

.PHONY: autostart
autostart: app
	mkdir -p "$(HOME)/Library/LaunchAgents"
	printf '%s\n' \
		'<?xml version="1.0" encoding="UTF-8"?>' \
		'<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' \
		'<plist version="1.0">' \
		'<dict>' \
		'  <key>Label</key><string>org.$(NAME)</string>' \
		'  <key>ProgramArguments</key>' \
		'  <array>' \
		'    <string>$(HOME)/$(APPNAME)/Contents/MacOS/$(NAME)</string>' \
		'  </array>' \
		'  <key>RunAtLoad</key><true/>' \
		'</dict>' \
		'</plist>' > "$(LAUNCH_AGENT_PATH)"
	launchctl unload "$(LAUNCH_AGENT_PATH)" 2>/dev/null || true
	launchctl load "$(LAUNCH_AGENT_PATH)"

.PHONY: uninstall-autostart
uninstall-autostart:
	launchctl unload "$(LAUNCH_AGENT_PATH)" 2>/dev/null || true
	rm -f "$(LAUNCH_AGENT_PATH)"
