`default_nettype none
module tt_um_data #(parameter BUS_WIDTH = 8,
	               parameter NUM_STAGES = 2)
(
	input  wire       ena,      // always 1 when the design is powered, so you can ignore it
	input clk,   
	input rst_n,
	input [BUS_WIDTH-1:0] ui_in,
	input  wire [7:0] uio_in,   // IOs: Input path
	output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
	output reg [BUS_WIDTH-1:0] uo_out
);

reg [NUM_STAGES-1:0] sync_reg;
reg enable_ff;
wire enable_pulse_reg;
wire [BUS_WIDTH-1:0] sync_bus_reg;

wire _unused = &{ena,uio_in[6:0], 1'b0};
	
assign uio_out[6:0] = 0;
assign uio_oe  = 0;	
	
assign enable_pulse_reg = sync_reg[NUM_STAGES-1] && !enable_ff;
assign sync_bus_reg = enable_pulse_reg ? ui_in: uo_out;


always @(posedge clk or negedge rst_n)
 begin
  if(!rst_n)      
   begin
    sync_reg <= 'b0 ;
   end
  else
   begin
    sync_reg <= {sync_reg[NUM_STAGES-2:0],uio_in[7]};
   end  
 end

always @(posedge clk or negedge rst_n) begin 
	if(~rst_n) begin
		enable_ff <= 0;
	end 
	else begin
		enable_ff <= sync_reg[NUM_STAGES-1];
	end
end

always @(posedge clk or negedge rst_n) begin 
	if(~rst_n) begin
		uio_out[7] <= 0;
	end 
	else begin
		uio_out[7] <= enable_pulse_reg;
	end
end

always @(posedge clk or negedge rst_n) begin 
	if(~rst_n) begin
		uo_out <= 0;
	end 
	else begin
		uo_out <= sync_bus_reg;
	end
end

endmodule 
