build:
	hugo --minify

clean: 
	rm -r public

run: 
	hugo server --disableFastRender -D

pull: 
	git pull && git submodule update --remote --merge

push: pull
	git add . && git commit -m "Update" && git push
