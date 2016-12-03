module eq1 #(D_SIZE=8, A_SIZE=2) (data,address,clock,rw,ce);

localparam D_SIZE1 = D_SIZE - 1;
localparam A_SIZE1 = A_SIZE - 1;

inout wire [D_SIZE1:0] data;
input wire [A_SIZE1:0] address;
input wire rw, ce, clock;

// Registers, same size of data bus.
reg [D_SIZE1:0] r0, r1, r2, r3;  // General purpose registers.
reg [D_SIZE1:0] cr;              // Current register on data bus.

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

// Effectively route out cr to the data bus.
assign data = cr;

endmodule
