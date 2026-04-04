#
# tools makefile
#
.PHONY: lint update install apps cleanapps

uname := $(shell uname)

lint:
	@hash shellcheck 2>/dev/null || { echo '*  shellcheck not found in $$PATH'; exit 1; }
ifeq (Darwin,$(uname))
	@find -E . -type f -regex ".*\.(ba)?sh" -not -name "*.inc.sh" | xargs shellcheck
endif
ifeq (Linux,$(uname))
	@find . -regextype egrep -type f -regex ".*\.(ba)?sh" -not -name "*.inc.sh" | xargs shellcheck
endif

update:
	@if [[ -d .git ]]; then \
  		git pull; \
  	fi
	@if [[ -r install.bash ]]; then \
  		bash install.bash prompt || true; \
  	fi

install:
	[[ -r install.bash ]] && { bash install.bash prompt || true; }

apps:
	cd apps/wtselect && CGO_ENABLED=0 go build -v

cleanapps:
	cd apps/wtselect && go clean
