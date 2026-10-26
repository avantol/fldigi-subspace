# fldigi-subspace

A temporary copy of **fldigi 4.2.13** (W1HKJ and the fldigi developers,
GPL-3.0) with a small number of changes to **PTT timing when the radio is
controlled through flrig**. It is meant for stations that share one radio
between several programs through flrig, together with
[flrig-subspace](https://github.com/avantol/flrig-subspace).

**Everything else is stock fldigi 4.2.13, unchanged.** Modes, decoding,
macros, logging, the sound card, hamlib and every other rig control path
behave exactly as in fldigi 4.2.13. Questions and problems about those go to
the fldigi project: <http://www.w1hkj.org> and the fldigi user group.

## The changes (all marked `[subspace]` in the source)

| Change | File |
|---|---|
| fldigi's flrig poll cycle stops as soon as a PTT request is waiting, instead of finishing up to 7 more calls first | `src/rigcontrol/xmlrpc_rig.cxx` |
| PTT on goes to flrig the moment fldigi decides to transmit, not after the receive loop winds down (median 70 ms -> 20 ms on the bench). Not for CW. | `src/rigcontrol/xmlrpc_rig.cxx`, `src/trx/trx.cxx` |
| At the end of a transmission (end of text, or the T/R button), fldigi asks flrig-subspace (`rig.reserve_ptt`) to keep its radio polling off the serial line until the unkey arrives, about 1.3 s later in PSK31. On flrig's side, unkey -> radio went from a median of 16 ms (worst 39) to 11 ms (worst 31) on the bench. A stock flrig does not have this call; fldigi then stops asking until it reconnects to flrig. Not for CW. | `src/rigcontrol/xmlrpc_rig.cxx`, `src/dialogs/fl_digi.cxx`, `src/trx/modem.cxx`, `src/trx/trx.cxx` |

Packaging only (no effect on the program):

- Linux: `packaging/build-deb.sh` builds `fldigi-subspace`, installed as
  `/usr/bin/fldigi-subspace` with its own menu entry and data folder.
- Windows: `.github/workflows/windows.yml` builds an installer named
  `fldigi-subspace` (its own Program Files folder and Start menu entry). This
  Windows build has no hamlib; use flrig for rig control.

## Installing beside a stock fldigi

Both can be installed at once, but they share the same settings folder
(`~/.fldigi`, or `fldigi.files` on Windows) and the same ports. Run one at a
time.
