public/index.xml: pages/*.rkt posts/*.rkt *.rkt
	racket -y main.rkt

.PHONY: clean
clean:
	rm -fr public

.PHONY: deploy
# deploy: public/index.xml
# 	rsync -avz --delete public/* defn:~/www

save: public/index.xml
	git add -A && git commit -am "save" && git push

deploy: save
	cp -r public/* ../evalwhen.github.io
	cd ../evalwhen.github.io && git add -A && git commit -am "publish" && git push
