module addr8 (
  input            [7:0] inA,
  input            [7:0] inB,
  output     logic [7:0] out,
  output           logic cout);
  
  logic             cin12;
  logic             cin23;
  logic             cin34;
  logic             cin45;
  logic             cin56;
  logic             cin67;
  logic             cin78;
  
  addr1 addr1_a(
    .ina       ( inA[0] ),
    .inb       ( inB[0] ),
    .cin       ( 1'b0   ),
    .sum       ( out[0] ), 
    .cout      ( cin12  ));
    
  addr1 addr1_b(
    .ina       ( inA[1] ),
    .inb       ( inB[1] ),
    .cin       ( cin12  ),
    .sum       ( out[1] ), 
    .cout      ( cin23  ));

  addr1 addr1_c(
    .ina       ( inA[2] ),
    .inb       ( inB[2] ),
    .cin       ( cin23   ),
    .sum       ( out[2] ), 
    .cout      ( cin34  ));
    
  addr1 addr1_d(
    .ina       ( inA[3] ),
    .inb       ( inB[3] ),
    .cin       ( cin34  ),
    .sum       ( out[3] ), 
    .cout      ( cin45  )); 
    
  addr1 addr1_e(
    .ina       ( inA[4] ),
    .inb       ( inB[4] ),
    .cin       ( cin45  ),
    .sum       ( out[4] ), 
    .cout      ( cin56  ));

  addr1 addr1_f(
    .ina       ( inA[5] ),
    .inb       ( inB[5] ),
    .cin       ( cin56   ),
    .sum       ( out[5] ), 
    .cout      ( cin67  ));
    
  addr1 addr1_g(
    .ina       ( inA[6] ),
    .inb       ( inB[6] ),
    .cin       ( cin67  ),
    .sum       ( out[6] ), 
    .cout      ( cin78  ));   
    
  addr1 addr1_h(
    .ina       ( inA[7] ),
    .inb       ( inB[7] ),
    .cin       ( cin78  ),
    .sum       ( out[7] ), 
    .cout      ( cout  ));   

endmodule



module addr1 (
  input              ina,
  input              inb, 
  input              cin,
  output       logic cout,
  output       logic sum);  

  assign {cout,sum} =  cin + inb + ina;
 
endmodule
 
 

