module tas (
  input                 clk_50, // 50Mhz input clock
  input                 clk_2, // 2Mhz input clock
  input                 reset_n, // reset async active low
  input                 serial_data, // serial input data
  input                 data_ena, // serial data enable
  output   logic        ram_wr_n, // write strobe to ram
  output   logic [7:0]  ram_data, // ram data
  output   logic [10:0] ram_addr); // ram address
  
  logic [39:0] shift_reg_out;
  logic [31:0] temp_out;
  logic [7:0] addout_a;
  logic [7:0] addout_b;  
  logic [7:0] addout;
  logic [7:0] avg_out; 
  logic [1:0] cout;
  logic cout_a;
  logic cout_b;
  logic cout_c;
  logic cnt_en;
  logic shift_clear;
  logic avg_sft_in;
  logic avg_sft_en;
  logic avg_load_en;
  logic val_pac; 
  logic valid_packet;
  logic [7:0] sft_cnt;
  logic sft_cnt_dn;
  

  shift_reg #(. width (40)) shift_reg0 (
    . reset_n    ( (!shift_clear)||(reset_n) ),
    . clk        ( clk_50        ),
    . enable     ( data_ena      ),
    .shift_in    ( serial_data   ),
    . dout       ( shift_reg_out ));  
    
  mpr_reg #(. width (32)) in_reg_1(
    . reset_n    ( reset_n       ),
    . clk        ( clk_50        ),
    . enable     ( val_pac       ),
    . din        ( shift_reg_out[39:8] ), 
    . dout       ( temp_out      ));  
    
  l_shift_reg #(. width (8)) l_shift_reg0 (
    . reset_n    ( reset_n       ),
    . clk        ( clk_2         ),
    . enable     ( avg_load_en   ),
    . shift      ( avg_sft_en    ),
    . shift_in   ( avg_sft_in    ),
    . din        ( addout        ), 
    . dout       ( ram_data      ));  
    
  addr8 addr8_12(
    .inA       ( temp_out[7:0]   ),
    .inB       ( temp_out[15:8]  ),
    .out       ( addout_a        ), 
    .cout      ( cout_a          ));
    
  addr8 addr8_34(
    .inA       ( temp_out[23:16] ),
    .inB       ( temp_out[31:24] ),
    .out       ( addout_b        ), 
    .cout      ( cout_b          ));  

  addr8 addr8_agv(
    .inA       ( addout_a        ),
    .inB       ( addout_b        ),
    .out       ( addout          ), 
    .cout      ( cout_c          ));  
    
  down_counter #(. cntFrom (11'h7FF)) down_counter_0(
    .reset_n          ( reset_n ),
    .enable           ( cnt_en   ),
    .clk              ( clk_2    ),
    .count            ( ram_addr ),
    .done             (          ));
    
   up_counter #(. cntTo (40)) up_counter_sft(
    .reset_n          ( reset_n ),
    .enable           ( data_ena ),
    .clk              ( clk_50     ),
    .count            ( sft_cnt ),
    .done             ( sft_cnt_dn  )); 
 
  assign cout = cout_a + cout_b + cout_c;
  
  enum reg [1:0] {
    CHECK = 2'b00,
    MOV   = 2'b10,
    CLEAR = 2'b11
  } reg_ps, reg_ns;

  always_ff @(posedge clk_50, negedge reset_n)
    if (!reset_n) reg_ps <= CHECK;
    else reg_ps <= reg_ns;
  
  
  always_comb begin 
    reg_ns = CHECK;
    unique case (reg_ps)
      CHECK: begin 
        if(!reset_n) reg_ns = CLEAR;
        else if (sft_cnt_dn) 
          if((shift_reg_out[7:0]==8'hA5)||(shift_reg_out[7:0]==8'hC3))
            reg_ns = MOV;
          else 
            reg_ns = CLEAR;          
        else reg_ns = CHECK;  
      end
      MOV: begin 
        reg_ns = CLEAR; 
      end
      CLEAR: begin
        reg_ns = CHECK;
      end
    endcase
  end  

  always_comb begin
    val_pac = 1'b0;
    shift_clear = 1'b0;    
    unique case (reg_ps)
      CHECK: begin 
        shift_clear = 1'b0;
        val_pac = 1'b0; 
      end
      MOV: begin 
        val_pac = 1'b1; 
      end
      CLEAR: begin
        val_pac = 1'b0;
        shift_clear = 1'b1;
      end
    endcase
  end  

  always_comb begin
    if (val_pac) valid_packet = 1'b1;
    else if (ram_wr_n) valid_packet = 1'b0;
  end   
  
 enum reg [2:0]{
    IDLE   = 3'b000,
    DELAY  = 3'b100,
    SHIFT0 = 3'b010,
    SHIFT1 = 3'b011,
    DONE   = 3'b001
    }sft_ns, sft_ps;

//moves present state to next state
always_ff @(posedge clk_2, negedge reset_n)
  if (!reset_n) sft_ps <= IDLE;
  else sft_ps <= sft_ns;

//Core state machine (outputs below)
always_comb begin
  sft_ns = IDLE;       //default _ns WAIT
  unique case (sft_ps)
      IDLE: begin
        if (valid_packet) sft_ns = DELAY;
      end
      DELAY: sft_ns = SHIFT0;
      SHIFT0: begin
        sft_ns = SHIFT1;
      end
      SHIFT1: begin
        sft_ns = DONE;
      end
      DONE: begin
        sft_ns = IDLE;
      end
    endcase
  end      
  
  
  always_comb begin
    cnt_en = 1'b0;
    avg_sft_en <= 1'b0;
    avg_sft_in = 1'b0; 
    avg_load_en = 1'b0;   
    ram_wr_n = 1'b0;
    unique case (sft_ps)
      IDLE: begin
        cnt_en = 1'b0;
      end
      DELAY: if (valid_packet) avg_load_en = 1'b1; 
      SHIFT0: begin    
        avg_sft_in = cout[0];
        avg_sft_en <= 1'b1;
      end
      SHIFT1: begin
        avg_sft_in = cout[1];
        avg_sft_en <= 1'b1;
      end
      DONE: begin
        ram_wr_n = 1'b1;
        cnt_en = 1'b1;
        avg_sft_en <= 1'b0;
      end
    endcase
  end      
 endmodule   
    
  
    
    
    
    