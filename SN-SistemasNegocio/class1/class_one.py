# 1.- Count the number of items in a list with the result in a dictionary.
l = ["a","b","c","d","d","a","d"]
for i in l:
    c[i] = l.count(i)
print c

# 2.- Print only odd numbers.
for i in range(1,10):
    if i%2==1:
        print i

# 3.- Answers to: py args.py 34,67,55,33,12,98 / AND /  py args.py 23 24 22
import sys
if (len(sys.argv)>2):
    li=[]
    for num in sys.argv[1:]:
        li.append(num)
else:
    li=sys.argv[1].split(".")
print li
print tuple(li)

# 4.- Compute word frequency of a text file and print it ordered.
import sys
words = open(sys.argv[1]).read().split()
for w in words
    freq[words.count(w)] = w
print freq.sort()

# 5.- Matrix from file. /Cómo hacer escalable la parte del With?/
import sys
def mat_calc(matrix):
    for l in matrix:
        for n in l.split():
            yield int(n)
with open(sys.argv[1]) as matrix:
    print mat_calc(matrix).next() * 2
    print mat_calc(matrix).next() * 2

# 6.- A list whose elements are square of numbers. /Falt matplotlib/
def pow_n(x):
    return lambda y: y ** x
print map(pow_n(2),range(1,21))

# 7.- Permutations.
import itertools
print([x for x in itertools.permutations('1234')]) # on a tuple.
print list(map("".join, itertools.permutations('1234'))) # on a string.

# 8.-
# 9.-
# 10.-