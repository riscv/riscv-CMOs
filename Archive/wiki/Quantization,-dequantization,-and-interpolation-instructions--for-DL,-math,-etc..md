STATUS: TBD: not proposed yet for RISC-V, but I expect to do so when the time comes

It is often advantageous in deep learning to *quantize* the data.  E.g. to represent 16 or 32 bit data in memory using only two or four bits.  
* E.g. dequantizing (expanding or unpacking) the two bit numbers into 16-bit data to perform computations, and then quantizing (compressing or packing) the 16-bit data into two bits to restore back in memory. Thereby saving memory bandwidth but not compute bandwidth.
* Some systems can actually do computations in the narrower widths - which essentially amounts to having the dequantization and quantization logic in the pipeline to the arithmetic units. Thereby saving both memory bandwidth and computational unit bandwidth.

Dequantization at its simplest is essentially a classic indexed lookup table. In the vector instruction set has a VRGATHER instruction that accomplishes this, although IRC its smallest index is eight bits wide. Conceptually it is not difficult to imagine extending VRGATHER to use vectors of two bit or four bit values to perform the indexing. For that matter, memory lookup tables... Although two and four bit quantized values don't really need memory lookup tables.

Another use case: mapping one of the several varieties of 8-bit floating-point or 8-bit LNS to standard 16-bit or 32-bit floating-point. 

The obvious or counterpart to such a dequantization instruction is a quantization instruction.

Anyway, to quantize, you map something like a 16-bit number to a 2 or 4 bit number.  

Linear quantization is usually not the right thing to do. I.e. it is not just extracting the higher order bits.

Nonlinear quantization is essentially determining in which interval the wider number resides.

E.g. to quantize an unsigned 16-bit number N to a 2 bit number M, you do
	if 0 <= N < T0 then M = 00
	else if T0 <= N < T1 then M = 01
	else if T1 <= N < T2 then M = 10
	else M = 11
and it is convenient to pack the 3 16-bit values T0,T1,T2 into a 64-bit register
	RANGE_LUT_64 = ( T0, T1, T2 ) 
leaving 64-bits unused.

I call this RANGE_LUT_64 or INTERVAL_LUT – it is not exactly the same as an ordinary indexed LUTs, such as is used in cryptography or dequantization. I call the latter INDEXED_LUTs.  Some computer arithmetic subdisciplines call this sort of comparison based thing a LUT, and also have other LUTs that are similar to ternary CAMs, sometimes conceptually in ROM (which synthesize to less regular but more compact logic).

I will certainly be proposing this instruction at some point to assist RISC-V deep learning. Probably as part of some V-DL extension - deep learning in the vector register file - but also possibly a scalar register file version. As you can imagine, the [[multipart instruction approach]] can also be used here if there are too many conceptual operands to fit in the classic RISC two or three input model.

In fact, the most annoying thing about this sort of quantization instruction using a RANGE_LUT is that the RANGE_LUT does not make use of a full vector operand or typical quantization's like 16 bits to 2 bits.  Even when doing something like quantizing 32 bits to 4 bits, it really wants to have to vector operands of different lengths. Which as far as I can tell is something that the vector instruction set is not naturally suited for.

--

Piling on:

Some math dequantization instructions are not just a simple indexed LUT operation.  E.g. they may LUT a smallish number of the top bits, and concatenate with or otherwise combine with low bits of the value to be looked up (which is no longer an index). GPU texture units do something like this, although usually in 2D or 3D, not a single dimension, and combined with a special cache for the values that are looked up, at different resolutions (MIP mapping levels).

Furthermore, a rather common operation in numerically intensive code is to do piecewise linear interpolation.  E.g. have a set of data breakpoints like in the INTERVAL_LUT, and if the value does not exactly match one of those breakpoints, then interpolate. Sometimes linearly sometimes with fancier interpolation functions.

But, again, I cannot imagine uses for these operations in cryptography. I don't think the cryptography will normally want to use interpolation, and especially not any form of approximate arithmetic. I sometimes wonder if it could be useful for curves in cryptography. But the piecewise intervals are far too many and should not be compressible.

--

Generalized:
* INDEX_LUT
* INTERVAL_LUT
* GPU texture lookup = INDEX_LUT and interpolation (typically in two or more dimensions)
* piecewise interpolation = RANGE_LUT and interpolation

