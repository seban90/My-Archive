ip_path := $(CURDIR)
DK_PATH := /DK
fsdb := 1
dump := 1
cov := 0

VCODE = ${ip_path}/vectors/test/vcode.f

#t := 1
#######################################################################################
RTL_CODES := $(ip_path)/rtl
#RTL_CODES := $(ip_path)/rtl_t${t}
#-syn_dir := syn_T${t}_$(shell date +%H%M%S)
#syn_dir := syn_T${t}_$(shell date +%Y%m%d_%H%M)
syn_dir := syn_$(shell date +%Y%m%d_%H%M)

TARGET := test.so
SOURCES := $(shell echo ${ip_path}/cmodels/*.c)
#######################################################################################
ifeq (${cov}, 0)
	opt_cov := 
else
	opt_cov = -covfile coverage_config_file.tcl -coverage all
endif
ifeq (${dump}, 0)
	opt_dump = 
else
ifeq (${fsdb}, 0)
	opt_dump = -input ncsim_shm.tcl ${opt_cov}
else
	opt_dump = -input ncsim_fsdb.tcl ${opt_cov}
endif
endif

UVM_FLAG = 
UVM_FLAG += -uvm

#######################################################################################
top := multiplier

TOP_DESIGN = $(top)

export ip_path
export DK_PATH
export RTL_CODES
export TOP_DESIGN
export syn_dir
#export t

all:
	make help


.PHONY: sim
sim:
	@if [ ! -e ./sim ]; then \
		mkdir sim; \
		cp test.rc sim/ ; \
		cp ~/SOC/nxip/ip_common/sim/novas_init.rc sim/novas.rc; \
		cp ~/SOC/nxip/ip_common/sim/ncsim_shm.tcl sim/ ; \
		cp ~/SOC/nxip/ip_common/sim/ncsim_fsdb.tcl sim/ ; \
	fi

ifeq (${cov}, 1)
	@if [ ! -e ./sim/coverage_config_file.tcl ]; then \
		cp ~/SOC/nxip/ip_common/sim/coverage_config_file.tcl sim/ ; \
	fi
endif
	make cc
	#${ip_path}/cmodels/a.out
	#-cd sim_T${t}; irun -access +rwc -timescale 1ns/1ps -f ${ip_path}/tb/vcode.f -input ncsim_shm.tcl -sv_lib ${ip_path}/cmodels/test.so
	#-cd sim_T${t}; time irun -access +rwc -timescale 1ns/1ps -f ${ip_path}/tb/vcode.f ${opt_dump} -sv_lib ${ip_path}/cmodels/test.so
	echo "# opt_dump : ${opt_dump}"
	#cd sim_T${t}; time irun -access +rwc -timescale 1ns/1ps -f ${ip_path}/tb/vcode.f -sv_lib ${ip_path}/cmodels/test.so ${opt_dump}
	cd sim; time irun -access +rwc -timescale 1ns/1ps -f ${VCODE} -sv_lib ${ip_path}/cmodels/test.so ${opt_dump} ${UVM_FLAG}

cc:
	cd ${ip_path}/cmodels; time gcc -shared -o ${TARGET} ${SOURCES} -fPIC

.PHONY: syn
syn:
	@if [ ! -e ./$(syn_dir) ]; then \
		mkdir -p $(syn_dir); \
		ln -s ../list.txt $(syn_dir)/list.txt ; \
	fi
	cd $(syn_dir); time dc_shell -no_gui -f $(ip_path)/scripts/run.tcl | tee syn.log
	ln -s $(syn_dir)/syn.log .

.PHONY: verdi
verdi:
	@if [ ! -e xxx.log ]; then \
		if [ -e ./sim/irun.log ]; then ln -s ./sim/irun.log xxx.log ; fi; \
	fi
	#-cd sim; vericom -lib test -f $(CURDIR)/vcode.f
	#-cd sim; verdi -f $(CURDIR)/vcode.f $(CURDIR)/sim/test.fsdb -sswr $(CURDIR)/sim/novas.rc &
	#-cd sim; verdi -f $(CURDIR)/vcode.f $(CURDIR)/sim/test.fsdb -sswr $(CURDIR)/sim/test.rc &
	#cd sim_T${t}; verdi -f $(ip_path)/tb/vcode.f $(ip_path)/sim_T${t}/test.fsdb -sswr $(ip_path)/sim_T${t}/test.rc &
	#cd sim; verdi -f $(ip_path)/tb/vcode.f $(ip_path)/sim/test.fsdb -sswr $(ip_path)/sim/test.rc &
	cd sim; verdi -f $(VCODE) $(ip_path)/sim/test.fsdb -sswr $(ip_path)/sim/test.rc &

.PHONY: verdi_init
verdi_init:
	#-cd sim; vericom -lib test -f $(CURDIR)/vcode.f
	#cd sim_T${t}; verdi -f $(CURDIR)/vcode.f $(CURDIR)/sim_T${t}/test.fsdb -sswr $(CURDIR)/sim_T${t}/novas.rc &
	cd sim; verdi -f $(CURDIR)/vcode.f $(CURDIR)/sim/test.fsdb -sswr $(CURDIR)/sim/novas.rc &

.PHONY: diff_check
diff_check:
	@echo "#################################################### ";
	@diff $(FILE1) $(FILE2) > diff.log; \
	make -f ~/SOC/nxip/ip_common/tools/makefile.diff meld_check FILE1="$(FILE1)" FILE2="$(FILE2)" ;

temp:
	@ls -al diff.log;

.PHONY: diff
diff:
	make diff_check FILE1="./.gitignore" FILE2="~/SOC/nxip/ip_common/.gitignore" ;
	make diff_check FILE1="./makefile"   FILE2="~/SOC/OJT/syn_mul01_study/makefile" ;
	make diff_check FILE1="./test.rc"    FILE2="~/SOC/OJT/syn_mul01_study/test.rc" ;

.PHONY: diff_old
diff_old:
	meld ./.gitignore ~/SOC/nxip/ip_common/.gitignore &
	meld ./makefile ~/SOC/OJT/syn_mul01_study/makefile &
	meld ./test.rc ~/SOC/OJT/syn_mul01_study/test.rc &

clean:
	rm -rf syn_*; rm -rf sim* *.log ./verdiLog

help:
	@echo "============================================================="
	@echo "How to make"
	@echo "============================================================="
	@echo "make sim : simulation start"
	@echo "make syn : synthesis start"
	@echo ""
	@echo ""
	@echo ""
