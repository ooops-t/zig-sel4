/*
 * Copyright 2020, Data61, CSIRO (ABN 41 687 119 230)
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

ENTRY(_start)

SECTIONS
{

	.text : ALIGN(4K) {
		*(.text)
	}

	.rodata : ALIGN(4K) {
		*(.rodata)
	}

	.tdata : {
		_tdata_start = . ;
		*(.tdata .tdata.* .gnu.linkonce.td.*)
		_tdata_end = . ;
	}
	.tbss : {
		_tbss_start = . ;
		*(.tbss .tbss.* .gnu.linkonce.tb.*) *(.tcommon)
		_tbss_end = . ;
	}

	.data : ALIGN(4K) {
		*(.data)
	}

	.bss : ALIGN(4K) {
		*(COMMON)
		*(.bss)
	}
}
