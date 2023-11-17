#!/usr/bin/env python3
from pyln.client import Plugin
from hashlib import sha256


plugin = Plugin()


wait_on = {
#    'payment_hash': [(cltv_expiry, request_obj), ... ]
}

# todo:
# - fancy: make hodlinvoice be a replacement for invoice
#          except pass in payment_hash (preimage not known)
# - fancy2: save to datastore so we do the right thing across a restart

@plugin.subscribe("block_added")
def on_block_received(block_added, plugin, **kwargs):
    # if block within range of timeout
    blockheight = block_added['height']
    hashes_to_del = []
    for payment_hash, pending_reqs in wait_on.items():
        print(pending_reqs)
        is_expired = False
        for expiry, _ in pending_reqs:
            if expiry <= blockheight + 1:
                is_expired = True
                break

        if is_expired:
            hashes_to_del.append(payment_hash)
            for _, request in pending_reqs:
                request.set_result({'result': 'fail',
                                    'failure_message': '2002'})
    for hash in hashes_to_del:
        del wait_on[hash]          
    

@plugin.async_hook("htlc_accepted")
def on_htlc_accepted(request, htlc, onion, plugin, **kwargs):
    plugin.log(f'{htlc} {onion}')
    payment_hash = htlc['payment_hash']
    cltv_expiry = htlc['cltv_expiry']
    if payment_hash in wait_on:
        wait_on[payment_hash].append((cltv_expiry, request))
    else:
        request.set_result({'result': 'continue'})


@plugin.method("hodlinvoice")
def hodl(plugin, payment_hash):
    if payment_hash not in wait_on:
        wait_on[payment_hash] = []

    return {'hodl': payment_hash in wait_on,
            'payment_hash': payment_hash}


@plugin.method("inspecthodl")
def inspect():
  return {'hodled': wait_on}


@plugin.method("unhodlinvoice")
def unhodl(payment_preimage, plugin):
    counter = 0
    was_hodled = False
    payment_hash = sha256(bytes.fromhex(payment_preimage)).hexdigest()
    if payment_hash in wait_on:
        plugin.log(f"preimage matches hash! {payment_hash}")
        was_hodled = True
        for _, request in wait_on[payment_hash]:
            request.set_result({
                'result': 'resolve',
                'payment_key': payment_preimage, 
            })
        counter = len(wait_on[payment_hash])
        del wait_on[payment_hash]

    return {'hodled': was_hodled, 
            'payment_hash': payment_hash,
            'payment_preimage': payment_preimage,
            'unhodled_count': counter}


plugin.run()