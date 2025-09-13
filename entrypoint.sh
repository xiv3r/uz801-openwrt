#!/bin/sh
set -e

chown -R builder:bilder /home/builder/openwrt/dl \
                    /home/builder/openwrt/bin \
                    /home/builder/openwrt/build_dir

exec "$@"
