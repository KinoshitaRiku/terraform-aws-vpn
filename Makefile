# {簡略化コマンド}:
# 	{実行コマンド(コマンドは1つ以上)}

# Windowsだと一部の簡略化コマンドが動かないので、各コマンドを手動実行してください。

help: 
	@echo "Available make commands:"
	@awk -F: '/^[a-zA-Z_]+:/ { print $$1 }' Makefile

build:
	docker-compose build

up:
	docker-compose up -d

down:
	docker-compose down --rmi all

##########
# backend
##########
init:
	cd tf && terraform init -upgrade

plan:
	cd tf && terraform plan
