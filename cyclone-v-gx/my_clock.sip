set_global_assignment -entity "my_clock" -library "lib_my_clock" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "my_clock" -library "lib_my_clock" -name IP_TOOL_VERSION "23.1"
set_global_assignment -entity "my_clock" -library "lib_my_clock" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_my_clock" -name SPD_FILE [file join $::quartus(sip_path) "my_clock.spd"]

set_global_assignment -library "lib_my_clock" -name MISC_FILE [file join $::quartus(sip_path) "my_clock_sim/my_clock.vo"]
