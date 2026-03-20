package PipeMulFIFO;

import FIFO::*;
import FIFOF::*;

// -------------------------
// Stage definition
// -------------------------
typedef struct {
    Bit#(8) multiplicand;
    Bit#(4) multiplier;
    Bit#(8) product;
} Stage deriving (Bits, Eq);

// -------------------------
// Interface
// -------------------------
interface MulIfc;
    method Action start(Bit#(4) a, Bit#(4) b);
    method ActionValue#(Bit#(8)) getResult();
endinterface

// -------------------------
// Module
// -------------------------
module mkPipeMulFIFO(MulIfc);

    // Pipeline FIFOs
    FIFOF#(Stage) f0 <- mkFIFOF;
    FIFOF#(Stage) f1 <- mkFIFOF;
    FIFOF#(Stage) f2 <- mkFIFOF;
    FIFOF#(Stage) f3 <- mkFIFOF;
    FIFOF#(Bit#(8)) outF <- mkFIFOF;

    // -------------------------
    // Stage 1
    // -------------------------
    rule stage1;

        let s = f0.first;
        f0.deq;

        Bit#(8) new_product = s.product;
        if (s.multiplier[0] == 1)
            new_product = s.product + s.multiplicand;

        f1.enq(Stage {
            multiplicand: s.multiplicand << 1,
            multiplier:   s.multiplier >> 1,
            product:      new_product
        });
    endrule

    // -------------------------
    // Stage 2
    // -------------------------
    rule stage2;

        let s = f1.first;
        f1.deq;

        Bit#(8) new_product = s.product;
        if (s.multiplier[0] == 1)
            new_product = s.product + s.multiplicand;

        f2.enq(Stage {
            multiplicand: s.multiplicand << 1,
            multiplier:   s.multiplier >> 1,
            product:      new_product
        });
    endrule

    // -------------------------
    // Stage 3
    // -------------------------
    rule stage3 ;

        let s = f2.first;
        f2.deq;

        Bit#(8) new_product = s.product;
        if (s.multiplier[0] == 1)
            new_product = s.product + s.multiplicand;

        f3.enq(Stage {
            multiplicand: s.multiplicand << 1,
            multiplier:   s.multiplier >> 1,
            product:      new_product
        });
    endrule

    // -------------------------
    // Stage 4 (final)
    // -------------------------
    rule stage4 ;

        let s = f3.first;
        f3.deq;

        Bit#(8) new_product = s.product;
        if (s.multiplier[0] == 1)
            new_product = s.product + s.multiplicand;

        outF.enq(new_product);
    endrule

        // -------------------------
    // Input
    // -------------------------
    method Action start(Bit#(4) a, Bit#(4) b);
        f0.enq(Stage {
            multiplicand: zeroExtend(a),
            multiplier: b,
            product: 0
        });
    endmethod

    // -------------------------
    // Output
    // -------------------------
    method ActionValue#(Bit#(8)) getResult();
        let r = outF.first;
        outF.deq;
        return r;
    endmethod

endmodule

module mktbPipeMulFIFO();

    MulIfc dut <- mkPipeMulFIFO;

    Reg#(Bit#(8)) testCount <- mkReg(0);
    Reg#(Bit#(8)) passCount <- mkReg(0);
    Reg#(Bit#(8)) cycle <- mkReg(0);

    // -------------------------
    // Stimulus: feed inputs
    // -------------------------
    rule feed_inputs (testCount < 16);

        Bit#(4) a = truncate(testCount);          // 0 to 15
        Bit#(4) b = truncate(15 - testCount);     // reverse pattern

        dut.start(a, b);

        $display("Cycle %0d Sent: a=%0d b=%0d", cycle, a, b);

        testCount <= testCount + 1;
    endrule

    rule count_cycles;
        cycle <= cycle + 1;
    endrule

    // -------------------------
    // Check outputs
    // -------------------------
    rule check_outputs;

        let result <- dut.getResult();

        Bit#(8) idx = passCount;

        Bit#(4) a = truncate(idx);
        Bit#(4) b = truncate(15 - idx);

        Bit#(8) expected = zeroExtend(a) * zeroExtend(b);

        if (result == expected) begin
            $display("Cycle %0d: PASS: %0d * %0d = %0d", cycle, a, b, result);
        end
        else begin
            $display("Cycle %0d: FAIL: %0d * %0d = %0d (expected %0d)", 
                     cycle, a, b, result, expected);
            $finish;
        end

        passCount <= passCount + 1;

        // Finish after all tests
        if (passCount == 15) begin
            $display("Cycle %0d: All tests PASSED!", cycle);
            $finish;
        end

    endrule

endmodule

endpackage
