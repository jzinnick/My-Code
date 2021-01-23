fahrenheit = input('What is the temperature in fahrenheit? ')

if fahrenheit.isnumeric() == False:
    print('Please enter numbers only.')
    exit()

fahrenheit=int(fahrenheit)
celsius = int((fahrenheit - 32) * 5/9)
print('Temperature in celsius is '+ str(celsius))
