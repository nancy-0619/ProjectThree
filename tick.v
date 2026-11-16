module tick(
    input clk,
    output tick
);
    /*
    Produces a pulse that is high for one clock cycle out of every 100.
    With the 1kHz clock, this is 10 pulses per second, which sets the
    sample rate for recording and playback.

    Use a 7 bit counter that starts at 0 and increases by 1 at every
    positive clock edge. When the counter is 99, the next value is 0.
    tick is high while the counter is 99, and low otherwise.
    */
    //Do not modify above this line
    reg[6:0] count = 7'd0;  // initialize count

    always @(posedge clk) begin
        if(count == 7'd99) count <= 7'd0;   //reset count after it reaches 99
        else count <= count + 7'd1;     //increment count
    end

    assign tick = (count == 7'd99);     //tick is high at count == 99
endmodule
