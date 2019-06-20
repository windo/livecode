b1 >> bass([0, 2, 3, 4], dur=4, amp=0.8, oct=4, lpf=50, delay=(0, 1), drive=0.1)

p1 >> pluck(dur=.25, slide=[0,0,0,[0,0,0,1]]).follow(b1) + P[(0, 2, 4), 2, 4, 0]

d1 >> play("xxox")

hh >> play("---(-=)")
