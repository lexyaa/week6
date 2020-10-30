
//practice01

//hms_cnt
module hms_cnt(
               o_hms_cnt,
               o_max_hit,
               i_max_cnt,
               clk,
               rst_n          );

output [5:0]   o_hms_cnt       ;
output         o_max_hit       ;

input  [5:0]   i_max_cnt       ;
input          clk             ;
input          rst_n           ;

reg    [5:0]   o_hms_cnt       ;
reg            o_max_hit       ;

always @(posedge clk or negedge rst_n) begin
       if(rst_n == 1'b0) begin
                o_hms_cnt <= 6'd0;
                o_max_hit <= 1'b0;
       end else begin
                if(o_hms_cnt >= i_max_cnt) begin
                          o_hms_cnt <= 6'd0;
                          o_max_hit <= 1'b1;
                end else begin
                          o_hms_cnt <= o_hms_cnt + 1'b1;
                          o_max_hit <= 1'b0;
                end
       end
end
endmodule

//minsec
module minsec( o_sec,
               o_min,
               o_max_hit_sec,
               o_max_hit_min,
               i_sec_clk,
               i_min_clk,
               clk,
               rst_n          );

output [5:0]   o_sec           ;
output [5:0]   o_min           ;
output         o_max_hit_sec   ;
output         o_max_hit_min   ;

input          i_sec_clk       ;
input          i_min_clk       ;

input          clk             ;
input          rst_n           ;

hms_cnt        u0_hms_cnt(
               .o_hms_cnt    ( o_sec         ),
               .o_max_hit    ( o_max_hit_sec ),
               .i_max_cnt    ( 6'd59         ),
               .clk          ( i_sec_clk     ),
               .rst_n        ( rst_n         ));

hms_cnt        u1_hms_cnt(
               .o_hms_cnt    ( o_min         ),
               .o_max_hit    ( o_max_hit_min ),
               .i_max_cnt    ( 6'd59         ),
               .clk          ( i_min_clk     ),
               .rst_n        ( rst_n         ));

endmodule

// Numerical Controlled Oscillator
module nco(     clk_gen,
                num,
                clk,
                rst_n    );

output          clk_gen   ;
input  [31:0]   num       ;
input           clk       ;
input           rst_n     ;

reg    [31:0]   cnt       ;
reg             clk_gen   ;
always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
                 cnt      <= 32'd0;
                 clk_gen  <= 1'd0;
        end else begin
                 if(cnt >= num/2-1) begin
                           cnt      <= 32'd0;
                           clk_gen  <= ~clk_gen;
                 end else begin
                           cnt <= cnt + 1'b1;
                 end
        end
end

endmodule

// Counter
module cnt60(  out,
               clk,
               rst_n );

output [5:0]   out          ;
input          clk          ;
input          rst_n        ;

reg    [5:0]   out          ;
always @(posedge clk or negedge rst_n) begin
       if(rst_n == 1'b0) begin
                out <= 6'd0;
       end else begin
                if(out >= 6'd59) begin
                       out <= 6'd0;
                end else begin
                       out <= out + 1'b1;
                end
       end

end

endmodule

// NCO Counter
module top_cnt(  out,
                 num,
                 clk,
                 rst_n  );

output [5:0]     out     ;
input  [31:0]    num     ;
input            clk     ;
input            rst_n   ;

wire             clk_gen ;

nco     nco_u0(  .clk_gen  ( clk_gen ),
                 .num      ( num     ),
                 .clk      ( clk     ),
                 .rst_n    ( rst_n   ));

cnt60   cnt_u0(  .out      ( out     ),
                 .clk      ( clk_gen ),
                 .rst_n    ( rst_n   ));

endmodule

//Double figure separate
module double_fig_sep(
              o_left,
              o_right,
              i_double_fig);

output [3:0]  o_left       ;
output [3:0]  o_right      ;

input  [5:0]  i_double_fig ;

assign o_left   = i_double_fig / 10;
assign o_right  = i_double_fig % 10;

endmodule

//FND Decoder
module fnd_dec( o_seg,
                i_num );

output [6:0]    o_seg  ;
input  [3:0]    i_num  ;

reg    [6:0]    o_seg  ;
always @(*) begin
       case(i_num)
            4'd0  : o_seg = 7'b1111_110;
            4'd1  : o_seg = 7'b0110_000;
            4'd2  : o_seg = 7'b1101_101;
            4'd3  : o_seg = 7'b1111_001;
            4'd4  : o_seg = 7'b0110_011;
            4'd5  : o_seg = 7'b1011_011;
            4'd6  : o_seg = 7'b1011_111;
            4'd7  : o_seg = 7'b1110_000;
            4'd8  : o_seg = 7'b1111_111;
            4'd9  : o_seg = 7'b1110_011;
            4'd10 : o_seg = 7'b1110_111;
            4'd11 : o_seg = 7'b1111_111;
            4'd12 : o_seg = 7'b1001_110;
            4'd13 : o_seg = 7'b1111_110;
            4'd14 : o_seg = 7'b1001_111;
            4'd15 : o_seg = 7'b1000_111;
            default o_seg = 7'b0000_000;
        endcase
end

endmodule

// LED Display
module led_disp( o_seg,
                 o_seg_dp,
                 o_seg_enb,
                 i_six_digit_seg,
                 i_six_dp,
                 clk,
                 rst_n      );

output [5:0]     o_seg_enb           ;
output           o_seg_dp            ;
output [6:0]     o_seg               ;

input  [41:0]    i_six_digit_seg     ;
input  [5:0]     i_six_dp            ;
input            clk                 ;
input            rst_n               ;

wire             gen_clk             ;
nco              u_nco(
                 .clk_gen  ( gen_clk  ),
                 .num      ( 32'd5000 ),
                 .clk      ( clk      ),
                 .rst_n    ( rst_n    ));

reg    [3:0]     cnt_common_node     ;
always @(posedge gen_clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
                 cnt_common_node <= 4'd0;
        end else begin
                 if(cnt_common_node >= 4'd5) begin
                        cnt_common_node <= 4'd0;
                 end else begin
                        cnt_common_node <= cnt_common_node + 1'b1;
                 end
        end
end

reg     [5:0]    o_seg_enb           ;
always @(cnt_common_node) begin
         case(cnt_common_node)
                 4'd0 : o_seg_enb = 6'b111110;
                 4'd1 : o_seg_enb = 6'b111101;
                 4'd2 : o_seg_enb = 6'b111011;
                 4'd3 : o_seg_enb = 6'b110111;
                 4'd4 : o_seg_enb = 6'b101111;
                 4'd5 : o_seg_enb = 6'b011111;
         endcase
end

reg              o_seg_dp            ;
always @(cnt_common_node) begin
         case(cnt_common_node)
                 4'd0 : o_seg_dp = i_six_dp[0];
                 4'd1 : o_seg_dp = i_six_dp[1];
                 4'd2 : o_seg_dp = i_six_dp[2];
                 4'd3 : o_seg_dp = i_six_dp[3];
                 4'd4 : o_seg_dp = i_six_dp[4];
                 4'd5 : o_seg_dp = i_six_dp[5];
         endcase
end

reg      [6:0]   o_seg               ;
always @(cnt_common_node) begin
         case(cnt_common_node)
                 4'd0 : o_seg = i_six_digit_seg[6:0];
                 4'd1 : o_seg = i_six_digit_seg[13:7];
                 4'd2 : o_seg = i_six_digit_seg[20:14];
                 4'd3 : o_seg = i_six_digit_seg[27:21];
                 4'd4 : o_seg = i_six_digit_seg[34:28];
                 4'd5 : o_seg = i_six_digit_seg[41:35];
         endcase
end

endmodule

//Debounce
module debounce(
               o_sw,
               i_sw,
               clk,
               o_sw );
output         o_sw           ;

input          i_sw           ;
input          clk            ;

reg            dly1_sw        ;
always @(posedge clk) begin
         dly1_sw <= i_sw;
end

reg            dly2_sw        ;
always @(posedge clk) begin
         dly2_sw <= dly1_sw;
end

assign           o_sw = dly1_sw | ~dly2_sw;

endmodule

//controller
module controller(
               o_mode,
               o_position,
               o_sec_clk,
               o_min_clk,
               i_sw0,
               i_sw1,
               i_sw2,
               i_max_hit_min,
               i_max_hit_sec,
               clk,
               rst_n          );

output         o_mode          ;
output         o_position      ;
output         o_sec_clk       ;
output         o_min_clk       ;

input          i_max_hit_min   ;
input          i_max_hit_sec   ;

input          i_sw0           ;
input          i_sw1           ;
input          i_sw2           ;

input          clk             ;
input          rst_n           ;

parameter      MODE_CLOCK = 1'b0      ;
parameter      MODE_SETUP = 1'b1      ;

parameter      POS_SEC = 1'b0         ;
parameter      POS_MIN = 1'b1         ;

wire           clk_slow               ;
nco            u_ncl_db(
               .clk_gen      ( clk_slow   ),
               .num          ( 32'd500000 ),
               .clk          ( clk        ),
               .rst_n        ( rst_n      ));

wire           sw0     ;
wire           sw1     ;
wire           sw2     ;
debounce       u_debouce0(
               .o_sw   ( sw0      ),
               .i_sw   ( i_sw0    ),
               .clk    ( clk_slow ));

debounce       u_debouce1(
               .o_sw   ( sw1      ),
               .i_sw   ( i_sw1    ),
               .clk    ( clk_slow ));

debounce       u_debouce2(
               .o_sw   ( sw2      ),
               .i_sw   ( i_sw2    ),
               .clk    ( clk_slow ));

reg            o_mode  ;
always @(posedge sw0 or negedge rst_n) begin
    if(rst_n == 1'b0) begin
         o_mode <= MODE_CLOCK;
    end else begin
         o_mode <= o_mode + 1'b1;
    end
end

reg            o_position   ;
always @(posedge sw1 or negedge rst_n) begin
    if(rst_n == 1'b0) begin
         o_position <= POS_SEC;
    end else begin
         if(o_position >= POS_MIN) begin
             o_position <= POS_SEC;
         end else begin
             o_position <= o_position + 1'b1;
         end
    end
end

wire     clk_1hz      ;
nco      u_nco(
         .clk_gen  (  clk_1hz        ),
         .num      (  32'd50000000   ),
         .clk      (  clk            ),
         .rst_n    (  rst_n          ));

reg      o_sec_clk    ;
reg      o_min_clk    ;
always @(*) begin
   case(o_mode)
      MODE_CLOCK : begin
          o_sec_clk <= clk_1hz;
          o_min_clk <= i_max_hit_sec;
      end
      MODE_SETUP : begin
      case(o_position)
          POS_SEC : begin
             o_sec_clk <= ~i_sw2;
             o_sec_clk <= ~sw2;
             o_min_clk <= 1'b0;
          end
          POS_MIN : begin
             o_sec_clk <= 1'b0;
             o_min_clk <= ~i_sw2;
             o_min_clk <= ~sw2;
          end
      endcase
      end
    endcase
end

endmodule

//Top hms clock
module top_hms_clock(
          o_seg,
          o_seg_dp,
          o_seg_enb,
          clk,
          i_sw0,
          i_sw1,
          i_sw2,
          rst_n              );

output [6:0] o_seg           ;
output       o_seg_dp        ;
output [5:0] o_seg_enb       ;

input        clk             ;
input        i_sw0           ;
input        i_sw1           ;
input        i_sw2           ;
input        rst_n           ;

wire         mode            ;
wire         position        ;
wire         sec_clk         ;
wire         min_clk         ;
wire         min_hit_sec     ;
wire         min_hit_min     ;

controller   u_ctrl(
             .o_mode         ( mode        ),
             .o_position     ( position    ),
             .o_sec_clk      ( sec_clk     ),
             .o_min_clk      ( min_clk     ),
             .i_max_hit_min  ( max_hit_min ),
             .i_max_hit_sec  ( max_hit_sec ),
             .i_sw0          ( i_sw0       ),
             .i_sw1          ( i_sw1       ),
             .i_sw2          ( i_sw2       ),
             .clk            ( clk         ),
             .rst_n          ( rst_n       ));

wire [5:0]   sec             ;
wire [5:0]   min             ;
minsec       u_minsec(
             .o_sec          ( sec         ),
             .o_min          ( min         ),
             .o_max_hit_sec  ( max_hit_sec ),
             .o_max_hit_min  ( max_hit_min ),
             .i_sec_clk      ( sec_clk     ),
             .i_min_clk      ( min_clk     ),
             .clk            ( clk         ),
             .rst_n          ( rst_n       ));

wire [3:0]   sec_left        ;
wire [3:0]   sec_right       ;
double_fig_sep u0_dfs(
             .o_left         ( sec_left    ),
             .o_right        ( sec_right   ),
             .i_double_fig   ( sec         ));

wire [3:0]   min_left        ;
wire [3:0]   min_right       ;
double_fig_sep u1_dfs(
             .o_left         ( min_left    ),
             .o_right        ( min_right   ),
             .i_double_fig   ( min         ));

wire [6:0]   sec_seg_l       ;
wire [6:0]   sec_seg_r       ;
fnd_dec      u0_fnd_dec(
             .o_seg          ( sec_seg_l   ),
             .i_num          ( sec_left    ));

fnd_dec      u1_fnd_dec(
             .o_seg          ( sec_seg_r   ),
             .i_num          ( sec_right   ));

wire [6:0]   min_seg_l       ;
wire [6:0]   min_seg_r       ;
fnd_dec      u2_fnd_dec(
             .o_seg          ( min_seg_l  ),
             .i_num          ( min_left   ));

fnd_dec      u3_fnd_dec(
             .o_seg          ( min_seg_r   ),
             .i_num          ( min_right   ));

wire [41:0]  i_six_digit_seg   ;
assign       i_six_digit_seg = { {2{7'd0}}, min_seg_l, min_seg_r, sec_seg_l, sec_seg_r };
led_disp     u_led_disp(
             .o_seg            ( o_seg           ),
             .o_seg_dp         ( o_seg_dp        ),
             .o_seg_enb        ( o_seg_enb       ),
             .i_six_digit_seg  ( i_six_digit_seg ),
             .i_six_dp         ( 6'd0            ),
             .clk              ( clk             ),
             .rst_n            ( rst_n           ));

endmodule
