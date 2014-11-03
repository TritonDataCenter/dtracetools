#!/usr/sbin/dtrace -s
/*
 * mysql_pid_slow.d	Trace queries slower than specified ms.
 *
 * USAGE: ./mysql_pid_slow.d -p mysqld_PID min_ms
 *
 */

#pragma D option quiet
#pragma D option defaultargs
#pragma D option switchrate=10hz
#pragma D option strsize=8000

dtrace:::BEGIN
/$1 == 0/
{
	printf("USAGE: %s -p PID min_ms\n\n", $$0);
	printf("\teg: %s -p 12345 100\n", $$0);
	exit(1);
}

dtrace:::BEGIN
{
	min_ns = $1 * 1000000;
	printf("Tracing... Min query time: %d ns.\n\n", min_ns);
	printf(" %-8s %-8s %s\n", "TIME(ms)", "CPU(ms)", "QUERY");
}

mysql$target::*dispatch_command*:query-start
{
	self->query = copyinstr(arg0);
	self->start = timestamp;
	self->vstart = vtimestamp;
}

mysql$target::*dispatch_command*:query-done
/self->start && (timestamp - self->start) > min_ns/
{
	this->time = (timestamp - self->start) / 1000000;
	this->vtime = (vtimestamp - self->vstart) / 1000000;
	printf(" %-8d %-8d %S\n", this->time, this->vtime, self->query);
}

mysql$target::*dispatch_command*:query-done
{
	self->query = 0;
	self->start = 0;
	self->vstart = 0;
}
