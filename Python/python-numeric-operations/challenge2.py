print('Simple calculator!')
number1 = input('First number? ')
if number1.isnumeric() == False:
    print('Please enter numbers only.')
    exit()
operator = input('Operation? ')
# if operator.isalpha() == False:
#     print('Please enter operator only.')
#     exit()
number2 = input('Second number? ')
if number2.isnumeric() == False:
    print('Please enter numbers only.')
    exit()
number1 = int(number1)
number2 = int(number2)

if operator == '+':
    answer = number1 + number2
    label = 'sum'
elif operator == '-':
    answer = number1 - number2
    label = 'difference'
elif operator == '*':
    answer = number1 * number2
    label = 'product'
elif operator == '/':
    answer = number1 / number2
    label = 'quotient'
elif operator == '%':
    answer = number1 % number2
    label = 'exponent'
elif operator == '**':
    answer = number1 ** number2
    label = 'modulus'
else:
    print('Not a valid operator!')

print(f'{str.capitalize(label)} of {str(number1)} {str(operator)} {str(number2)} equals {str(answer)}')

# THERE ANSWER
# print('Simple calculator!')

# first_number = input('First number? ')

# if first_number.isnumeric() == False:
#     print('Please input a number.')
#     exit()

# operation = input('Operation? ')

# second_number = input('Second number? ')

# if second_number.isnumeric() == False:
#     print('Please input a number.')
#     exit()

# first_number = int(first_number)
# second_number = int(second_number)

# result = 0
# if operation == '+':
#     result = first_number + second_number
#     label = 'sum'
# elif operation == '-':
#     result = first_number - second_number
#     label = 'difference'
# elif operation == '*':
#     result = first_number * second_number
#     label = 'product'
# elif operation == '/':
#     result = first_number / second_number
#     label = 'quotient'
# elif operation == '**':
#     result = first_number ** second_number
#     label = 'exponent'
# elif operation == '%':
#     result = first_number % second_number
#     label = 'modulus'
# else:
#     print('Operation not recognized.')
#     exit()

# print(label + ' of ' + str(first_number) + ' ' + operation + ' ' + str(second_number) + ' equals ' + str(result))