module eq1 
(
	input wire i0, i1, arduino_input,
	output wire eq, cpld_output
);

// signal declaration
wire p0, p1;

// body
// sum of two product terms
assign eq = p0 | p1;
// product terms
assign p0 = ~i0 & ~i1;
assign p1 = i0 & i1;

// follow Arduino blink led
assign cpld_output = arduino_input;

endmodule
