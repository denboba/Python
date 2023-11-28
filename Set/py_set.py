basket = {'apple', 'orange', 'apple', 'pear', 'orange', 'banana'}
print(basket)  # {'banana', 'apple', 'pear', 'orange'}
print('orange' in basket)  # True
print('crabgrass' in basket)  # False
# Demonstrate set operations on unique letters from two words
a = set('abracadabra')
b = set('alacazam')
print(a)  # {'r', 'b', 'c', 'd', 'a'}
print(b)  # {'m', 'z', 'c', 'a', 'l'}
print(a - b)  # {'d', 'b', 'r'}
print(a | b)  # {'r', 'b', 'c', 'd', 'm', 'z', 'a', 'l'}
print(a & b)  # {'a', 'c'}
print(a ^ b)  # {'r', 'b', 'd', 'm', 'z', 'l'}
# Similarly to list comprehensions, set comprehensions are also supported:
a = {x for x in 'abracadabra' if x not in 'abc'}
print(a)  # {'r', 'd'}

# modify the set
basket.add('melon')
print(basket)  # {'banana', 'apple', 'pear', 'orange', 'melon'}
basket.remove('apple')
print(basket)  # {'banana', 'pear', 'orange', 'melon'}
basket.discard('banana')
print(basket)  # {'banana', 'pear', 'orange', 'melon'}
basket.pop()
print(basket)  # {'pear', 'orange', 'melon'}
basket.clear()
print(basket)  # set()

# Set comprehensions are also supported:
a = {x for x in range(100) if x % 3 == 0}
print(a)  # {0, 3, 6, 9, 12, 15, 18, 21, 24, 27, ...}

# frozenset is a set that cannot be changed
a = frozenset([1, 2, 3, 4, 5])
print(a)  # frozenset({1, 2, 3, 4, 5})
#a.add(6)  # AttributeError: 'frozenset' object has no attribute 'add'
#a.remove(1)  # AttributeError: 'frozenset' object has no attribute 'remove'
print(a)  # frozenset({1, 2, 3, 4, 5})
