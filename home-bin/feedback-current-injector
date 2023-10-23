#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
from pprint import pprint, pformat
import argparse
from operator import itemgetter
from math import log10, ceil, floor

def siprefix(val):
	gr = min(max(int(floor(log10(abs(val)) / 3)), -10), 10)
	return "%1.2f%s"%(val / (10 ** (3 * gr)), (gr != 0 and "qryzafpnum_kMGTPEZYRQ"[gr + 10]) or "")

eseries = {
	 3: [100, 220, 470],
	 6: [100, 150, 220, 330, 470, 680],
	12: [100, 120, 150, 180, 220, 270, 330, 390, 470, 560, 680, 820],
	24: [100, 110, 120, 130, 150, 160, 180, 200, 220, 240, 270, 300, 330, 360, 390, 430, 470, 510, 560, 620, 680, 750, 820, 910],
	48: [100, 105, 110, 115, 121, 127, 133, 140, 147, 154, 162, 169, 178, 187, 196, 205, 215, 226, 237, 249, 261, 274, 287, 301, 316, 332, 348, 365, 383, 402, 422, 442, 464, 487, 511, 536, 562, 590, 619, 649, 681, 715, 750, 787, 825, 866, 909, 953],
	96: [100, 102, 105, 107, 110, 113, 115, 118, 121, 124, 127, 130, 133, 137, 140, 143, 147, 150, 154, 158, 162, 165, 169, 174, 178, 182, 187, 191, 196, 200, 205, 210, 215, 221, 226, 232, 237, 243, 249, 255, 261, 267, 274, 280, 287, 294, 301, 309, 316, 324, 332,340, 348, 357, 365, 374, 383, 392, 402, 412, 422, 432, 442, 453, 464, 475, 487, 499, 511, 523, 536, 549, 562, 576, 590, 604, 619, 634, 649, 665, 681, 698, 715, 732, 750, 768, 787, 806, 825, 845, 866, 887, 909, 931, 953, 976],
	192: [100, 101, 102, 104, 105, 106, 107, 109, 110, 111, 113, 114, 115, 117, 118, 120, 121, 123, 124, 126, 127, 129, 130, 132, 133, 135, 137, 138, 140, 142, 143, 145, 147, 149, 150, 152, 154, 156, 158, 160, 162, 164, 165, 167, 169, 172, 174, 176, 178, 180, 182,184, 187, 189, 191, 193, 196, 198, 200, 203, 205, 208, 210, 213, 215, 218, 221, 223, 226, 229, 232, 234, 237, 240, 243, 246, 249, 252, 255, 258, 261, 264, 267, 271, 274, 277, 280, 284, 287, 291, 294, 298, 301, 305, 309, 312, 316, 320, 324, 328, 332, 336, 340, 344, 348, 352, 357, 361, 365, 370, 374, 379, 383, 388, 392, 397, 402, 407, 412, 417, 422, 427, 432, 437, 442, 448, 453, 459, 464, 470, 475, 481, 487, 493, 499, 505, 511, 517, 523, 530, 536, 542, 549, 556, 562, 569, 576, 583, 590, 597, 604, 612, 619, 626, 634, 642, 649, 657, 665, 673, 681, 690, 698, 706, 715, 723, 732, 741, 750, 759, 768, 777, 787, 796, 806, 816, 825, 835, 845, 856, 866, 876, 887, 898, 909, 920, 931, 942, 953, 965, 976, 988]
}

parser = argparse.ArgumentParser(description='Current-injected feedback network finder')

parser.add_argument('Vdac', metavar='Vdac', type=float, help='Max DAC voltage')
parser.add_argument('Vmax', metavar='Vmax', type=float, help='Max Output voltage (at Vdac=0)')
parser.add_argument('Vmin', metavar='Vmin', type=float, help='Min Output voltage (at Vdac=VdacMax)')
parser.add_argument('Vfb', metavar='Vfb', type=float, help='Feedback voltage')
parser.add_argument('-e', '--series', help='E-series to use', type=int, choices=[3, 6,12,24,48,96,192], default=24)
parser.add_argument('-r', '--results', help='Results to show', type=int, default=3)

args = parser.parse_args()

Vdac = args.Vdac
Vmax = args.Vmax
Vmin = args.Vmin
Vfb  = args.Vfb
es   = eseries[args.series] + [eseries[args.series][0] * 10]

print("Vout: %g-%gV\nVdac: %gV\nVfb : %gV\n" % (Vmin, Vmax, Vdac, Vfb))

#         Vo
#          |
#         Rt
#          |
# DAC→ -Ri-+- →FB
#          |
#         Rb
#          |
#          ⏚

# ((Vdac - Vfb) / Ri - Vfb / Rb) * -Rt + Vfb = Vmin
# ((0    - Vfb) / Ri - Vfb / Rb) * -Rt + Vfb = Vmax

# (Vdac - Vfb) / Ri = (Vmin - Vfb) / -Rt + Vfb / Rb
# (0    - Vfb) / Ri = (Vmax - Vfb) / -Rt + Vfb / Rb

# Ri = (Vdac - Vfb) / ((Vmin - Vfb) / -Rt + Vfb / Rb)
# Ri = (0    - Vfb) / ((Vmax - Vfb) / -Rt + Vfb / Rb)

# ((0    - Vfb) / Ri - Vfb / Rb) * -Rt + Vfb = Vmax

results=[]

def rclose(val):
    mul = 10 ** (floor(log10(val)) - 2)
    return list(sorted(es, key=lambda x: abs(x * mul - val)))[0] * mul

for Rbt in es:
    Rbt *= 10
    Irb = Vfb / Rbt;
    
    Rt = (((Vmax - Vmin) * (1 - (Vfb / Vdac))) + Vmin - Vfb) * Rbt / Vfb
    Rtc = rclose(Rt)
    
    Ri = (Vdac - Vfb) / ((Vmin - Vfb) / -Rt + Vfb / Rbt)
    Ric = rclose(Ri)
    
    xVmax   =  ((0    - Vfb) / Ric - Irb) * -Rtc + Vfb;
    VmaxErr = xVmax/Vmax - 1
    xVmin   =  ((Vdac - Vfb) / Ric - Irb) * -Rtc + Vfb
    VminErr = xVmin/Vmin - 1
    
    results.append([Irb, Rbt, Rt, Rtc, Rtc/Rt-1, Ri, Ric, Ric/Ri-1, xVmax, VmaxErr, xVmin, VminErr, (VmaxErr ** 4) + (VminErr ** 4)])

results.sort(key=itemgetter(12))

for i in range(args.results):
    r=results[i]
    Irb = r[0]
    Rbt = r[1]
    Rt  = r[2]
    Rtc = r[3]
    Ri  = r[5]
    Ric = r[6]
    xVmax = r[8]
    VmaxErr = r[9]
    xVmin = r[10]
    VminErr = r[11]
    print("Irb: %sA" % siprefix(Irb))
    print("Rb: %sΩ, Rt: %sΩ (%sΩ is %+2.2f%%)" % (siprefix(Rbt), siprefix(Rt), siprefix(Rtc), 100 * (Rtc/Rt - 1)));
    print("Ri: %sΩ (%sΩ is %+2.2f%%)" % (siprefix(Ri), siprefix(Ric), 100 * (Ric/Ri - 1)))
    print("Vmax = %sV (%+2.2f%%)" % (siprefix(xVmax), 100 * VmaxErr))
    print("Vmin = %sV (%+2.2f%%)" % (siprefix(xVmin), 100 * VminErr))
    
    print()
