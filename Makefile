EMACS_URI=https://github.com/emacs-mirror/emacs/archive/emacs-25.1-rc1.tar.gz
BUILD_DIR=/tmp/restaurant-release
ARCHIVE_NAME=$(shell basename ${EMACS_URI})

## f*king github with its name conventions!
SOURCE_DIR=emacs-$(shell basename ${EMACS_URI} .tar.gz)
RUBY=$(shell which ruby)
BUNDLE=$(shell which bundle)
RVM=$(shell which rvm)
RESTAURANT_VERSION=$(shell grep autoconf-anchor rc/version.el | cut -d\" -f2 | tr -d \\n)

all: build clean-build clean

emacs:
	@echo "Making temporary working directory ${BUILD_DIR}"
	@mkdir -p ${BUILD_DIR}/emacs-build
	@mkdir -p ${BUILD_DIR}/restaurant
	@echo "Getting emacs archive..."
	@test -f ${ARCHIVE_NAME} || curl -L --progress-bar ${EMACS_URI} > ${ARCHIVE_NAME}
	@cp ${ARCHIVE_NAME} ${BUILD_DIR}
	@echo "Unpacking emacs archive..."
	@tar -C ${BUILD_DIR} -xf ${BUILD_DIR}/${ARCHIVE_NAME}
	@echo "Building emacs..."
	@cd ${BUILD_DIR}/${SOURCE_DIR} && \
	autoreconf -fi -I m4 ## emacs 25
	cd ${BUILD_DIR}/${SOURCE_DIR} && \
	./configure --prefix=/ --with-x-toolkit=gtk3 --without-pop --without-gif --without-png --without-jpeg --without-tiff --without-makeinfo && \
	make && \
	make install DESTDIR=${BUILD_DIR}/emacs-build
	@echo "Preparing to working state..."
	@cp -r ${BUILD_DIR}/${SOURCE_DIR}/lib-src/ ${BUILD_DIR}/emacs-build/lib-src/
	@mv -f ${BUILD_DIR}/emacs-build/share/emacs/25.1/* ${BUILD_DIR}/emacs-build/
	@mv -f ${BUILD_DIR}/emacs-build/share/man/ ${BUILD_DIR}/emacs-build/
	@mv -f ${BUILD_DIR}/emacs-build/share/info/ ${BUILD_DIR}/emacs-build/
	@echo "Stripping from unneded files..."
	@rm -rf ${BUILD_DIR}/emacs-build/share/
	@rm -rf ${BUILD_DIR}/emacs-build/var/
	@find ${BUILD_DIR}/emacs-build/ -type f -name '*.el.gz' -delete
	@echo "Moving to current directory as ''emacs''..."
	@mv ${BUILD_DIR}/emacs-build/ emacs

el-get: emacs
	@echo "Getting required dependencies via el-get..."
	@emacs/bin/emacs -Q --debug-init --script ./bootstrap.el

build: el-get
	@echo "Building restaurant..."
	@cd scripts && ./build_all
	@chmod 755 restaurant
	@cat el-get/robe-mode/Gemfile >> Gemfile
	@touch build

bootstrap: build
	@echo "Chekcing if all needed components are installed..."
ifneq ($(RUBY),yes)
	@echo "ERROR: there is no ruby in system. Exiting" && exit 1
endif
ifneq ($(BUNDLE),yes)
	@echo "ERROR: there is no ruby in system. Exiting" && exit 1
endif
	@echo "Building restaurant starting dependencies..."
	@cd bundle install
ifeq ($(RVM),yes)
	@echo "Generating RI documentation..."
	@rvm docs generate
endif
	@touch bootstrap

install: build
	@echo install

clean-build:
	@echo "Clearing build directory..."
	@[ -d ${BUILD_DIR} ] && rm -rf ${BUILD_DIR} || return 0

clean:
	@echo "Clearing working directory..."
	@rm -rf autom4te.cache config.log conf18498.dir config.status
	@find . -type f -name '*~' -delete
	@find . -type f -name '*#$$' -delete
	@find . -type f -name '*^#*' -delete

clean-emacs: clean-build
	@rm -rf emacs

mrproper: clean-emacs clean
	@echo "Clearing emacs 3rt-party data dirs..."
	@rm -rf build el-get elpa configure Gemfile.lock ${ARCHIVE_NAME} Gemfile share

package: build clean-build clean
	@echo "Building package..."
	@mkdir -p ${BUILD_DIR}/restaurant/
	@for i in restaurant bootstrap.el data init.el LICENSE rc README.md el-get elpa emacs share Gemfile; do cp -rp $$i ${BUILD_DIR}/restaurant/; done
	@touch ${BUILD_DIR}/restaurant/build
	@echo "Stripping package from unneded files..."
	@find ${BUILD_DIR}/restaurant/ -type d -name '.git' -exec rm -rf {} +
	@find ${BUILD_DIR}/restaurant/ -type f -name '.gitignore' -delete
	# TODO: add external libraries
	@echo "Packaging..."
	@cd ${BUILD_DIR} && tar -czpf restaurant-${RESTAURANT_VERSION}-gtk3.tar.gz restaurant
	@cp ${BUILD_DIR}/restaurant-${RESTAURANT_VERSION}-gtk3.tar.gz .

release: package clean-emacs clean

help:
	@echo "Restaurant Chef IDE v. ${RESTAURANT_VERSION}"
	@echo "Options:"
	@echo "       all targets: $(shell cat Makefile | grep -E '^[a-z].*\:' | cut -d: -f1| tr ":" " ")"
	@echo
	@echo "       most important targets:"
	@echo "       build       - build restaurant (w/o emacs. Just bootstrap)"
	@echo "       install     - install restaurant (not implemented yet. Just local usage)"
	@echo "       emacs       - build emacs locally to work with restaurant"
	@echo "       release     - perform completely building and packaging restaurant"
	@echo "       clean       - clean working directory from unndeded files"
	@echo "       mrproper    - perform fully cleaning. Leaving only files, required for"
	@echo "                     building restaurant (Restaurant will not works after that)"
