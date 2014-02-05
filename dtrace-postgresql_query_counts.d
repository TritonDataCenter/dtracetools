#!/usr/sbin/dtrace -qs

postgresql$target:::query-start {
		@[copyinstr(arg0)] = count();
}
