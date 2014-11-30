bootstrap:

	@echo "\nSetting up API Keys, leave blank if you don't know."

	@printf '\nWhat is your Ello API Client Secret? '; \
		read ELLO_CLIENT_SECRET; \
		bundle exec pod keys set ElloAPIClientSecret "$$ELLO_CLIENT_SECRET" Ello

	@printf '\nWhat is your Ello API Client Key? '; \
		read ELLO_CLIENT_KEY; \
		bundle exec pod keys set ElloAPIClientKey "$$ELLO_CLIENT_KEY"

	bundle
	bundle exec pod install