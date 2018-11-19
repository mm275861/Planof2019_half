module uart_rx(
	clk,
	rst,
	irq,
	data,
	rx
);

input clk,rst,rx;
output reg irq;
output reg [7:0]data;

reg [8:0]cnt;
reg [3:0]cnt2;
reg [7:0]outdata;

reg flag;
reg last;

reg begin_bit;


localparam CHECK_STATE = 1'b0;
localparam COUNT_STATE = 1'b1;

always@(posedge clk,negedge rst) begin
if(!rst) begin
	cnt <= 9'b0;
	irq <= 1'b0;
	data <= 8'b0;
	outdata <=7'b0;
	flag <= COUNT_STATE;
	last <= rx;
	cnt2 <= 4'b0;
	begin_bit <= 1'b0;

end
else
case(flag)

COUNT_STATE: begin
	if(begin_bit)
		if(cnt == 9'd434)
			flag <= CHECK_STATE;
		else
			cnt <= cnt + 1'b1;
	else	
		if(last!=rx) begin
			flag <= CHECK_STATE;
		end
		else begin
			cnt2 <= 4'b0;
			last <= rx;
			cnt <= cnt + 1'b1;
		end
	irq <= 1'b0;
		
	end

CHECK_STATE: begin
	if(cnt2 == 4'b0 && last && !rx) begin
		begin_bit <= 1'b1;
		cnt2 <= cnt2 + 1'b1;
		cnt <= 9'd217;
	end
	else if(cnt2 == 4'd10 && rx && begin_bit) begin
		begin_bit <= 1'b0;
		irq <= 1'b1;
		data <= outdata;
		cnt2 <= 4'b0;
		cnt <= 9'b0;
	end
	else begin
		outdata <= {rx,outdata[7:1]};
		cnt2 <= cnt2 + 1'b1;
		cnt <= 9'b0;
	end

		
	
	flag <= COUNT_STATE;
	last <= rx;
end		
endcase
	

	

end
endmodule