
tuple = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
print(tuple)  # (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

# Tuple slicing
print(tuple[1:3])  # (2, 3)
print(tuple[:3])  # (1, 2, 3)
print(tuple[1:])  # (2, 3, 4, 5, 6, 7, 8, 9, 10)
print(tuple[:])  # (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
print(tuple[::2])  # (1, 3, 5, 7, 9)
print(tuple[::-1])  # (10, 9, 8, 7, 6, 5, 4, 3, 2, 1)

# Tuple membership
tuple = (1, 2, 3, 4)
print(1 in tuple)  # True
print(5 in tuple)  # False
print(5 not in tuple)  # True

# Tuple iteration
tuple = ("apple", "banana", "cherry")
for i in tuple:
    print(i)  # apple banana cherry

# Tuple length
print(len(tuple))  # 3

# Tuple min
tuple = (1, 2, 3, 4)
print(min(tuple))  # 1

# Tuple max
tuple = (1, 2, 3, 4)
print(max(tuple))  # 4

# Tuple count
tuple = (1, 2, 3, 4, 1, 1)
print(tuple.count(1))  # 3

# Tuple index
tuple = (1, 2, 3, 4, 1, 1)
print(tuple.index(1))  # 0

# Tuple type
tuple = (1, 2, 3, 4)
print(type(tuple))  # <class 'tuple'>

# Tuple concatenation
tuple = (1, 2, 3, 4)
tuple2 = (5, 6, 7, 8)
print(tuple + tuple2)  # (1, 2, 3, 4, 5, 6, 7, 8)

# Tuple replication
tuple = (1, 2, 3, 4)
print(tuple * 2)  # (1, 2, 3, 4, 1, 2, 3, 4)

# Tuple unpacking
tuple = (1, 2, 3, 4)
a, b, c, d = tuple
print(a)  # 1
print(b)  # 2
print(c)  # 3
print(d)  # 4

# Tuple unpacking
tuple = (1, 2, 3, 4)
a, b, *c = tuple
print(a)  # 1
print(b)  # 2
print(c)  # [3, 4]

# Tuple unpacking
tuple = (1, 2, 3, 4)
a, *b, c = tuple

