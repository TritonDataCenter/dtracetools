#!/usr/sbin/dtrace -s
/*
 * slowhttpdconnect-stacks.d	Trace slow httpd connect()s, with stacks.
 *
 * USAGE: ./slowhttpdconnect-stacks.d [min_ms]
 *
 * This is written to trace the time from either blocking or non-blocking
 * connect()s.  Tracing begins with the connect() entry, and ends when the
 * first I/O is attempted.  If there is a slow syscall inbetween, including
 * connect() or poll(), it will be identified.
 *
 * Copyright (c) 2011 Joyent Inc., All rights reserved.
 */

#pragma D option quiet
#pragma D option defaultargs
#pragma D option switchrate=10hz

dtrace:::BEGIN
{
	min_ns = $1 ? $1 * 1000000 : 1100 * 1000000;
	printf("Tracing httpd syscalls after connect() slower than %d ms.\n\n",
	    min_ns / 1000000);
	printf("%-20s %-10s %-16s %-6s %-16s %3s %3s %s\n", "TIME", "ZONE",
	    "EXEC", "PID", "SYSCALL", "RET", "ERR", "LATENCY");
}

syscall::connect:entry /execname == "httpd"/ { self->after_connect = 1; }

syscall::*read*:entry,
syscall::*write*:entry,
syscall::*send*:entry,
syscall::*recv*:entry,
syscall::close:entry
{
	self->after_connect = 0;
}

syscall:::entry
/self->after_connect && execname == "httpd"/
{
	self->start = timestamp;
}

syscall:::return
/self->start/
{
	this->delta = timestamp - self->start;
}

syscall:::return
/self->start && (this->delta > min_ns)/
{
	printf("\n%-20Y %-10s %-16s %-6d %-16s %3d %3d %d ms", walltimestamp,
	    zonename, execname, pid, probefunc, arg1, errno,
	    (this->delta / 1000000));
	ustack(8);
}

syscall:::return
{
	self->start = 0;
}
