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
		self->btinsert = 0;
}

pid$target::_ZNK5mongo18IndexInterfaceImplINS_12BtreeData_V1EE9bt_insertENS_7DiskLocES3_RKNS_7BSONObjERKNS_8OrderingEbRNS_12IndexDetailsEb:entry
{
		self->btstart = timestamp;
}

pid$target::_ZNK5mongo18IndexInterfaceImplINS_12BtreeData_V1EE9bt_insertENS_7DiskLocES3_RKNS_7BSONObjERKNS_8OrderingEbRNS_12IndexDetailsEb:return
/self->btstart/
{
		self->btinsert += timestamp - self->btstart;
		self->btstart = 0;
}

pid$target::_ZN5mongo16MyMessageHandler7processERNS_7MessageEPNS_21AbstractMessagingPortEPNS_9LastErrorE:return
/self->start && (this->delta = timestamp - self->start) > min_ns/
{
		printf("slow mongo cmd: %d ms (btinsert: %d ms)\n", this->delta / 1000000,
				self->btinsert / 1000000);
}

pid$target::_ZN5mongo16MyMessageHandler7processERNS_7MessageEPNS_21AbstractMessagingPortEPNS_9LastErrorE:return
{
			self->start = 0;
			self->btinsert = 0;
}
