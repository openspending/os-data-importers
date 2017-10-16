.PHONY: update-eu-structural-funds

update-eu-structural-funds:
	git subtree pull \
		--prefix eu-structural-funds \
		https://github.com/os-data/eu-structural-funds.git \
		master \
		--squash
