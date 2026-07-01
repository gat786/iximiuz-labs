buildpacks:
	labctl content push -fw tutorial creating-docker-images-without-writing-dockerfiles-using-buildpacks-4c989678

buildpacks-upload-sample:
	#!/bin/bash
	cd creating-docker-images-without-writing-dockerfiles-using-buildpacks-4c989678/
	zip -r python-app.zip -x="python-app/.venv/**" -x="python-app/__pycache__/**" python-app
	npx wrangler r2 object put gats-dev-source-codes/buildpacks/sample-python-app.zip --file python-app.zip
