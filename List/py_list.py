
list = [1, 2, 3, 4, 5]
print(list)  # [1, 2, 3, 4, 5]
print(list[0])  # 1
print(list[4])  # 5
print(list[-1])  # 5

list[0] = 10 # modify the list
print(list)  # [10, 2, 3, 4, 5]

list.append(6) # add an element to the end of the list
print(list)  # [10, 2, 3, 4, 5, 6]
list.insert(0, 20) # insert an element at a specific position

print(list)  # [20, 10, 2, 3, 4, 5, 6]

list.remove(10) # remove an element from the list
print(list)  # [20, 2, 3, 4, 5, 6]

list.pop() # remove the last element from the list
print(list)  # [20, 2, 3, 4, 5]

list.pop(0) # remove the first element from the list
print(list)  # [2, 3, 4, 5]

list.clear() # remove all elements from the list

print(list)  # []

# hetreogeneous list
list = [1, 2.0, "Hello", True]
print(list)  # [1, 2.0, 'Hello', True]

# nested list
list = ["mouse", [8, 4, 6], ['a']]
print(list)  # ['mouse', [8, 4, 6], ['a']]
print(list[0])  # mouse
print(list[1])  # [8, 4, 6]
print(list[2])  # ['a']
print(list[0][3])  # s


# List comprehensions
list = [x for x in range(10)]
print(list)  # [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
list = [x for x in range(10) if x % 2 == 0]
print(list)  # [0, 2, 4, 6, 8]

# List slicing
list = [1, 2, 3, 4, 5]
print(list[1:3])  # [2, 3]
print(list[:3])  # [1, 2, 3]
print(list[1:])  # [2, 3, 4, 5]
print(list[:])  # [1, 2, 3, 4, 5]
print(list[::2])  # [1, 3, 5]
print(list[::-1])  # [5, 4, 3, 2, 1]

# List sorting
list = [4, 2, 7, 3, 1]
list.sort()
print(list)  # [1, 2, 3, 4, 7]
list.sort(reverse=True)

print(list)  # [7, 4, 3, 2, 1]
list = [4, 2, 7, 3, 1]
list.reverse()
print(list)  # [1, 3, 7, 2, 4]

# List membership

list = [1, 2, 3, 4]
print(1 in list)  # True
print(5 in list)  # False
print(5 not in list)  # True

# List iteration
list = ["apple", "banana", "cherry"]
for i in list:
    print(i)  # apple banana cherry

# List length
list = ["apple", "banana", "cherry"]
print(len(list))  # 3

# List min
list = [1, 2, 3, 4]
print(min(list))  # 1

# List max
list = [1, 2, 3, 4]
print(max(list))  # 4




