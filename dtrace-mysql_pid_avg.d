#!/usr/sbin/dtrace -s
/*
 * mysql_pid_avg.d	Print average query latency every second, plus more.
 *
 * USAGE: ./mysql_pid_avg.d -p mysqld_PID
 *
 */

#pragma D option quiet

dtrace:::BEGIN
{
	printf("Tracing PID %d...\n\n", $target);
	printf("%-20s %10s %8s %8s %8s\n", "TIME", "QUERIES", "1+sec_Qs",
	    "AVG(ms)", "MAX(ms)");
}

mysql$target::*dispatch_command*:query-start
{
	self->start = timestamp;
}

mysql$target::*dispatch_command*:query-done
/self->start && (this->time = (timestamp - self->start))/
{
	@avg = avg(this->time);
	@max = max(this->time);
	@num = count();
}

mysql$target::*dispatch_command*:query-done
/self->start && (this->time > 1000000000)/
{
	@slow = count();
}

mysql$target::*dispatch_command*:query-done
{
	self->start = 0;
}

profile:::tick-1s
{
	normalize(@avg, 1000000);
	normalize(@max, 1000000);
	printf("%Y ", walltimestamp);
	printa("%@10d %@8d %@8d %@8d", @num, @slow, @avg, @max);
	printf("\n");
	clear(@num); clear(@slow); clear(@avg); clear(@max);
}

dtrace:::END
{
	trunc(@num); trunc(@slow); trunc(@avg); trunc(@max);
}
