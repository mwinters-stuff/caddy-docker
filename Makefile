%/Dockerfile: %/base.img Dockerfile.tmpl
	gomplate -d base=$< -f Dockerfile.tmpl -o $@
