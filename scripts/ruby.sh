#!/bin/bash

. config.in

RSPEC_MODE_URL="https://github.com/pezra/rspec-mode/archive/master.zip"
ERUBY_URL="https://raw.githubusercontent.com/cosmonaut-ok/emacs-eruby-mode/master/eruby-mode.el"
BUNDLER_URL="https://raw.githubusercontent.com/tobiassvn/bundler.el/master/bundler.el"

function pkg_install
{
    get_url_with_name rspec-mode.zip $RSPEC_MODE_URL
    get_url_with_name eruby-mode.el $ERUBY_URL
    get_url_with_name bundler.el $BUNDLER_URL
    extract rspec-mode.zip
    copy_to_local eruby-mode.el ruby
    copy_to_local bundler.el ruby
    copy_to_local "rspec-mode-master/*" rspec-mode
}


function pkg_update
{
    :
}

. include.in
