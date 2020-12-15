# CMO Phase 1 Scope

## Introduction

This document summarizes the current plan-of-record for Phase 1 of the CMO extension.
Additional details will be provided by various extension proposal documents. 

## Basic Instructions

The following instructions are included in Phase 1:

* Cache Block Operations by Effective Address (Mandatory Semantics)
  * CBO.INVAL.EA - Invalidate Cache Block at Effective Address
  * CBO.CLEAN.EA - Clean Cache Block at Effective Address
  * CBO.FLUSH.EA - Flush Cache Block at Effective Address
  * CBO.ZERO.EA - Zero Cache Block at Effective Address
* Cache Block Operations by Effective Address (Advisory Semantics)
  * PREFETCH.R.EA - Prefetch Cache Block for Read (load) at Effective Address
  * PREFETCH.W.EA - Prefetch Cache Block for Write (store) at Effective Address
  * PREFETCH.I.EA - Prefetch Cache Block for Instruction Fetch at Effective Address
  * DEMOTE.EA - Demote Cache Block at Effective Address
    * Note: DEMOTE.EA is intended to increase the likelihood that the cache block at the effective address will be selected for replacement
* Ordering and Completion Operations
  * FENCE.COMP - Completion Fence
    * Note: FENCE.COMP ensures that previous operations have been completed rather than simply ordered

## Variations

Addressing Modes, depending on operation type:

* For CBOs with mandatory semantics, [rs1] only
* For CBOs with advisory semantics, [rs1] (or [rs1+imm12] with sufficient justification)

Levels, depending on operation type:

* For CBOs with mandatory semantics, the following abstract system levels:
  * Point of Convergence for all Harts*
  * Point of Convergence for all Harts and I/O Devices
  * Points of Persistence at different levels (e.g. DRAM, NVRAM, deep)*
* For CBOs with advisory semantics, the following specific cache levels, numbered beginning with the first cache accessed on the path to memory:
  * Unspecified/Default
  * L1*
  * L2*
  * L3*

\* These are currently in scope for Phase 1 but may be left reserved in the interest of time

## Open Issues

Topics required to round out Phase 1:

* Permissions, protection, and access control (i.e. relationship to translation, PMAs, PMPs, and privilege level)
* Memory ordering model (i.e. relationship to loads, stores, FENCEs, SFENCEs, etc.)
* Discovery of block sizes and types
* Safe transformations of operations
  * HW: safe transformations enable implementation choices
  * SW: safe transformations allow less privileged software to use ops
* Temporality (reuse) hints for PREFETCH operations
* Completion semantics
* Levels (Points of Persistence) beyond the POC for all harts and devices
* Effects of mismatched PMA/VA attributes and changing attributes
* After most (or all) of the above, instruction encodings

## Roadmap

These topics are deferred from Phase 1 and may be considered in Phase 2 and onward:

* Items above that do not make it into Phase 1
* Cache Block Operations by Index (Mandatory Semantics)
  * CBO.INVAL.IX - Invalidate Cache Block at Index
  * CBO.CLEAN.IX - Clean Cache Block at Index
  * CBO.FLUSH.IX - Flush Cache Block at Index
* CMO.ALL
* Security-related CMOs, e.g. CMO.ALL.SEC
* Non-uniform (i.e. mixed) block sizes
* Operations that return values, i.e. ranges, e.g. CMO.op.AR and CMO.op.UR
* Others?
