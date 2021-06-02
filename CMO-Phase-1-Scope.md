# CMO Phase 1 Scope

## Introduction

This document summarizes the current plan-of-record for Phase 1 of the CMO
extension. Additional details will be provided by various extension proposal
documents.

## Sub-extensions

Phase 1 is divided into three sub-extensions that add the following
instructions and features:

* Cache Block Management Operations (Zicbom)
  * CBO.INVAL - Invalidate Cache Block (at effective address)
  * CBO.CLEAN - Clean Cache Block (at effective address)
  * CBO.FLUSH - Flush Cache Block (at effective address)
  * Memory ordering with respect to other memory accesses
* Cache Block Zero Operations (Zicboz)
  * CBO.ZERO - Zero Cache Block (at effective address)
  * Memory ordering with respect to other memory accesses
* Cache Block Prefetch Operations (Zicbop)
  * PREFETCH.R - Prefetch Cache Block for Read (at effective address)
  * PREFETCH.W - Prefetch Cache Block for Write (at effective address)
  * PREFETCH.I - Prefetch Cache Block for Instruction Fetch (at effective
    address)

Instructions in the Zicbom and Zicboz sub-extensions support a [rs1] addressing
mode. Instructions in the Zicbop sub-extension may support a modified form of a
[rs1+imm12] addressing mode.

For Phase 1, Zicbom instructions operate to the copy of data in memory, while
Zicboz updates the values of memory corresponding to a memory location like
stores. Zicbop instructions may allocated in any cache as well as none.

## Closed Issues

_Note:_ "Closed" implies that a given issue has been documented in the
specification

* Permissions, protection, and access control (i.e. relationship to translation,
  PMAs, PMPs, and privilege level)
* Safe transformations of operations
  * HW: safe transformations enable implementation choices
  * SW: safe transformations allow less privileged software to use ops

## Open Issues

Topics required to round out Phase 1:

* Memory ordering model (i.e. relationship to loads, stores, FENCEs, SFENCEs, etc.)
* Discovery of block sizes and types
* Temporality (reuse) hints for PREFETCH operations
* Final instruction encodings

## Roadmap

These topics are deferred from Phase 1 and may be considered in Phase 2 and
onward:

* Effects of mismatched PMA/VA attributes and changing attributes
* Additional levels or points of convergence for system optimization
* Levels (Points of Persistence) beyond the POC for all harts and devices
* Cache Block Operations by Index
  * CBO.INVAL.IX - Invalidate Cache Block at Index
  * CBO.CLEAN.IX - Clean Cache Block at Index
  * CBO.FLUSH.IX - Flush Cache Block at Index
* CMO.ALL
* DEMOTE
* Completion semantics
* Security-related CMOs, e.g. CMO.ALL.SEC
* Non-uniform (i.e. mixed) block sizes
* Operations that return values, i.e. ranges, e.g. CMO.op.AR and CMO.op.UR
* Others?
