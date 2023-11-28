dic = {"name": "John", "age": 36, "country": "Norway"}
print(dic)
print(dic["name"])
print(dic["age"])
print(dic["country"])

# Dictionary length
print(len(dic))  # 3

# Dictionary type
print(type(dic))  # <class 'dict'>

# Dictionary keys
print(dic.keys())  # dict_keys(['name', 'age', 'country'])

# Dictionary values
print(dic.values())  # dict_values(['John', 36, 'Norway'])

# Dictionary items
print(dic.items())  # dict_items([('name', 'John'), ('age', 36), ('country', 'Norway')])

# Dictionary iteration
for i in dic:
    print(i)  # name age country

for i in dic:
    print(dic[i])  # John 36 Norway

for i in dic.values():
    print(i)  # John 36 Norway

for i in dic.items():
    print(i)  # ('name', 'John') ('age', 36) ('country', 'Norway')

for i, j in dic.items():
    print(i, j)  # name John age 36 country Norway

# Dictionary membership
print("name" in dic)  # True
print("John" in dic)  # False
print("John" not in dic)  # True

# Dictionary min
print(min(dic))  # age

# Dictionary max
print(max(dic))  # name

# Dictionary clear
dic.clear()
print(dic)  # {}

# Dictionary copy
dic = {"name": "John", "age": 36, "country": "Norway"}
dic2 = dic.copy()
print(dic2)  # {'name': 'John', 'age': 36, 'country': 'Norway'}

# Dictionary fromkeys
x = ("key1", "key2", "key3")
y = 0
dic = dict.fromkeys(x, y)
print(dic)  # {'key1': 0, 'key2': 0, 'key3': 0}

# Dictionary get
dic = {"name": "John", "age": 36, "country": "Norway"}
print(dic.get("name"))  # John

# Dictionary pop
dic.pop("name")
print(dic)  # {'age': 36, 'country': 'Norway'}

# Dictionary popitem
dic.popitem()
print(dic)  # {'age': 36}

# Dictionary setdefault
dic.setdefault("name", "John")
print(dic)  # {'age': 36, 'name': 'John'}

# Dictionary update
dic.update({"name": "John"})
print(dic)  # {'age': 36, 'name': 'John'}

# Dictionary values
print(dic.values())  # dict_values([36, 'John'])

# Dictionary clear
dic.clear()
print(dic)  # {}
