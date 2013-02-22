#!/usr/sbin/dtrace -s
/*
 * dtrace-postgresql91_transaction_counts.d
 * Analyzes transaction counts in the system
 *
 * USAGE: ./dtrace-postgresql91_transaction_counts.d -p `pgrep -n postgres`
 *
 */

#pragma D option quiet
#pragma D option defaultargs
#pragma D option switchrate=10hz
#pragma D option strsize=8000

postgresql$target:::transaction-start
{
      @start["Start"] = count();
      self->ts  = timestamp;
}

postgresql$target:::transaction-abort
{
      @abort["Abort"] = count();
}

postgresql$target:::transaction-commit
/self->ts/
{
      @commit["Commit"] = count();
      @time["Total time (ns)"] = sum(timestamp - self->ts);
      self->ts=0;
}
