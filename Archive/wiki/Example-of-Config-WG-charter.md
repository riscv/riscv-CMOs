

> From: Tim Newsome <tim@sifive.com>
>
> Sent: Monday, July 27, 2020 12:09PM
>
> To: Tech-Config <tech-config@lists.riscv.org>
>
> Subject: Re: [RISC-V] [tech-config] updated charter
>
>  
> On 7/27/2020 12:09 PM, Tim Newsome wrote:
>
> The proposal is in the pull request on github. 

> https://github.com/riscv/configuration-structure/pull/5

> (You can see the actual text by clicking the "Files changed" link.)
>
> If anybody disagrees with that language, please comment on github or
> start an e-mail discussion with your proposed change and
> reasoning. Until you see your new text appear in that pull request,
> it will not be voted on at the next meeting, so speak up repeatedly
> if you have to. All I've seen so far is people here and there
> mentioning that maybe something would be nice or is also
> relevant. If I missed something, please repeat it.
>
> Tim

# Task Group Charter

The Configuration Structure Task Group will:
* Specify syntax and semantics for a static data structure that can accommodate
  all implementation parameters of RISC-V standards: the configuration
  structure. There will be two configuration structure formats: a
  machine-readable format intended to be embedded in hardware, and a
  human-readable format intended for people to work with directly.
* Specify how M-mode software can discover and access any present
  machine-readable configuration structures.
* Provide a tool that can translate between the machine-readable and
  human-readable formats.

Implementation parameters are details that a RISC-V specification explicitly
leaves up to an implementation. This includes hart-specific details like the
kinds of hardware triggers supported, as well as details that are outside
harts such as the supported abstract debug commands.

The configuration structure should:
* be flexible enough that future task groups won’t feel the need to
  create another structure used to describe implementation parameters.
* be easy to translate into other data structures.

The configuration structure is intended to be used:
* to describe RISC-V hardware profiles
* by firmware and BIOSes during the boot process
* by debuggers
* by a tool chain to build software tailored to a configuration profile
