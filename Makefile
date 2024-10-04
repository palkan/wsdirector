default: test

nextify:
	bundle exec rake nextify

test: nextify
	bundle exec rspec

lint:
	bundle exec rubocop

.PHONY: pure-release
pure-release:
	@echo "Executing pure-release target"
	RELEASING_ANYWAY=true gem release wsdirector-core -t
	RELEASING_ANYWAY=true gem release wsdirector-cli

release: test lint pure-release
	git push
	git push --tags

ci-release: nextify pure-release
