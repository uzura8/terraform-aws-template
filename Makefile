CD = cd ./

deploy:
	@${CD} && \
		sh ./build.sh && \
		terraform apply
