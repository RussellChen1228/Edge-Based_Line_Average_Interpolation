`timescale 1ns/10ps

module ELA(clk, rst, in_data, data_rd, req, wen, addr, data_wr, done);

	input				clk;
	input				rst;
	input		[7:0]	in_data;
	input		[7:0]	data_rd;
	output				req;
	output				wen;
	output		[9:0]	addr;
	output		[7:0]	data_wr;
	output				done;

	reg ready, req, wen, done;

	reg [3:0] save_num;
	reg [4:0] count;
	reg [7:0] data_wr, a, b, c, d, e, f, d1, d2, d3, min, result;
	reg [9:0] addr, addr_count, addr_read;
	reg [1:0] currentstate, nextstate;

	parameter [1:0] req_high = 0, save_data = 1, read_data = 2, output_data = 3;
	
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			currentstate <= req_high;
		end
		else begin
			currentstate <= nextstate;
		end
	end
	always @(*) begin
		case(currentstate)
			req_high: begin
				nextstate = save_data;
			end
			save_data: begin
				if(count == 31 && addr_count != 991)
					nextstate = req_high;
				else if (addr_count == 991)
					nextstate = read_data;
				else
					nextstate = save_data;
			end
			read_data: begin
				if (ready==1) begin
					nextstate = output_data;
				end
				else
					nextstate = read_data;
			end
			output_data:begin
				nextstate = read_data;
			end
		endcase

	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			req <= 1'b0;
			wen <= 1'b0;
			done <= 1'b0;
			addr <= 10'b0;
			count <= 4'b0;
			save_num <= 0;
			addr_count <= 10'b0;
			addr_read <= 10'd32;
			data_wr <= 8'b0;
		end
		else begin
			case(currentstate)
				req_high: begin
					req <= 1'b1;
					wen <= 1'b0;
					done <= 1'b0;
					data_wr <= 8'b0;
					if(addr_count!=0)
						addr_count <= addr_count + 32;
				end
				save_data: begin
					req <= 1'b0;
					wen <= 1'b1;
					done <= 1'b0;
					data_wr <= in_data;
					addr <= addr_count;
					addr_count <= addr_count + 1;
					count <= count + 1;
				end
				read_data: begin
					wen <= 1'b0;
					req <= 1'b0;
					done <= 1'b0;
					if(count == 0) begin
						if (save_num == 0) begin
							ready <= 0;
							save_num <= 1;
							addr <= addr_read - 32;
						end
						else if (save_num == 1) begin
							ready <= 0;
							b <= data_rd;
							save_num <= 2;
							addr <= addr_read + 32;
						end
						else if (save_num == 2) begin
							ready <= 0;
							e <= data_rd;
							save_num <=3;
							addr <= addr_read - 31;
						end
						else if (save_num == 3) begin
							ready <= 1;
							c <= data_rd;
							save_num <= 4;
							addr <= addr_read + 33;
						end
						else if (save_num == 4) begin
							ready <= 0;
							f <= data_rd;
							save_num <= 0;
						end
					end
					else begin
						case(save_num)
							0: begin
								a <= b;
								d <= e;
								b <= c;
								e <= f;
								ready <= 0;
								save_num <= 1;
								addr <= addr_read - 31;
							end
							1: begin
								ready <= 1;
								c <= data_rd;
								save_num <= 2;
								addr <= addr_read + 33;
							end
							2:begin
								ready <= 0;
								f <= data_rd;
								save_num <= 0;
							end
						endcase
					end
				end
				output_data: begin
					req <= 1'b0;
					wen <= 1'b1;
					ready <= 1'b0;
					addr <= addr_read;
					if (addr_read > 959) begin
						done <= 1'b1;
					end
					if (count==0 || count==31)
						data_wr <= (b+e)/2;
					else begin
						data_wr <= result;
					end
					if (count == 31) begin
						addr_read <= addr_read + 33;
					end
					else begin
						addr_read <= addr_read + 1;
					end
					count <= count + 1;
				end
		
			endcase
		end
	end
always@(*) begin
	d1 = (a < f) ? f - a : a - f;
	d2 = (b < e) ? e - b : b - e;
	d3 = (c < d) ? d - c : c - d;
	min = d1<d2 ? d1<d3 ? d1:d3 : d2<d3 ? d2:d3;
	result = min == d2 ? (b+e) / 2 : min == d1 ? (a+f) / 2 : (c+d) / 2;
end
endmodule