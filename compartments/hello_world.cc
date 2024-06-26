// Copyright lowRISC Contributors.
// SPDX-License-Identifier: Apache-2.0

#include <compartment.h>
#include <thread.h>
#include <debug.hh>

using Debug = ConditionalDebug<true, "Hello World">;

void __cheri_compartment("hello_world") entry_point()
{
  while (true)
  {
    Debug::log("Hello RISC-V Summit!");
    thread_millisecond_wait(500);
  }
}
