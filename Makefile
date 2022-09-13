default: test

nextify:
	bundle exec rake nextify

test: nextify
	bundle exec rspec

lint:
	bundle exec rubocop

release: test lint
	RELEASING_ANYWAY=true gem release wsdirector -t
	RELEASING_ANYWAY=true gem release wsdirector-cli
	git push
	git push --tags
