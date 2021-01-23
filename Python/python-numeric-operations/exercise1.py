print(type('7'))
print(type(7))
print(type(7.1))

print(isinstance('7', str))
print(isinstance(7, int))
print(isinstance(7.1, float))

print(isinstance(7, str))
print(isinstance('7', int))
print(isinstance('7.1', float))

print(type('7') == str)
print(type(7) == int)
print(type(7.1) == float)

print(type(7) == str)
print(type('7') == int)
print(type('7.1') == float)

x = 'a string'
print(type(x))
x = 7
print(type(x))
x = False 
print(type(x))

first_value = int(input('First Number: '))
second_value = int(input('Second number: '))
sum = first_value + second_value
print("Sum: " + str(sum))