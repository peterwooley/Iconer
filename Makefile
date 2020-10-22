test:
	luacheck -d . && xmllint --noout *.xml

test-pre-commit:
	luacheck -q -d --formatter plain . && xmllint --noout *.xml
