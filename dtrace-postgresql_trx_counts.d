#!/usr/sbin/dtrace -qs

postgresql$target:::transaction-start {
		@ = count();
}

profile:::tick-1s
{
		printa("PostgreSQL transactions/s: %@d\n", @); clear(@);
}
