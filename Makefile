.PHONY: lua

format:
	npx @johnnymorganz/stylua-bin \
		--config-path ./.stylua.toml \
		--glob '*.lua' \
		./lua
