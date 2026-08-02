module top #(
parameter DATA_WIDTH = 8 ,
parameter ACC_WIDTH = 32,
parameter N =8,
parameter IDX_WIDTH = 3
)(
input clk,
input reset,
input start,
input [N*N*DATA_WIDTH-1:0] A,B,

output reg [N*N*ACC_WIDTH-1:0] C,
output reg done,
output reg busy
);

localparam IDLE =2'b00;
localparam RUN =2'b01;
localparam DONE =2'b10;

localparam A_WIDTH = N*DATA_WIDTH;
localparam C_WIDTH = N*ACC_WIDTH;

reg [1:0]state;
reg [IDX_WIDTH-1:0]row_idx;

wire [A_WIDTH-1:0]A_row;
wire [C_WIDTH-1:0]C_row;

assign A_row = A[row_idx*A_WIDTH +:A_WIDTH];
mac #(
.DATA_WIDTH(DATA_WIDTH),
.ACC_WIDTH(ACC_WIDTH),
.N(N)
) mac0 (
.A(A_row),
.B(B),
.C(C_row)
);


always @(posedge clk or posedge reset) begin
if (reset) begin
state <= IDLE;
row_idx <= 0;
C <= {(N*N*ACC_WIDTH){1'b0}};
busy <= 1'b0;
done <= 1'b0;
end 
// IDLE 
else begin 
case (state)
IDLE :begin
busy <= 1'b0;
done <= 1'b0;
if (start) begin 
state <= RUN;
row_idx <= 0;
C <= {(N*N*ACC_WIDTH){1'b0}};
busy <= 1'b1;
done <= 1'b0;
end 
end 
//RUN
RUN : begin
busy <= 1'b1;
done <= 1'b0;
C[row_idx*C_WIDTH +:C_WIDTH ] <= C_row;

if ( row_idx == {IDX_WIDTH{1'b1}} ) begin
state <= DONE ;
busy <= 1'b0;
done <= 1'b1;
end 
else begin
row_idx <= row_idx +1 ;
end 
end 
//DONE 
DONE : begin 
busy <= 1'b0;
done <= 1'b1;

if (~start) begin 
state <= IDLE ;
done <=1'b0;
end 
end

default : begin
state <= IDLE;
row_idx <= 0;
C <= {(N*N*ACC_WIDTH){1'b0}};
busy <= 1'b0;
done <= 1'b0;
end 
endcase
end 
end
endmodule 
