module eq1 #(ADDRESS_BUS_SIZE=3, DATA_BUS_SIZE=8) (scl, sda);

localparam ADDRESS_BUS_SIZE1   = ADDRESS_BUS_SIZE - 1;
localparam DATA_BUS_SIZE1      = DATA_BUS_SIZE - 1;
localparam MEMORY_SIZE         = 2 ** ADDRESS_BUS_SIZE;
localparam MEMORY_SIZE1        = MEMORY_SIZE - 1;
localparam COMMAND_SIZE        = 1 + 1 + ADDRESS_BUS_SIZE + DATA_BUS_SIZE + 1; // START+RD_RW+ADDRESS+DATA+STOP
localparam COMMAND_SIZE1       = COMMAND_SIZE -1;
localparam COMMAND_BIT_SIZE    = COMMAND_SIZE ** (1/2);

input wire scl;
inout wire sda;

reg reg_sda;

reg rd_wr;
reg rd_wr_state = 1'b0;

reg [DATA_BUS_SIZE1:0] memory [0:MEMORY_SIZE1];

reg [4:0] bit_counter = 5'h0;
reg [18:0] memory_address = 19'h0;
reg [2:0] memory_bit_offset;

always @ (posedge scl)
begin
  if (sda == 1'b0 && bit_counter == 5'd0)
  begin
    bit_counter = bit_counter + 1;
  end 
  else if (bit_counter == 5'd1)
  begin
    rd_wr = sda;
    bit_counter = bit_counter + 1;
  end
  else if (bit_counter <= 5'd21)
  begin
    memory_address = {memory_address[17:0], sda};
    bit_counter = bit_counter + 1;
  end
  else if (bit_counter <= 5'd29)
  begin
    if (rd_wr == 0)          // WRITE DATA TO MEMORY
    begin
      rd_wr_state = 1'b0;
      memory_bit_offset = bit_counter - 5'd22;
      memory[memory_address][memory_bit_offset] = sda;
      bit_counter = bit_counter + 1;
    end
    else  // rd_rw == 1      // READ DATA FROM MEMORY
    begin
      rd_wr_state = 1'b1;
      memory_bit_offset = bit_counter - 5'd22;
      reg_sda = memory[memory_address][memory_bit_offset];
      bit_counter = bit_counter + 1;
    end
  end
  else
  begin
    rd_wr_state = 1'b0;
    bit_counter = 5'd0;
  end
end

assign sda = rd_wr_state ? reg_sda : 1'bZ;

endmodule

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
/*
module eq1 #(ADDR_N=19, DATA_N=8) (address, x_data, _e, _g, i_addr, _o_data, i_clk, s);

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
output wire [DATA_N1:0] x_data;  // Data outputs
input wire _e;                   // _Chip Enable (not inverted yet)
input wire _g;                   // _Output Enable (not inverted yet)

// CE and OE are active low. If invertion is not made
// right from the input wire we are in trouble.
assign __e = ~_e;                // Chip Enable (active low).
assign __g = ~_g;                // Output Enable (ative low).

reg [DATA_N1:0] data;            // Data read from bus.

output wire [1:0] _o_data;
input wire [4:0] i_addr;
input wire i_clk;
output wire s;
reg [1:0] o_data;

reg [ADDR_N1:0] reset_addr = 19'h4ABCD;   // Default value, if never set
reg _s = 1'b0;                         // Set bit


reg [7:0] data_memory [0:524287];
reg [ADDR_N1:0] address_memory [0:524287];
reg [3:0] address_counter = 4'h0;


initial
begin
  integer k;
  // zero memory with program
  for (k = 0; k < 524288; k = k + 1)
    data_memory[k] = 8'h0;

  // zero memory with addresses record
  for (k = 0; k < 524288; k = k + 1)
    address_memory[k] = 8'h0;
end


always @(negedge __g)
  begin
    case (address[2:0])
		5'b000: data = 8'h60;
		5'b001: data = 8'h00;
		5'b010: data = 8'h00;
		5'b011: data = 8'h00;
		5'b100: data = 8'h00;
		5'b101: data = 8'h00;
		5'b110: data = 8'h00;
		5'b111: data = 8'h00;
		default : data = 8'bz;
	 endcase

	 // Grab first asked address and
	 // store it´s value into reset_addr;
    if (__e == 1'b0)
	   if (_s == 1'b0)
      begin
		  reset_addr = address;
        _s = 1'b1;
      end
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
*/
/* WORKS
module eq1(data,bank,clk);

output wire [3:0] data;
input wire bank, clk;

reg [3:0] internal_data;

always @(negedge clk)
  begin
    case (bank)
      0: internal_data = 4'hA;
		1: internal_data = 4'hB;
    endcase
  end

assign data = internal_data;

endmodule
*/

/*
module adder #(SIZE=8) (in0,in1,out,c);

localparam SIZE1 = SIZE - 1;

input wire [SIZE1:0] in0, in1;
output wire [SIZE1:0] out;
output wire c;

assign {c, out}  = in0 + in1;

endmodule

module eq1(in0, in1, out, c);

localparam BUS_SIZE = 4;
localparam BUS_SIZE1 = BUS_SIZE - 1;

input wire [BUS_SIZE1:0] in0, in1;
output wire [BUS_SIZE1:0] out;
output wire c;


adder #(4) unit0 (.in0(in0), .in1(in1), .c(c));

endmodule
*/
