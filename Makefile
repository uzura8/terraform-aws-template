CD = cd ./

deploy:
	@${CD} && \
		sh ./build.sh && \
		terraform apply && \
		sh lex_deploy.sh

destroy:
	@${CD} && \
		sh ./lex_destroy.sh && \
		terraform destroy
