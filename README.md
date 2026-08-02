# MAC Array INT8 cho NPU Fallback

Đề tài này hiện thực một khối tính toán số dạng **MAC Array INT8** dùng cho NPU Fallback. Thiết kế được mô tả bằng Verilog HDL, kiểm tra chức năng bằng Verilator và triển khai vật lý bằng OpenLane trên công nghệ SKY130.

## 1. Tổng quan đề tài

Thiết kế tập trung vào datapath tính toán nhân - cộng ma trận, trong đó mỗi phần tử đầu ra được tạo từ phép dot-product giữa một hàng của ma trận đầu vào `A` và một cột của ma trận trọng số `B`.

Thiết kế được tổ chức theo hướng top-down gồm ba module chính:

- `top.v`: module điều khiển cấp cao, sử dụng FSM IDLE/RUN/DONE.
- `mac.v`: mảng MAC thực hiện phép dot-product.
- `pe.v`: Processing Element thực hiện nhân INT8 có dấu và cộng dồn 32-bit.

Cấu hình trong báo cáo và OpenLane fullflow là:

- Kích thước mảng: `N = 2`
- Số PE: `2 × 2 = 4`
- Độ rộng dữ liệu: INT8
- Độ rộng tích lũy: 32-bit
- Công nghệ: SKY130
- Standard cell library: `sky130_fd_sc_hd`

Cấu hình `N = 2` được sử dụng như một bản proof-of-concept để hoàn tất đầy đủ luồng RTL-to-GDSII. Thiết kế có thể mở rộng lên các kích thước lớn hơn như `N = 8`, tuy nhiên cần tối ưu thêm về IO, routing, pipeline hoặc bộ nhớ cục bộ.

## 2. Cấu trúc thư mục

```text
.
├── README.md
├── src/
│   ├── top.v
│   ├── mac.v
│   └── pe.v
├── testbench/
│   └── tb_top1.sv
├── OpenLane/
│   └── config.tcl
├── results/
│   ├── metrics.csv
│   ├── synthesis_summary.txt
│   ├── sta_summary.txt
│   ├── power_summary.txt
│   ├── signoff_summary.txt
│   └── tb_top1_verilator_result.txt
└── images/
    ├── klayout_layout.png
    ├── waveform.png
    └── fsm_top.png
