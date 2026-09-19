`default_nettype none

module tt_um_vga_example(
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input wire       ena
);

  wire hsync;
  wire vsync;
  wire [1:0] R;
  wire [1:0] G;
  wire [1:0] B;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // TinyVGA PMOD pinout
  assign uo_out  = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};
  assign uio_out = 0;
  assign uio_oe  = 0;

  wire _unused_ok = &{ena, ui_in, uio_in};

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );

  // -----------------------------------------------------------------
  // TV static: a wide LFSR advanced every pixel clock, giving fresh
  // pseudo-random bits for every pixel drawn on screen.
  // -----------------------------------------------------------------
  reg [23:0] lfsr;
  wire feedback = lfsr[23] ^ lfsr[22] ^ lfsr[21] ^ lfsr[16];

  always @(posedge clk) begin
    if (~rst_n)
      lfsr <= 24'hACE1F0;
    else
      lfsr <= {lfsr[22:0], feedback};
  end

  // Grayscale noise value from the LFSR (2 bits -> 4 shades)
  wire [1:0] noise = lfsr[1:0];

  // Darken every other scanline slightly for a CRT / rolling-static look
  wire [1:0] shaded_noise = pix_y[0] ? (noise >> 1) : noise;

  assign R = video_active ? shaded_noise : 2'b00;
  assign G = video_active ? shaded_noise : 2'b00;
  assign B = video_active ? shaded_noise : 2'b00;

endmodule
