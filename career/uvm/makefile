name=test

all:
	@mkdir -p $(name)/
	@mkdir -p $(name)/uvm_model
	@mkdir -p $(name)/c_model
	@mkdir -p $(name)/rtl
	@cp -r test_bench $(name)
	@python run.py $(name)
	@echo "Please modify"
	@echo "           $(name)/uvm_model/$(name)_pkg.sv"

clean:
	rm -rf $(name) 
