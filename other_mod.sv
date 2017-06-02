module l_shift_reg #(parameter width=8)(

   input             reset_n,
   input             clk,
   input             enable,
   input             shift,
   input             shift_in,
   input             [width-1:0] din,
   output      logic [width-1:0] dout );
   
   reg               [width-1:0] dreg;
   
   always @(posedge clk, negedge reset_n)
     if (!reset_n)       dout = 0;
     else if (enable)    dout = din; 
     else if (shift)     begin
        dout = dout >> 1;
        dout[width-1] = shift_in;
     end   
endmodule

module shift_reg #(parameter width=8)(

   input             reset_n,
   input             clk,
   input             enable,
   input             shift_in,
   output      logic [width-1:0] dout );
   
   always @(posedge clk, negedge reset_n)
     if (!reset_n) dout[width-3:0] = 0;
     else if (enable) begin
        dout = dout >> 1;
        dout[width-1] = shift_in;
     end        
endmodule  

module mpr_reg #(parameter width=8)(

   input             reset_n,
   input             clk,
   input             enable,
   input             [width-1:0] din,
   output      logic [width-1:0] dout );
   
   always @(posedge clk, negedge reset_n)
     if (!reset_n)       dout[width-1:0] = 0;
     else if (enable) dout = din;   
endmodule 

  


module up_counter #(parameter cntTo = 32) (
  input              reset_n,
  input              enable,
  input              clk,
  output       logic [7:0] count = 0,
  output       logic done);
  
  
  always @(posedge clk, negedge reset_n)
    if (!reset_n) count = 'b0;
    else if (done) count = 'b0;
    else if (enable) count = count + 1;
  
  always_comb begin 
     if (count > (cntTo-1)) done = 1'b1;
     else done = 1'b0;     
  end
endmodule  

module down_counter #(parameter cntFrom = 32) (
  input              reset_n,
  input              enable,
  input              clk,
  output       logic [10:0] count,
  output       logic done);
  
  
  always @(posedge clk, negedge reset_n)
    if (!reset_n) count = 8'b0;
    else if (done) count = cntFrom;
    else if (enable) count = count - 1;
    
  always_comb begin 
     if (count < (1)) done = 1'b1;
     else done = 1'b0;     
  end
endmodule 
