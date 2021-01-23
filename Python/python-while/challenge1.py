import random
guess = 0
tries = 0
number = random.randint(1, 5)

while guess != number:
    tries += 1
    guess = input('Guess a number between 1 and 5: ')
    if guess.isnumeric():
        guess=int(guess)
else:
    print(f'You guessed it in {tries} tries!')