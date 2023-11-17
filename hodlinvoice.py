#!/usr/bin/env python3
from pyln.client import Plugin


plugin = Plugin()


wait_on = {}

@plugin.async_hook("htlc_accepted")
def on_htlc_accepted(request, htlc, onion, plugin, **kwargs):
    request.set_result({'result': 'continue'})


@plugin.method("hodlinvoice")
def hodl(plugin, payment_hash):
  return {'hodl': False, 'payment_hash': payment_hash}


@plugin.method("inspecthodl")
def inspect():
  return {'hodled': wait_on}


@plugin.method("unhodlinvoice")
def unhodl(plugin, payment_hash):    
  return {'hodl': False, 
          'payment_hash': payment_hash,
          'unhodled_count': 0}


plugin.run()