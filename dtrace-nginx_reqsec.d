#!/usr/sbin/dtrace -qs

pid$target:nginx:ngx_http_create_request:entry {
		@ = count();
}

profile:::tick-1s
{
		printa("nginx req/s: %@d\n", @); clear(@);
}
