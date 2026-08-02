module pe #(
parameter DATA_WIDTH = 8,
parameter ACC_WIDTH = 32
)(
input signed [DATA_WIDTH-1:0] A ,
input signed [DATA_WIDTH-1:0] B ,
input signed [ACC_WIDTH-1:0] pin,

output signed [ACC_WIDTH-1:0] pout
);
 
 wire signed [2*DATA_WIDTH-1:0] multi;
 wire signed [ACC_WIDTH-1:0] multi_exp;
 
 assign multi = $signed(A) * $signed(B);

 assign multi_exp = {{(ACC_WIDTH - 2*DATA_WIDTH){multi[2*DATA_WIDTH-1]}},multi};

 assign pout = multi_exp + pin;
  
 endmodule 
