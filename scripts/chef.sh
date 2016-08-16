#!/bin/bash

. config.in

CHEF_MODE_URL="https://raw.githubusercontent.com/cosmonaut-ok/chef-mode/master/chef-mode.el"
CHEF_URL="https://raw.githubusercontent.com/cosmonaut-ok/emacs-chef/master/chef.el"
KITCHEN_URL="https://raw.githubusercontent.com/cosmonaut-ok/test-kitchen-el/master/test-kitchen.el"
KNIFE_URL="https://raw.githubusercontent.com/bryanwb/knife-mode/master/knife.el"
BERKS_URL="https://raw.githubusercontent.com/restaurant-ide/berkshelf.el/master/berkshelf.el"

function pkg_install
{
    _PWD=`pwd`
    cd $TMP
    get_url_with_name chef.el $CHEF_URL chef.el
    get_url_with_name chef-mode.el $CHEF_MODE_URL chef-mode.el
    get_url_with_name test-kitchen.el $KITCHEN_URL test-kitchen.el
    get_url_with_name knife.el $KNIFE_URL knife.el
    get_url_with_name berkshelf.el $BERKS_URL berkshelf.el
    mkdir $DST/chef
    cp chef.el $DST/chef
    cp chef-mode.el $DST/chef
    cp test-kitchen.el $DST/chef
    cp knife.el $DST/chef
    cp berkshelf.el $DST/chef
    cd $_PWD
    $RM -rf $TMP
}


function pkg_update
{
    :
}

. include.in
