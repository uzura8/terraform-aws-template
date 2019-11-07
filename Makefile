CD = cd ./

deploy:
	@${CD} && \
		sh bin/build_lambda_file.sh && \
		terraform apply && \
		sh bin/lex_deploy.sh

destroy:
	@${CD} && \
		sh bin/lex_destroy.sh && \
		terraform destroy
