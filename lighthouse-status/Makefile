target=$(file <target)

.PHONY: deploy
deploy: build
	rsync --chmod=D0755,F0644 --perms -rP build/ $(target)

.PHONY: build
build:
	yarn build
