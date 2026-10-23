.PHONY: validate test lint

validate: lint test

lint:
	scripts/lint.sh

test:
	tests/lint.test.sh
