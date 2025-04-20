# Define the base clock
#create_clock -name base_clk -period 20.0 [get_ports {CLOCK_50_B5B}]
create_clock -name base_clk -period 10.0 [get_ports {CLOCK_50_B5B}]

#derive_pll_clocks
#derive_clock_uncertainty
