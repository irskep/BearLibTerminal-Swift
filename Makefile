.PHONY: docs

docs:
	jazzy \
		-o docs \
		--clean \
		--no-skip-undocumented \
		--sdk macosx \
		--xcodebuild-arguments -project,BearLibTerminal.xcodeproj,-target,BearLibTerminal \
		--author "Steve Johnson" \
		--author_url "http://steveasleep.com" \
		--module-version 1.0.5 \
		--copyright "2018 Steve Johnson" \
		--root-url "http://steveasleep.com/BearLibTerminal-Swift" \
		--github_url "https://github.com/irskep/BearLibTerminal-Swift"

deploydocs: docs
	ghp-import docs -npm "Update docs"
