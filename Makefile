format:
	find . -name "*.lua" | xargs lua-format -i

.PHONY: .format
