-incdir ../verif/agents/control_agent
-incdir ../verif/agents/data_agent
-incdir ../verif/env
-incdir ../verif/tests

../rtl/lfsr.v

../verif/agents/control_agent/control_agent_pkg.sv
../verif/agents/data_agent/data_agent_pkg.sv

../verif/env/lfsr_env_pkg.sv

../verif/tests/lfsr_tests_pkg.sv


../verif/tb/lfsr_tb_pkg.sv
../verif/tb/tb_top.sv

-access +rwc
-sv
-gui 

-coverage all 
-covoverwrite