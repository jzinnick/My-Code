import random
guess = 0
tries = 0
number = random.randint(1, 10)
print('Guess a number between 1 and 10')

while guess != number:
    tries += 1
    guess= input(f'Enter guess # {tries}: ')
    if guess.isnumeric():
        guess=int(guess)
    else:
        print('Numbers only please!')
        continue
    if guess > number:
        print('Your guess is to high, try again!')
    elif guess < number:
        print('Your guess is to low, try again!')
else:
    print(f'You guessed it in {tries} tries!')