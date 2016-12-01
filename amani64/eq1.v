module eq1(data,address,clock,rw,ce);

localparam D_SIZE = 7; // 8-bit
localparam A_SIZE = 1; // 2-bit

inout wire [D_SIZE:0] data;
input wire [A_SIZE:0] address;
input wire rw, ce, clock;

// Registers
reg [D_SIZE:0] r0, r1, r2, r3;  // GPR
reg [D_SIZE:0] cr;              // Current register on bus

always @(negedge clock)
  begin
    case ({ce, rw, address}) // 0 => read, 1 => write
      // Getter
      4'b1000:  cr = r0;
      4'b1001:  cr = r1;
      4'b1010:  cr = r2;
      4'b1011:  cr = r3;

      // Setter
      4'b1100:  r0   = data;
      4'b1101:  r1   = data;
      4'b1110:  r2   = data;
      4'b1111:  r3   = data;

      // ce = 0, data is just ´z´
      default: cr = {8{1'bz}};
    endcase
  end

assign data = cr;

endmodule
