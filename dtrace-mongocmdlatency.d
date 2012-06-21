#!/usr/sbin/dtrace -s

pid$target::_ZN5mongo16MyMessageHandler7processERNS_7MessageEPNS_21AbstractMessagingPortEPNS_9LastErrorE:entry
{
		self->start = timestamp;
}

pid$target::_ZN5mongo16MyMessageHandler7processERNS_7MessageEPNS_21AbstractMessagingPortEPNS_9LastErrorE:return
/self->start/
{
		  @["mongo cmd (ns):"] = quantize(timestamp - self->start);
			self->start = 0;
}
