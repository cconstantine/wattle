#Timeout after 20 minutes
TIMEOUT=timeout -s SIGKILL 1200

#The number 3 is used to signify the number of cpus to use.
#Optimal running seems to use about 3/4 of cpus (Jenkins currently has 4 cpus)
test: tmp
	bundle install
	rake log:clear
	rake db:test:prepare
	rake spec:fixture_builder:rebuild
	$(TIMEOUT) bundle exec rake spec

tmp:
	mkdir tmp

.PHONY: test
