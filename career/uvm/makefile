name=test

all:
	@mkdir -p ${name}/uvm_model/vip
	@mkdir -p ${name}/vectors/test
	@mkdir -p ${name}/cmodels
	@mkdir -p ${name}/rtl
	@mkdir -p ${name}/tb
	@cp -r template/test_bench/* ${name}/tb
	@cp template/makefile ${name}/makefile
	@touch ${name}/test.rc
	@python run.py ${name}

help:
	cat readme.txt
