#!/usr/sbin/dtrace -s
/*
 * innodb_thread_concurrency.d  measure thread concurrency sleeps
 *
 * USAGE: ./innodb_thread_concurrency.d -p mysqld_PID
 *
 * TESTED: these pid-provider probes may only work on some mysqld versions.
 *      5.0.51a: ok
 */

pid$target::srv_conc_enter_innodb:entry
{
	self->srv = 1;
}

pid$target::os_thread_sleep:entry
/self->srv/
{
	@["innodb srv sleep (ns)"] = quantize(arg0 * 1000);
}

pid$target::srv_conc_enter_innodb:return
{
	self->srv = 0;
}

pid$target::*dispatch_command*:entry
{
	self->start = timestamp;
}

pid$target::*dispatch_command*:return
/self->start/
{
	@["query time (ns)"] = quantize(timestamp - self->start);
	self->start = 0;
}

profile:::tick-1s
{
	printa(@);
	trunc(@);
}
