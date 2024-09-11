
`timescale 1 ns / 1 ps

module axis_rle_interpreter #
(
  parameter integer AXIS_TDATA_WIDTH = 128
)
(
  input  wire                   aclk,
  input  wire                   aresetn,

  input  wire                   s_axis_tvalid,
  input  wire [AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
  output wire                   s_axis_tready,

  output wire                   m_axis_tvalid,
  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  input  wire                   m_axis_tready
);
  // Assert that AXIS_TDATA_WIDTH is 128
  //$assert(AXIS_TDATA_WIDTH == 128, "AXIS_TDATA_WIDTH must be 128");

  reg int_reg_tvalid;
  reg [AXIS_TDATA_WIDTH-1:0] int_reg_tdata;
  reg [15:0] repeat_counter = 0;

  always @(posedge aclk) begin
    if (!aresetn) begin
      int_reg_tvalid <= 1'b0;
      int_reg_tdata <= 0;
    end else begin
      // Load input data if we are ready to accept them
      if (s_axis_tvalid && s_axis_tready) begin
        repeat_counter <= s_axis_tdata[AXIS_TDATA_WIDTH-1-16 -: 16] + 1;
        int_reg_tdata <= s_axis_tdata;
      end else begin
        if (m_axis_tready && repeat_counter > 0) begin
          repeat_counter <= repeat_counter - 1;
        end
      end
    end
  end

  assign s_axis_tready = (repeat_counter <= 1) && m_axis_tready;
  assign m_axis_tvalid = repeat_counter > 0;
  assign m_axis_tdata = int_reg_tdata;


endmodule
