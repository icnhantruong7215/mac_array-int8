module mac #(
parameter DATA_WIDTH = 8,
parameter ACC_WIDTH = 32,
parameter N = 8 
)(
input signed [N*DATA_WIDTH-1:0] A,
input signed [N*N*DATA_WIDTH-1:0] B,
output signed [N*ACC_WIDTH-1:0] C
);

genvar i,j;

generate
	for (j=0;j<N;j=j+1) begin :col
	wire signed [(N+1)*ACC_WIDTH-1:0] psum_bus;// N+1 tại lấy kết quả sau mỗi lần tính 8 lần tính thì phải xong lần thứ 8 tổng hợp ở lần thứ 9 

   assign psum_bus[ACC_WIDTH-1:0] = {ACC_WIDTH{1'b0}};// Psum = 0 thôi 

   for (i = 0; i < N; i = i + 1) begin : row

	wire signed [DATA_WIDTH-1:0] A_i;
	wire signed [DATA_WIDTH-1:0] B_ij;
	wire signed [ACC_WIDTH-1:0]  pin_i;
	wire signed [ACC_WIDTH-1:0]  pout_i;

	assign A_i  = A[i*DATA_WIDTH +: DATA_WIDTH];
	assign B_ij = B[(i*N + j)*DATA_WIDTH +: DATA_WIDTH];

	assign pin_i = psum_bus[i*ACC_WIDTH +: ACC_WIDTH];

pe #(
.DATA_WIDTH(DATA_WIDTH),
.ACC_WIDTH(ACC_WIDTH)
) u_pe (
.A(A_i),
.B(B_ij),
.pin(pin_i),
.pout(pout_i)
);

	assign psum_bus[(i+1)*ACC_WIDTH +: ACC_WIDTH] = pout_i;
end
   assign C[j*ACC_WIDTH +: ACC_WIDTH] = psum_bus[N*ACC_WIDTH +: ACC_WIDTH];

end
endgenerate

endmodule
