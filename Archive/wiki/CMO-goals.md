Goals: 
* it should be possible for some or even most CMOs to be invoked from user mode unprivileged code, but privileged code must be able to control or forbid unprivileged access to CMOs
* implementations can range from simple, one cache line at a time, to more complicated state machines
* transparent support for events such as page faults, debug exceptions, machine check error exceptions, etc.
* no virtualization holes - e.g. CMOs do not allow the user to observe page faults, except by timing as is already possible
* long-duration CMOs can be interrupted, i.e. are nonblocking to the hart that is running them. They can be resumed partway along, and do not have to restart from scratch. Conversely, if such interruptability interferes with the guarantees that security usage models require, this must be exposed and possibly prevented if privilege allows
* transparency/interruptability/resumability means that
 * on an exception the PC points to the CMO instruction, not the instruction after it
 * the OS is not required to parse the CMO instruction in order to determine how to handle exceptions such as page faults 
 * ordinary X scalar registers are modified to indicate partial progress, and are read back on exception return.
