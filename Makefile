.PHONY: lua

format:
	npx @johnnymorganz/stylua-bin \
		--glob '*.lua' \
		./lua
