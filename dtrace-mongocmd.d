#!/usr/sbin/dtrace -s

pid$target::_ZN5mongo16MyMessageHandler7processERNS_7MessageEPNS_21AbstractMessagingPortEPNS_9LastErrorE:entry {
		@ = count();
}

profile:::tick-1s
{
		printa("mongo cmds/s: %@d", @); clear(@);
}
