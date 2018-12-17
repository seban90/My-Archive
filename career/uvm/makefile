name=test

all:
	@mkdir -p $(name)/sim/
	@mkdir -p $(name)/sim/uvm_model
	@mkdir -p $(name)/sim/c_model
	@mkdir -p $(name)/rtl
	@cp -r template/test_bench $(name)/sim
	@python run.py $(name)
	@echo "Please modify"
	@echo "           $(name)/sim/uvm_model/$(name)_pkg.sv"

clean:
	rm -rf $(name) 
