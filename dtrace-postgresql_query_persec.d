#!/usr/sbin/dtrace -qs

postgresql$target:::query-start {
		@ = count();
}

profile:::tick-1s
{
		printa("PostgreSQL query/s: %@d\n", @); clear(@);
}
