#!/usr/sbin/dtrace -s

#pragma D option quiet
#pragma D option switchrate=10

BEGIN
{
			min_ns = 10 * 1000000;
			trace("Tracing...\n");
}

pid$target::_ZN5mongo16MyMessageHandler7processERNS_7MessageEPNS_21AbstractMessagingPortEPNS_9LastErrorE:entry
{
		self->start = timestamp;
}

pid$target::_ZN5mongo16MyMessageHandler7processERNS_7MessageEPNS_21AbstractMessagingPortEPNS_9LastErrorE:return
/self->start && (this->delta = timestamp - self->start) > min_ns/
{
		printf("slow mongo cmd: %d ms\n", this->delta / 1000000);
}

pid$target::_ZN5mongo16MyMessageHandler7processERNS_7MessageEPNS_21AbstractMessagingPortEPNS_9LastErrorE:return
{
			self->start = 0;
}
