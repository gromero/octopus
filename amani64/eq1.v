/*
module eq1 #(D_SIZE=8, A_SIZE=19) (data,address,clock,rw,ce);

localparam D_SIZE1 = D_SIZE - 1;
localparam A_SIZE1 = A_SIZE - 1;

inout wire [D_SIZE1:0] data;
input wire [A_SIZE1:0] address;
input wire rw, ce, clock;

// Memory matrix. 4 PowerPc instructions.
reg [D_SIZE1:0] r0 , r1 , r2 , r3 ;  // GPRs
reg [D_SIZE1:0] r4 , r5 , r6 , r7 ;  // GPRs
reg [D_SIZE1:0] r8 , r9 , r10, r11;  // GPRs
reg [D_SIZE1:0] r12, r13, r14, r15;  // GPRs

reg [D_SIZE1:0] cr;              // Current register on bus

always @(negedge clock)
  begin
    // Please, note that as cases are not complete,
    // a latch or some kind of memory is implicit in
    // that sort of contructo.
    case ({ce, rw, address}) // 0 => read, 1 => write
      // Store data bus value into register accordingly to the address.
      //ce=1,rw=0    padding     addr
      {2'b10, {A_SIZE-2{1'b0}}, 2'b00}:  cr = r0; // GPR 0
      {2'b10, {A_SIZE-2{1'b0}}, 2'b01}:  cr = r1; // GPR 1
      {2'b10, {A_SIZE-2{1'b0}}, 2'b10}:  cr = r2; // GPR 2
      {2'b10, {A_SIZE-2{1'b0}}, 2'b11}:  cr = r3; // GPR 3

      // Load data bus from register value accordingly to the address.
      //ce=1,rw=1    padding     addr
      {2'b11, {A_SIZE-2{1'b0}}, 2'b00}:  r0   = data; // GPR 0
      {2'b11, {A_SIZE-2{1'b0}}, 2'b01}:  r1   = data; // GPR 1
      {2'b11, {A_SIZE-2{1'b0}}, 2'b10}:  r2   = data; // GPR 2
      {2'b11, {A_SIZE-2{1'b0}}, 2'b11}:  r3   = data; // GPR 3

      // ce = 0, data is just high impedance.
      default: cr = {D_SIZE{1'bz}};
    endcase  
  end

// Effectively route put cr to the data bus.  
assign data = cr;
 
endmodule
*/

module reset_vector_address_prober #(ADDR_N=19, DATA_N=8) (address, x_data, _e, _g, i_addr, _o_data, i_clk, s);

// NOP 0x60000000
// addr[0] = 0x60
// addr[1] = 0x00
// addr[2] = 0x00
// addr[3] = 0x00
// addr[4] = 0x00
// addr[5] = 0x00
// addr[6] = 0x00 	
// addr[7] = 0x00 

localparam ADDR_N1 = ADDR_N - 1;
localparam DATA_N1 = DATA_N - 1;

input wire [ADDR_N1:0] address;  // Address inputs
output wire [DATA_N1:0] x_data;    // Data outputs
input wire _e;                   // _Chip Enable
input wire _g;                   // _Output Enable

reg [DATA_N1:0] data; // data bus value

output wire [1:0] _o_data;
input wire [4:0] i_addr;
input wire i_clk;
output wire s;
reg [1:0] o_data;

reg [ADDR_N1:0] reset_addr = 19'h4BEEF;   // First requested addrees ;-)
reg _s = 1'b0;                            // Set bit


always @*
  begin
    case ({_e, _g, address[2:0]})
      5'b00000: data = 8'h60;
      5'b00001: data = 'h00;
      5'b00010: data = 'h00;
      5'b00011: data = 'h00;
      5'b00100: data = 'h00;
      5'b00101: data = 'h00;
      5'b00110: data = 'h00;
      5'b00111: data = 'h00;
      default : data = 8'bz;
    endcase

   // Grab first asked address and
   // store it´s value in reset_addr;
   if (_e == 1'b0)
    if (_g == 1'b0)
      if (_s == 1'b0)
        reset_addr = address;
  end

always @(negedge i_clk)
  begin
    case (i_addr)
      5'b00000: o_data = reset_addr[1:0];
      5'b00001: o_data = reset_addr[3:2];
      5'b00010: o_data = reset_addr[5:4];
      5'b00011: o_data = reset_addr[7:6];
      5'b00100: o_data = reset_addr[9:8];
      5'b00101: o_data = reset_addr[11:10];
      5'b00110: o_data = reset_addr[13:12];
      5'b00111: o_data = reset_addr[15:14];
      5'b01000: o_data = reset_addr[17:16];
      5'b01001: o_data = {1'b0, reset_addr[18]};
      default: o_data = {5{1'bz}}; // 5 must be parametrized.
    endcase
  end

assign s = _s;
assign x_data = data;
assign _o_data  = o_data;

endmodule
