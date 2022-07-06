default: test

test:
	bundle exec rspec

lint:
	bundle exec rubocop

release: test lint
	gem release wsdirector -t
	gem release wsdirector-cli
	git push
	git push --tags
