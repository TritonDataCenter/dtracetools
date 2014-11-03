#!/usr/sbin/dtrace -s
/*
 * mysql_pid_latency.d	Print query latency distribution every second.
 *
 * USAGE: ./mysql_pid_latency.d -p mysqld_PID
 *
 */

#pragma D option quiet

dtrace:::BEGIN
{
	printf("Tracing PID %d... Hit Ctrl-C to end.\n", $target);
}

mysql$target::*dispatch_command*:query-start
{
	self->start = timestamp;
}

mysql$target::*dispatch_command*:query-done
/self->start/
{
	@time = quantize(timestamp - self->start);
	@num = count();
	self->start = 0;
}

profile:::tick-1s
{
	printa("\nMySQL queries/second: %@d; query latency (ns):", @num);
	printa(@time);
	clear(@time); clear(@num);
}

dtrace:::END
{
	trunc(@time); trunc(@num);
}
