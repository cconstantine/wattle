#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.
set -x # Show commands as they are executed

TIMEOUT="timeout -s SIGKILL 1200"

bundle install
rake log:clear db:drop db:create db:migrate db:test:prepare
rake spec:fixture_builder:rebuild
$(TIMEOUT) bundle exec rake spec
