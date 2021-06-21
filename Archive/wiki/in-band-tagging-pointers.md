RISC-V is considering in-band tagging of pointers. Workgroups incvolved include
* J extension (dynamic ;anguages like JavaScript)
* TEE Trusted Execution Environment security
although IMHO (Glew opinion) we are missing a group concerned specifically with preventing 

People involved
* Kostya Serebryany (Google)
* Lee Campbell (Google)
* ... ?? Nvidia ?? ...
* ... ?? Russian group that built TBI and MTE on RISC-V FPGA ??...

More accurately, RISC-V is considering <A href="../../comp-arch.net/wiki/pre-Virtual-Address Transformations">pre Virtual Address Transformations</A>
since Lee Campbell has proposed a transformation 

~~~
    address <-- (pointer&mask) | (substitute&~mask)
~~~
