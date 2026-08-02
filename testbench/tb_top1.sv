`timescale 1ns/1ps

module tb_top1;

parameter DATA_WIDTH = 8;
parameter ACC_WIDTH  = 32;
parameter N = 8;
parameter IDX_WIDTH = 3;

reg clk;
reg reset;
reg start;

reg [N*N*DATA_WIDTH-1:0] A;
reg [N*N*DATA_WIDTH-1:0] B;

wire [N*N*ACC_WIDTH-1:0] C;
wire done;
wire busy;

integer errors;

top #(
    .DATA_WIDTH(DATA_WIDTH),
    .ACC_WIDTH(ACC_WIDTH),
    .N(N),
    .IDX_WIDTH(IDX_WIDTH)
) DUT (
    .clk(clk),
    .reset(reset),
    .start(start),
    .A(A),
    .B(B),
    .C(C),
    .done(done),
    .busy(busy)
);

// Clock
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Task test cho trường hợp A, B đều cùng một giá trị
task run_uniform_case;
    input integer case_no;
    input signed [DATA_WIDTH-1:0] a_val;
    input signed [DATA_WIDTH-1:0] b_val;
    input signed [ACC_WIDTH-1:0] expected;

    integer k;
    integer case_errors;

begin
    case_errors = 0;

    // Reset core trước mỗi case
    reset = 1'b1;
    start = 1'b0;
    A = 0;
    B = 0;

    repeat (3) @(posedge clk);
    reset = 1'b0;

    repeat (2) @(posedge clk);

    // Nạp A, B
    A = {N*N{a_val}};
    B = {N*N{b_val}};

    // Pulse start 1 clock
    @(posedge clk);
    start = 1'b1;

    @(posedge clk);
    start = 1'b0;

    // Chờ core tính xong
    wait (done == 1'b1);

    // Đợi thêm 1 clock cho ổn định
    @(posedge clk);

    // Check toàn bộ 64 output
    for (k = 0; k < N*N; k = k + 1) begin
        if ($signed(C[k*ACC_WIDTH +: ACC_WIDTH]) !== expected) begin
            $display("CASE %0d ERROR: C[%0d] = %0d, expected = %0d",
                     case_no,
                     k,
                     $signed(C[k*ACC_WIDTH +: ACC_WIDTH]),
                     expected);
            case_errors = case_errors + 1;
            errors = errors + 1;
        end
    end

    if (case_errors == 0) begin
        $display("CASE %0d PASSED: A=%0d, B=%0d, C=%0d",
                 case_no, a_val, b_val, expected);
    end else begin
        $display("CASE %0d FAILED: %0d errors",
                 case_no, case_errors);
    end

    $display("busy = %0b, done = %0b", busy, done);
   

    repeat (2) @(posedge clk);
end
endtask

initial begin
    $dumpfile("top1.vcd");
    $dumpvars(0, tb_top1);

    reset = 1'b1;
    start = 1'b0;
    A = 0;
    B = 0;
    errors = 0;

    // CASE 1:
    // A = 1, B = 1
    // C = 1*1 cộng 8 lần = 8
    run_uniform_case(1, 8'sd1, 8'sd1, 32'sd8);

    // CASE 2:
    // A = 0, B = 1
    // C = 0
    run_uniform_case(2, 8'sd0, 8'sd1, 32'sd0);

    // CASE 3:
    // A = -1, B = 1
    // C = -1*1 cộng 8 lần = -8
    run_uniform_case(3, -8'sd1, 8'sd1, -32'sd8);

    // CASE 4:
    // A = 2, B = -3
    // C = 2*(-3) cộng 8 lần = -48
    run_uniform_case(4, 8'sd2, -8'sd3, -32'sd48);

    // CASE 5:
    // A = -2, B = -2
    // C = (-2)*(-2) cộng 8 lần = 32
    run_uniform_case(5, -8'sd2, -8'sd2, 32'sd32);

    if (errors == 0)
        $display("ALL TEST CASES PASSED");
    else
        $display("TEST FAILED: total errors = %0d", errors);

    $finish;
end

endmodule
