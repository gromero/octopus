`define D_SIZE 31

module eq1(
          input wire  [1:0] addr,
          output wire [`D_SIZE:0] data,
          input wire rw,
          input wire clk
         );

         reg [`D_SIZE:0] r0;     // Register r0
         reg [`D_SIZE:0] r1;     // Register r1
         reg [`D_SIZE:0] r2;     // Register r2
         reg [`D_SIZE:0] r3;     // Register r3
         reg [`D_SIZE:0] i_data; // Output register

         always @(negedge clk)
         begin // always block

         if (rw == 1'b0) // rw = 0 (set memory content)
           i_data = (addr == 2'b00) ? r0 :
                    (addr == 2'b01) ? r1 :
                    (addr == 2'b10) ? r2 : r3;

         else            // rw = 1 (get memory content)
           if (addr == 2'b00)
             r0 = data;
           else if (addr == 2'b01)
             r1 = data;
           else if (addr == 2'b10)
             r2 = data;
           else          // addr == 11
             r3 = data;

         end // always block

          assign data = i_data;
endmodule
